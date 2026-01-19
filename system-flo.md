# System Flow Overview

This document explains the overall flow of the Cognito system, describing how the frontend, backend, and database interact together from user registration to dashboard usage.

---

## 1. User Registration & Login Flow

1. The user accesses the frontend web application.
2. The frontend sends a POST request to the backend API for signup or login.
3. The backend validates user data and communicates with the PostgreSQL database.
4. Upon successful authentication, the backend returns the user information to the frontend.
5. The frontend stores the user session and redirects the user to the next step.

---

## 2. Placement Test Flow

1. After login, the user starts the placement test.
2. The frontend requests questions from the backend using:
   GET /placement-test/questions
3. The backend retrieves random questions from the database.
4. The frontend displays the questions to the user.
5. The user submits answers.
6. The frontend sends the answers to the backend using:
   POST /placement-test/submit
7. The backend:
   - Validates the submission
   - Calculates the score
   - Determines the user level (Beginner / Intermediate / Advanced)
   - Saves the result in the database
8. The backend returns the score and level to the frontend.

---

## 3. Path Selection Flow

1. After completing the placement test, the user selects a learning Path.
2. The frontend sends the selected Path to the backend.
3. The backend stores the selected Path in the database.
4. The user is redirected to the dashboard.

---

## 4. Dashboard Data Flow

1. The frontend requests user data using:
   GET /user/:id
2. The backend retrieves the user profile, level, and progress from the database.
3. The frontend displays the data in the dashboard interface.

---

## 5. Technology Interaction Summary

- Frontend communicates with Backend using RESTful APIs.
- Backend handles business logic and database access.
- PostgreSQL stores user data, questions, scores, and selected paths.
- The system follows a client-server architecture with clear separation of responsibilities.


