# Fruktparadiset

(Den här readme filen var skapad med hjälp av chatGPT)

## Beskrivning

Fruktparadiset är en webbapplikation byggd med Ruby och Sinatra som låter användare hantera frukter, registrera sig, logga in och administrera användare. Applikationen erbjuder också en kommentaravdelning för varje frukt.

## Projektstruktur

```

└── 📁wsp1-ex2
    └── 📁bin
        └── rackup
    └── 📁cells
        └── 📁button
            └── show.erb
        └── 📁fruit_card
            └── show.erb
        └── 📁fruit_form
            └── show.erb
        └── 📁login
            └── show.erb
        └── 📁theme_switcher
            └── show.erb
        └── button_cell.rb
        └── fruit_card_cell.rb
        └── fruit_form_cell.rb
        └── login_cell.rb
        └── theme_switcher_cell.rb
    └── 📁cypress
        └── 📁downloads
        └── 📁e2e
            └── spec.cy.js
        └── 📁fixtures
            └── example.json
        └── 📁support
            └── commands.js
            └── e2e.js
    └── 📁db
        └── fruits.sqlite
        └── seeder.rb
    └── 📁docs
        └── 📁img
            └── fruktparadiset.png
        └── .project_structure_ignore
        └── project_structure.txt
    └── 📁i18n
        └── en.yml
        └── ru.yml
        └── sv.yml
    └── 📁ngrok-v3-stable-linux-amd64
        └── ngrok
    └── 📁public
        └── 📁img
            └── affaren.png
            └── login.png
        └── 📁js
            └── switch.js
        └── 📁uploads
            └── 0.png
            └── 2.png
            └── 3.png
        └── style.css
    └── 📁views
        └── 📁fruits
            └── index.erb
            └── new.erb
            └── show.erb
        └── admin.erb
        └── layout.erb
        └── login.erb
        └── register.erb
    └── .env
    └── .gitignore
    └── app.rb
    └── config.ru
    └── cypress.config.js
    └── Gemfile
    └── Gemfile.lock
    └── LICENSE
    └── ngrok-v3-stable-linux-amd64.tgz
    └── rakefile
    └── README.md

```

### Beskrivning av mappar och filer

- **bin/rackup**: Startar applikationen.
- **cells**: Innehåller olika celler för att rendera komponenter som knappar och formulär.
- **cypress**: Innehåller tester för applikationen.
- **db**: Innehåller databasen och en fil för att fylla databasen med exempeldata.
- **docs**: Innehåller dokumentation och bilder.
- **i18n**: Innehåller lokaliseringsfiler för att stödja flera språk.
- **ngrok-v3-stable-linux-amd64**: Innehåller ngrok för att göra applikationen tillgänglig på internet.
- **public**: Innehåller offentliga resurser som bilder och CSS.
- **views**: Innehåller alla vyer (erb-filer) för applikationen.
- **.env**: Innehåller miljövariabler.
- **.gitignore**: Fil som anger vilka filer som ska ignoreras av git.
- **app.rb**: Huvudfilen för applikationen.
- **config.ru**: Rack-konfigurationsfil.
- **Gemfile**: Lista över beroenden för applikationen.
- **rakefile**: Innehåller olika rake-tasks för att hantera applikationen.

## Funktioner

- **Användarregistrering**: Användare kan registrera sig för att få tillgång till applikationen.
- **Inloggning**: Registrerade användare kan logga in och få tillgång till fruktlistan.
- **Frukt hantering**: Användare kan se, skapa och redigera frukter.
- **Kommentarer**: Användare kan lämna kommentarer på frukter.
- **Administrationsverktyg**: Administratörer kan hantera användare och deras behörigheter.
- **Flera språk**: Applikationen stödjer flera språk via lokaliseringsfiler.

## Komma igång

1. Klona repot:

   ```bash
   git clone "https://github.com/oudend/sinatra-web-test"
   ```

2. Navigera till projektmappen:
   ```bash
   cd wsp1-ex2
   ```
3. Installera beroenden:
   ```bash
   bundle install
   ```
4. Starta databasen och fyll den med exempeldata:
   ```bash
   rake seed
   ```
5. Starta applikationen:
   ```bash
   rake dev
   ```

Nu kan du besöka applikationen i din webbläsare på `http://localhost:9292`.

## Licens
