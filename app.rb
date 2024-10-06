require 'sinatra/r18n'
require "sinatra/cookies"
require_relative './cells/button_cell.rb'
require_relative './cells/fruit_form_cell.rb'
require_relative './cells/fruit_card_cell.rb'
require_relative './cells/login_cell.rb'
# require 'rack-ssl-enforcer'
require 'securerandom'
require 'sanitize'
# require 'rack/protection'
require 'bcrypt'
# require 'rest-client'
require 'json'
require 'sendgrid-ruby'
require 'dotenv/load'  # This loads the .env file

include SendGrid

class App < Sinatra::Base
    helpers do
        def sendgrid_client
            @sg ||= SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
        end
    end
    
    # use Rack::Protection

    # use Rack::SslEnforcer

    # use SecureHeaders::Middleware

    # SecureHeaders::Configuration.default do |config|
    #     config.hsts = "max-age=31536000; includeSubDomains" # Force HTTPS
    #     config.x_content_type_options = "nosniff"           # Prevent MIME-type sniffing
    #     config.x_frame_options = "DENY"                     # Prevent clickjacking
    #     config.x_xss_protection = "1; mode=block"           # Enable XSS protection
    # end

    # use Rack::Throttle::Hourly,   :max => 1000   # requests
    # use Rack::Throttle::Minute,   :max => 60    # requests

    # use Rack::Session::Cookie, :key => 'rack.session',
    #                         :path => '/',
    #                         :secret => 'your_secret'

    enable :sessions
    use Rack::Session::Pool, :expire_after => 2592000
    set :session_secret, SecureRandom.hex(64)
    # set :sessions, httponly: true, secure: true, same_site: :strict

    helpers Sinatra::Cookies

    def logged_in?
        !session[:user_id].nil?
    end

    before do
        # Generate a random nonce for each request
        @nonce = SecureRandom.base64(16)

        user = db.execute("SELECT * FROM users WHERE username = ?", [session['user_id']]).first

        @is_admin = false

        if user
            @is_admin =  user['admin'] == 1
        end

        response.set_header('content-type', 'text/html')

        session[:locale] = cookies[:locale] if cookies[:locale]

        # Redirect to /login if not logged in and the path is not already /login
        unless logged_in? || request.path_info == '/login' || request.path_info == '/register' || request.path_info.start_with?('/verify')
            redirect '/login'
        end
    end

    set :erb, escape_html: true #prevents xss

    register Sinatra::R18n
    set :root, __dir__

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/fruits.sqlite")
        @db.results_as_hash = true

        return @db
    end
    
    # Routen gör en redirect till '/fruits'
    get '/' do
        redirect("/fruits")
    end

    get '/admin' do 
        user = db.execute("SELECT * FROM users WHERE username = ?", [session['user_id']]).first

        if user['admin'] == 0 
            redirect '/fruits'
        end

        @users = db.execute("SELECT * FROM users ")

        erb :"admin"
    end

    post '/admin/update/:id' do
        user = db.execute("SELECT * FROM users WHERE username = ?", [session['user_id']]).first

        if user['admin'] == 0 
            return
        end

        user_id = params[:id]
        data = JSON.parse(request.body.read) # Read and parse the JSON request body

        username = data['username']
        email = data['email']
        verified = data['verified'].to_i
        admin = data['admin'].to_i

        # Update the user in the database
        db.execute("UPDATE users SET username = ?, email = ?, verified = ?, admin = ? WHERE id = ?", [username, email, verified, admin, user_id])

        # Respond with a JSON object indicating success
        { status: 'success' }.to_json
    end

    get '/login' do
        # if logged_in?
        #     redirect '/fruits'
        #     return
        # end

        @loginCell = LoginCell.new

        erb :"login", :layout => false
    end

    get '/register' do
        # if logged_in?
        #     redirect '/fruits'
        #     return
        # end

        @loginCell = LoginCell.new

        erb :"register", :layout => false
    end

    post '/register' do 
        content_type :json

        # if logged_in?
        #     return { status: 'success', redirect_url: '/fruits' }.to_json
        # end

        request_payload = JSON.parse request.body.read

        username = request_payload["usernameInput"]
        email = request_payload["emailInput"]
        password = request_payload["passwordInput"]

        begin
            db.transaction do
                # Hash the password
                password_hash = BCrypt::Password.create(password)
                verification_token = SecureRandom.hex(16)

                # Save user to the database
                db.execute("INSERT INTO users (username, email, password_hash, verification_token) VALUES (?, ?, ?, ?)",
                            [username, email, password_hash, verification_token])

                # Send verification email
                send_verification_email(email, verification_token)
            end

            return { status: 'success', message: 'Registration successful! Please verify your email.' }.to_json

        rescue SQLite3::ConstraintException => e
            return { status: 'error', message: 'Username or email already exists!' }.to_json
        rescue => e
            return { status: 'error', message: "An error occurred during registration: #{e}" }.to_json
        end
    end

    def send_verification_email(email, token)
        verification_link = "#{request.base_url}/verify/#{token}"

        from = Email.new(email: ENV['SENDGRID_MAIL'])
        to = Email.new(email: email)
        subject = 'Verify your account'
        content = Content.new(type: 'text/plain', value: "Please verify your account by clicking the link: #{verification_link}")

        mail = SendGrid::Mail.new(from, subject, to, content)

        begin
            response = sendgrid_client.client.mail._('send').post(request_body: mail.to_json)

            if response.status_code.to_i != 202
                raise "Email sending failed"
            end
        rescue => e
            raise "Failed to send verification email: #{e}"
        end
    end

    get '/verify/:token' do |token|
        # Find the user by token
        user = db.execute("SELECT * FROM users WHERE verification_token = ?", [token]).first

        if user
            # Mark user as verified in the database
            db.execute("UPDATE users SET verified = 1, verification_token = NULL WHERE id = ?", [user['id']])
            "Your account has been verified. You can now log in."
        else
            "Invalid or expired token."
        end

        redirect '/login'
    end

    post '/logout' do
        session['user_id'] = nil 
        redirect '/login'
    end

    #Routen hämtar alla frukter i databasen
    get '/fruits' do

        @fruits = db.execute('SELECT * FROM fruits')
        
        @fruit_categories = db.execute('SELECT category FROM FRUITS GROUP BY category')
        @categorized_fruit = {} 

        @fruit_categories.each do |row|
            category = row['category']
            @categorized_fruit[category] = db.execute('
                SELECT fruits.*, 
                    COUNT(comments.id) AS comment_count
                FROM fruits
                LEFT JOIN comments ON comments.fruit_id = fruits.id
                WHERE fruits.category = ?
                GROUP BY fruits.id
            ', category)

            # @categorized_fruit[category] = db.execute('SELECT * FROM FRUITS WHERE category = ?', category)
        end

        @fruitCardCell = FruitCardCell.new

        erb(:"fruits/index")
    end

    # Övning no. 2.1
    # Routen visar ett formulär för att spara en ny frukt till databasen.
    get '/fruits/new' do
        @fruitFormCell = FruitFormCell.new
        erb(:"fruits/new")
    end

    # Övning no. 2.2
    # Routen sparar en frukt till databasen och gör en redirect till '/fruits'.
    post '/fruits/new' do
        # rate_limit 'newfruit', 2,  20,
        #                        10, 600

        request_payload = JSON.parse request.body.read

        name = Sanitize.fragment(request_payload['name']) # Sanitize user input
        tastiness = request_payload['tastiness'].to_i
        category = Sanitize.fragment(request_payload['category']) # Sanitize user input
        description = Sanitize.fragment(request_payload['description']) # Sanitize user input
        price = request_payload['price'].to_f # Use to_f if price can be decimal
        image = request_payload['image'] # Base64 image; you may want to validate the format
        current_time = Time.now.strftime('%Y-%m-%d %H:%M:%S')

        # Insert fruit data without image path
        db.execute("INSERT INTO fruits (name, tastiness, description, category, price, edited_at) VALUES (?, ?, ?, ?, ?, ?)", 
                    [name, tastiness, description, category, price, current_time])

        # Retrieve the last inserted ID
        fruit_id = db.last_insert_row_id

        if image
            filename = "#{fruit_id}.png"
            file_path = "public/uploads/#{filename}"

            # Decode the Base64 string and save the file
            File.open(file_path, 'wb') do |file|
                file.write(Base64.decode64(image))
            end

            server_file_path = "uploads/#{filename}"

            # Update the fruit record with the image path
            db.execute("UPDATE fruits SET image_path = ? WHERE id = ?", [server_file_path, fruit_id])
        end

        { status: 'success', message: 'Fruit created successfully', id: fruit_id }.to_json
    end

    post '/login' do
        content_type :json

        # if logged_in?
        #     return { status: 'success', redirect_url: '/fruits', message: 'Redirecting to /fruits' }.to_json
        #     # redirect '/fruits'
        # end

        request_payload = JSON.parse request.body.read

        username = request_payload["usernameInput"]
        password = request_payload["passwordInput"]



        user = db.execute("SELECT * FROM users WHERE username = ?", [username]).first

        return { status: 'error', message: 'Incorrect password or username' }.to_json unless user

        if user['verified'] == 0 
            { status: 'error', message: 'Account is not verified, please check your mail' }.to_json
        end

        stored_password_hash = user['password_hash']

        if BCrypt::Password.new(stored_password_hash) == password
            session[:user_id] = username
            return { status: 'success', redirect_url: '/fruits', message: 'Redirecting to /fruits' }.to_json
            # redirect '/fruits'
        end

        { status: 'error', message: 'Incorrect password or username' }.to_json
    end

    post '/fruits/change' do
        # rate_limit 'newfruit', 2,  20,
        #                        10, 600

        request_payload = JSON.parse request.body.read

        name = Sanitize.fragment(request_payload['name']) # Sanitize user input
        tastiness = request_payload['tastiness'].to_i
        category = Sanitize.fragment(request_payload['category']) # Sanitize user input
        description = Sanitize.fragment(request_payload['description']) # Sanitize user input
        price = request_payload['price'].to_f # Use to_f if price can be decimal
        fruit_id = request_payload['id'].to_i
        image = request_payload['image'] # Base64 image; you may want to validate the format
        keep_image = request_payload['keep_image']
        current_time = Time.now.strftime('%Y-%m-%d %H:%M:%S')

        db.execute("UPDATE fruits SET name=?, tastiness=?, description=?, price=?, edited_at=? WHERE id=?", [name, tastiness, description, price, current_time, fruit_id])

        if !keep_image
            db.execute("UPDATE fruits SET image_path = NULL WHERE id=?", [fruit_id])
        end
        
        if image
            filename = "#{fruit_id}.png"
            file_path = "public/uploads/#{filename}"

            # Decode the Base64 string and save the file
            File.open(file_path, 'wb') do |file|
                file.write(Base64.decode64(image))
            end

            server_file_path = "uploads/#{filename}"

            # Update the fruit record with the image path
            db.execute("UPDATE fruits SET image_path = ? WHERE id = ?", [server_file_path, fruit_id])
        end

        { status: 'success', message: 'Fruit changed successfully', id: fruit_id }.to_json
    end

    get '/fruits/:id' do | id |
        @fruit_data = db.execute("SELECT * FROM fruits WHERE id=? LIMIT 1", id).first
        @comments = db.execute("
            SELECT comments.content, comments.created_at, users.username 
            FROM comments 
            INNER JOIN users ON comments.user_id = users.id 
            WHERE comments.fruit_id = ?
            ORDER BY comments.created_at DESC
        ", id)

        p @comments

        @fruitFormCell = FruitFormCell.new
        erb(:"fruits/show")
    end

    post '/fruits/:id/comments' do |id|
        content = params[:content]
        user_id = session['user_id'] # Assuming the user is logged in

        user = db.execute("SELECT * FROM users WHERE username = ?", [user_id]).first
        
        if user_id && content.strip != ''
            db.execute("INSERT INTO comments (user_id, fruit_id, content) VALUES (?, ?, ?)", [user['id'], id, content])
        end
        
        redirect back
    end

    post '/fruits/remove/:id' do | id |
        # rate_limit 'newfruit', 2,  20,
        #                        10, 600

        db.execute("DELETE FROM fruits WHERE id = ?", id)
        begin
            filename = "#{id}.png"
            file_path = "public/uploads/#{filename}"
            File.open(file_path, 'r') do |file|
                File.delete(file)
            end
        rescue Errno::ENOENT
        end
        redirect '/fruits'
    end
end