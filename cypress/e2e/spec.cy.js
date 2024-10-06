describe("Login Page", () => {
  beforeEach(() => {
    cy.visit("http://localhost:9292/login");
  });

  it("should load the login page", () => {
    // Check page title
    cy.title().should("eq", "Fruit Paradise - Login");

    // Check for username input
    cy.get('input[name="usernameInput"]').should("be.visible");

    // Check for password input
    cy.get('input[name="passwordInput"]').should("be.visible");

    // Check for Remember Me checkbox
    cy.get('input[name="rememberMeCheckbox"]').should("be.visible");

    // Check for language dropdown
    cy.get("#languageDropdown").should("be.visible");

    // Check for dark mode button
    cy.get("#dark").should("be.visible");

    // Check for submit button
    cy.get('button[type="submit"]').contains("Sign In").should("be.visible");
  });

  it("should show and hide password when clicking the toggle", () => {
    // Check if the password is initially hidden
    cy.get('input[name="passwordInput"]').should(
      "have.attr",
      "type",
      "password"
    );

    // Click the show password button
    cy.get("#togglePassword").click();

    // Check if the password is now visible
    cy.get('input[name="passwordInput"]').should("have.attr", "type", "text");

    // Click the hide password button
    cy.get("#togglePassword").click();

    // Check if the password is hidden again
    cy.get('input[name="passwordInput"]').should(
      "have.attr",
      "type",
      "password"
    );
  });

  it("should not log in with empty credentials", () => {
    // Try to submit the form without typing anything
    cy.get('button[type="submit"]').click();

    // Expect an error message (this assumes you have some validation mechanism)
    cy.url().should("include", "/login"); // Ensure still on login page
    // Add your validation message check here, if any
  });

  it("should not log in with incorrect credentials", () => {
    // Enter incorrect username and password
    cy.get('input[name="usernameInput"]').type("wrongUser");
    cy.get('input[name="passwordInput"]').type("wrongPassword");

    // Submit the form
    cy.get("form").submit();

    // Expect failure (check for an error message, redirect, etc.)
    cy.url().should("include", "/login"); // Still on login page
    // Add your validation message check here, if any
  });

  it("should log in with correct credentials", () => {
    cy.visit("http://localhost:9292/login");
    // Enter correct username and password
    cy.get('input[name="usernameInput"]').type("oudend");
    cy.get('input[name="passwordInput"]').type("SecretPassword");

    // Submit the form
    cy.get("form").submit();

    cy.intercept({
      method: "POST",
      url: "/login",
    });

    // Expect to be redirected to the fruits page (or wherever it goes after login)
    cy.url().should("not.include", "/login"); // Ensure we're no longer on login
    cy.url().should("include", "/fruits"); // Ensure it redirects to the right page
  });
});

describe("Fruits Page Tests", () => {
  beforeEach(() => {
    cy.visit("http://localhost:9292/fruits");
  });

  it("should load the /fruits page and verify all navbar links", () => {
    // Check if the navbar links are present
    cy.get("nav").within(() => {
      cy.get('a[href="/fruits"]').should("exist"); // Link to the fruits page
      cy.get('a[href="/fruits/new"]').should("exist"); // Link to create new fruit

      cy.get('a[href="/fruits"]').first().click(); // Use .first() to click the first matching link
      cy.url().should("include", "/fruits");

      cy.get('a[href="/fruits/new"]').first().click(); // Use .first() to select the first match
      cy.url().should("include", "/fruits/new");
    });
  });

  it("should switch themes with the theme switcher", () => {
    // Click the dark mode toggle button
    cy.get("#dark").click();

    // Verify that the dark mode is enabled by checking the attribute
    cy.get("html").should("have.attr", "data-bs-theme", "dark");

    // Switch back to light mode
    cy.get("#light").click();

    // Verify that light mode is restored
    cy.get("html").should("not.have.attr", "data-bs-theme", "dark");
  });

  it("should test the language selector", () => {
    // Select a different language
    cy.get("#languageDropdown").click();
    cy.get('.dropdown-menu a[data-code="sv"]').click(); // Switch to Swedish

    // Reloaded page will now display in Swedish
    cy.url().should("include", "/fruits");
    // You can check if the language switch happened by checking elements
    cy.get("html").should("have.attr", "lang", "sv");
  });

  it("should verify the search functionality works", () => {
    // Get the initial number of fruit cards before the search
    cy.get(".fruit-card")
      .its("length")
      .then((initialCount) => {
        // Search for a non-existing fruit
        cy.get("#fruitSearch").type("dwojdiowfjoifje");

        cy.wait(2000);

        // Check how many fruit cards are visible after the search
        let visibleCount = 0;

        cy.get(".fruit-card")
          .each((el) => {
            // Check if the fruit card is visible
            const displayStyle = el.css("display");
            if (displayStyle !== "none") {
              visibleCount++;
            }
          })
          .then(() => {
            // Assert that the number of visible fruit cards is less than the initial count
            expect(visibleCount).to.be.lessThan(initialCount);
          });
      });
  });

  it("should ensure category lists are visible after search clears", () => {
    // Search and clear search bar to check if all categories are displayed again
    cy.get("#fruitSearch").type("Banana");
    cy.get("#fruitSearch").clear();

    // Ensure all categories are visible again after clearing search
    cy.get(".category-list").should("be.visible");
  });
});

