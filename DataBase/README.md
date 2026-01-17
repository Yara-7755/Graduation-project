## Cognito – Database Module

This folder contains the database schema and SQL scripts used by the Cognito system.
The database supports user management, placement tests, and learning progress tracking.

### Database Technology
- PostgreSQL

### Files Description
- schema.sql:
  Contains the database schema definitions, including tables, constraints, and relationships.

- cognito_full_db.sql:
  Contains the full database setup including schema and sample data for testing and development purposes.

### Main Tables
- users:
  Stores user account information, selected field, placement score, and learning level.

- questions:
  Stores placement test questions and answer options.

- user_answers:
  Stores user responses to placement test questions.

### How to Setup the Database
1. Create a PostgreSQL database:
```sql
CREATE DATABASE cognito;
