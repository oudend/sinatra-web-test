require 'sqlite3'
require 'bcrypt'

class Seeder
  
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS fruits')
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS comments')
  end

  def self.create_tables
    db.execute('CREATE TABLE fruits (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL CHECK(name <> "") UNIQUE,
                tastiness INTEGER NOT NULL CHECK(tastiness > 0),
                description TEXT,
                image_path TEXT,
                category TEXT NOT NULL CHECK(category <> ""),
                price INTEGER NOT NULL CHECK(price > 0),
                edited_at DATETIME)')
    db.execute('CREATE TABLE users (
                id INTEGER PRIMARY KEY,
                username TEXT UNIQUE NOT NULL,
                password_hash TEXT NOT NULL,
                email TEXT UNIQUE NOT NULL,
                verification_token TEXT,
                verified INTEGER DEFAULT 0 NOT NULL,
                admin INTEGER DEFAULT 0 NOT NULL)')
    db.execute('CREATE TABLE comments (
                id INTEGER PRIMARY KEY,
                user_id INTEGER NOT NULL,
                fruit_id INTEGER NOT NULL,
                content TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY(user_id) REFERENCES users(id),
                FOREIGN KEY(fruit_id) REFERENCES fruits(id))')
  end

  def self.populate_tables
    db.execute('INSERT INTO fruits (name, tastiness, description, category, price) VALUES ("Äpple", 7, "En rund frukt som finns i många olika färger.", "frukt", 10)')
    db.execute('INSERT INTO fruits (name, tastiness, description, category, price) VALUES ("Päron", 6, "En nästan rund, men lite avläng, frukt. Oftast mjukt fruktkött.", "frukt", 10)')
    db.execute('INSERT INTO fruits (name, tastiness, description, category, price) VALUES ("Banan", 4, "En avlång gul frukt.", "frukt", 10)')
    password_hash = BCrypt::Password.create('SecretPassword')
    db.execute("INSERT INTO users (username, password_hash, email, verified, admin) VALUES (?, ?, ?, ?, ?)", ['oudend', password_hash, "oudend@gmail.com", 1, 1])
  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/fruits.sqlite')
    @db.results_as_hash = true
    @db
  end
end


Seeder.seed!