describe("Fruit Creation", () => {
  beforeEach(() => {
    cy.visit("http://localhost:9292/fruits/new");
  });

  it("should create a new fruit", () => {
    cy.get('input[name="name"]').clear().type("test name");
    cy.get('input[name="tastiness"]').clear().type("2");
    cy.get('input[name="description"]').clear().type("test description");
    cy.get('input[name="price"]').clear().type("2");
    cy.get('input[name="category"]').clear().type("test category");
    // Fill other fields as necessary

    cy.get("form").submit();

    cy.visit("http://localhost:9292/fruits");

    // Assert that the new fruit appears in the list of fruits
    cy.get(".fruit-card").should("contain", "test name");
    cy.get(".fruit-card").should("contain", "2");
    cy.get(".fruit-card").should("contain", "test description");
    cy.get("h3").should("contain", "test category");
  });

  it("should edit the created fruit", () => {
    cy.visit("http://localhost:9292/fruits");
    // First, locate the fruit with "test name" that was created
    cy.get(".fruit-card")
      .contains("test name") // Find the fruit card with the name "test name"
      .parents(".fruit-card") // Scope the action to the parent fruit card container
      .find("a.btn-primary") // Find the "Edit" button (assuming it's a button with the 'btn-primary' class)
      .click();

    // Edit the fruit's details in the form
    cy.get('input[name="name"]').clear().type("edited name");
    cy.get('input[name="tastiness"]').clear().type("182");
    cy.get('input[name="description"]').clear().type("edited description");
    cy.get('input[name="price"]').clear().type("1234");

    // Submit the form
    cy.get("form").submit();

    // Verify the changes on the fruits page
    cy.visit("http://localhost:9292/fruits");
    // cy.reload();

    // Verify the updated fruit details are reflected
    cy.get(".fruit-card")
      .contains("edited name") // Check that the new name is displayed
      .parents(".fruit-card") // Scope to the updated fruit card container
      .should("contain", "182") // Verify updated tastiness
      .and("contain", "edited description") // Verify updated description
      .and("contain", "1234"); // Verify updated price
  });

  it("should delete edited fruit", () => {
    cy.visit("http://localhost:9292/fruits");

    // Find the specific fruit card by the name and click the "Remove" button
    cy.contains(".fruit-card", "edited name")
      .find("button.btn-danger") // Target the "Remove" button
      .first()
      .click();

    // Confirm the modal appears
    cy.get(".modal").should("be.visible");

    // Wait for the modal to be visible
    cy.get(".modal.show")
      .should("be.visible")
      .within(() => {
        // Click the confirm remove button in the modal
        cy.get('button[type="submit"]').click();
      });

    // Assert that the fruit is no longer in the list
    cy.visit("http://localhost:9292/fruits");
    cy.get(".fruit-card").should("not.contain", "edited name");
  });
});
