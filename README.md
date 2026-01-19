## Cognito – Backend Module

This module represents the backend implementation of the Cognito system.
It is responsible for handling API requests, user authentication, placement test logic,
and database communication.

### Implemented Features
- User signup and login
- Placement test question retrieval
- Placement test submission and score calculation
- User level and field storage
- User data retrieval for dashboard display

### Technologies Used
- Node.js
- Express.js
- PostgreSQL
- RESTful APIs

### Project Structure
- index.js: Main server entry point
- package.json: Project dependencies and scripts

### Environment Variables
This module requires an `.env` file with the following variables:

```env
PORT=5001
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=cognito
