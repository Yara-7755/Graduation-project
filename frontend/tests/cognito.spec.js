import { test, expect } from "@playwright/test";

const BASE_URL = "http://localhost:5173";

test.describe("Cognito Full Basic Flow", () => {
  test.beforeEach(async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.clear();
      sessionStorage.clear();
    });
  });

  test("landing page loads", async ({ page }) => {
    await page.goto(BASE_URL);
    await expect(page.locator("body")).toContainText(/cognito/i);
  });

  test("login page loads correctly", async ({ page }) => {
    await page.goto(`${BASE_URL}/login`);

    await expect(page).toHaveURL(/login/);
    await expect(page.getByPlaceholder("Email")).toBeVisible();
    await expect(page.getByPlaceholder("Password")).toBeVisible();
    await expect(page.getByRole("button", { name: /^login$/i })).toBeVisible();
  });

  test("login shows error for invalid credentials", async ({ page }) => {
    await page.goto(`${BASE_URL}/login`);

    await page.getByPlaceholder("Email").fill("wrong@example.com");
    await page.getByPlaceholder("Password").fill("wrongpassword");
    await page.getByRole("button", { name: /^login$/i }).click();

    await expect(page.locator("body")).toContainText(/invalid credentials|login failed/i);
  });

  test("signup page opens correctly", async ({ page }) => {
    await page.goto(`${BASE_URL}/signup`);

    await expect(page).toHaveURL(/signup/);
    await expect(page.getByPlaceholder("Full Name")).toBeVisible();
    await expect(page.getByPlaceholder("University Major")).toBeVisible();
    await expect(page.getByPlaceholder("Phone Number")).toBeVisible();
    await expect(page.getByPlaceholder("Email")).toBeVisible();
    await expect(page.getByPlaceholder("Password")).toBeVisible();
    await expect(page.getByRole("button", { name: /create account/i })).toBeVisible();
  });

  test("signup validates full name", async ({ page }) => {
    await page.goto(`${BASE_URL}/signup`);

    await page.getByPlaceholder("Full Name").fill("Mohanad");
    await page.getByPlaceholder("University Major").fill("Software Engineering");
    await page.getByPlaceholder("Phone Number").fill("0791234567");
    await page.getByPlaceholder("Email").fill("test@example.com");
    await page.getByPlaceholder("Password").fill("12345678");

    await page.getByRole("button", { name: /create account/i }).click();

    await expect(page.locator("body")).toContainText(
      /full name must contain at least two parts/i
    );
  });

  test("signup validates phone number", async ({ page }) => {
    await page.goto(`${BASE_URL}/signup`);

    await page.getByPlaceholder("Full Name").fill("Mohanad Sawaie");
    await page.getByPlaceholder("University Major").fill("Software Engineering");
    await page.getByPlaceholder("Phone Number").fill("123");
    await page.getByPlaceholder("Email").fill("test@example.com");
    await page.getByPlaceholder("Password").fill("12345678");

    await page.getByRole("button", { name: /create account/i }).click();

    await expect(page.locator("body")).toContainText(/valid phone number/i);
  });

  test("admin route redirects unauthenticated user to login", async ({ page }) => {
    await page.goto(`${BASE_URL}/admin`);
    await expect(page).toHaveURL(/login/);
  });

  test("home route redirects unauthenticated user to login", async ({ page }) => {
    await page.goto(`${BASE_URL}/home`);
    await expect(page).toHaveURL(/login/);
  });

  test("dashboard route redirects unauthenticated user to login", async ({ page }) => {
    await page.goto(`${BASE_URL}/dashboard`);
    await expect(page).toHaveURL(/login/);
  });

  test("placement route redirects unauthenticated user to login", async ({ page }) => {
    await page.goto(`${BASE_URL}/placement-test`);
    await expect(page).toHaveURL(/login/);
  });

  test("learner can open placement page when logged in and no level", async ({ page }) => {
    await page.addInitScript(() => {
      sessionStorage.setItem(
        "user",
        JSON.stringify({
          id: 999999,
          name: "Test Learner",
          email: "learner@test.com",
          role: "user",
          level: null,
        })
      );
    });

    await page.route("**/user/999999", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({
          id: 999999,
          name: "Test Learner",
          email: "learner@test.com",
          role: "user",
          level: null,
          placement_score: null,
        }),
      });
    });

    await page.route("**/placement-test/questions", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify([
          {
            id: 1,
            question: "What does HTML stand for?",
            option_a: "Hyper Text Markup Language",
            option_b: "High Text Machine Language",
            option_c: "Hyper Tool Markup Language",
            option_d: "Home Tool Markup Language",
          },
          {
            id: 2,
            question: "Which language styles web pages?",
            option_a: "HTML",
            option_b: "CSS",
            option_c: "SQL",
            option_d: "C++",
          },
        ]),
      });
    });

    await page.goto(`${BASE_URL}/placement-test`);

    await expect(page.locator("body")).toContainText(/placement test/i);
    await expect(page.locator("body")).toContainText(/question 1 of 2/i);
  });

  test("placement test can select answers and submit", async ({ page }) => {
    await page.addInitScript(() => {
      sessionStorage.setItem(
        "user",
        JSON.stringify({
          id: 999998,
          name: "Test Learner",
          email: "learner2@test.com",
          role: "user",
          level: null,
        })
      );
    });

    await page.route("**/user/999998", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({
          id: 999998,
          name: "Test Learner",
          email: "learner2@test.com",
          role: "user",
          level: null,
          placement_score: null,
        }),
      });
    });

    await page.route("**/placement-test/questions", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify([
          {
            id: 1,
            question: "What does CSS do?",
            option_a: "Styles pages",
            option_b: "Stores data",
            option_c: "Runs servers",
            option_d: "Manages routes",
          },
        ]),
      });
    });

    await page.route("**/placement-test/submit", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({
          score: 80,
          level: "Advanced",
        }),
      });
    });

    await page.goto(`${BASE_URL}/placement-test`);

    await page.locator('input[type="radio"]').first().check();
    await page.getByRole("button", { name: /submit test/i }).click();

    await expect(page.locator("body")).toContainText(/your score/i);
    await expect(page.locator("body")).toContainText(/advanced/i);
  });
  test("topic quiz full flow: MCQ -> AI Quiz -> Coding -> Final Result", async ({ page }) => {
  await page.addInitScript(() => {
    sessionStorage.setItem(
      "user",
      JSON.stringify({
        id: 777777,
        name: "Quiz Test User",
        email: "quiz@test.com",
        role: "user",
        level: "Beginner",
        field: "Programming Fundamentals",
      })
    );
  });

  await page.route("**/topic/1/questions/777777", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify([
        {
          id: 101,
          question: "Which keyword declares a variable in JavaScript?",
          option_a: "var",
          option_b: "echo",
          option_c: "print",
          option_d: "select",
        },
        {
          id: 102,
          question: "Which symbol is used for strict equality?",
          option_a: "==",
          option_b: "===",
          option_c: "=",
          option_d: "!=",
        },
      ]),
    });
  });

  await page.route("**/ai/generate-quiz", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        source: "ai",
        questions: [
          {
            id: 201,
            question: "What is the output of console.log(2 + 3)?",
            option_a: "23",
            option_b: "5",
            option_c: "undefined",
            option_d: "error",
            question_type: "output_prediction",
          },
          {
            id: 202,
            question: "Which line fixes the syntax error?",
            option_a: "function test() {}",
            option_b: "function test( {}",
            option_c: "function = test",
            option_d: "test function()",
            question_type: "find_the_error",
          },
        ],
      }),
    });
  });

  await page.route("**/topic/submit-quiz", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        score: 80,
        passed: true,
        analysis: "Good MCQ performance.",
      }),
    });
  });

  await page.route("**/ai/submit-quiz", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        score: 90,
        passed: true,
        feedback: "Strong AI quiz performance.",
      }),
    });
  });

  await page.route("**/ai/generate-coding-question", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        title: "Add Two Numbers",
        description:
          "Write a function named addNumbers that takes two numbers and returns their sum.",
        language: "JavaScript",
        starter_code: "function addNumbers(a, b) {\n  // write your code here\n}",
        expected_output: "addNumbers(3, 5) should return 8",
        difficulty: "medium",
        field_name: "Programming Fundamentals",
      }),
    });
  });

  await page.route("**/ai/code-review", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        score: 95,
        errors: [],
        correctedCode: "function addNumbers(a, b) {\n  return a + b;\n}",
        explanation: "The function correctly returns the sum of two numbers.",
        feedback: "Excellent solution.",
      }),
    });
  });

  await page.goto(`${BASE_URL}/topic/1/quiz`);

  await expect(page.locator("body")).toContainText(/topic quiz/i);

  await page.getByText("var").click();
  await page.getByRole("button", { name: /next/i }).click();

  await page.getByText("===").click();
  await page.getByRole("button", { name: /go to ai quiz/i }).click();

  await expect(page.locator("body")).toContainText(/ai code quiz/i);

  await page.getByText("5").click();
  await page.getByRole("button", { name: /next/i }).click();

  await page.getByText("function test() {}").click();
  await page.getByRole("button", { name: /go to coding question/i }).click();

  await expect(page.locator("body")).toContainText(/coding challenge/i);
  await expect(page.locator("body")).toContainText(/add two numbers/i);

  await page.locator(".coding-textarea").fill(
    "function addNumbers(a, b) {\n  return a + b;\n}"
  );

  await page.getByRole("button", { name: /submit code/i }).click();

  await expect(page.locator("body")).toContainText(/ai code review/i);
  await expect(page.locator("body")).toContainText(/95%/);

  await page.getByRole("button", { name: /submit final/i }).click();

  await expect(page.locator("body")).toContainText(/quiz passed/i);
  await expect(page.locator("body")).toContainText(/final score/i);
  await expect(page.locator("body")).toContainText(/coding score/i);
});
});