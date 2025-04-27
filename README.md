# upark

Aplicación para conectar conductores y estacionamientos

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## PostgreSQL Setup for UPark Backend

This guide will help you set up PostgreSQL for the UPark backend from scratch.

### Prerequisites

1. [Install PostgreSQL](https://www.postgresql.org/download/) for your operating system
2. [Install Node.js](https://nodejs.org/) (version 14 or higher)

### Setup Steps

1. **Install PostgreSQL**

   - For Windows: Download and run the installer from the [PostgreSQL website](https://www.postgresql.org/download/windows/)
   - For macOS: `brew install postgresql` (using Homebrew)
   - For Linux: `sudo apt install postgresql postgresql-contrib` (Ubuntu/Debian)

2. **Create a local database**

   ```bash
   # Connect to PostgreSQL with the default postgres user
   psql -U postgres

   # Inside the PostgreSQL command line
   CREATE DATABASE upark;
   CREATE USER upark_user WITH ENCRYPTED PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE upark TO upark_user;
   \q
   ```

3. **Clone the repository and navigate to backend**

   ```bash
   git clone <repository-url>
   cd UPark/backend
   ```

4. **Install dependencies**

   ```bash
   npm install
   ```

5. **Create a .env file**
   Create a file named `.env` in the `backend` directory with the following content:

   ```
   DATABASE_URL=postgresql://upark_user:your_password@localhost:5432/upark
   PORT=3100
   ```

   Replace `your_password` with the password you set in step 2.

6. **Run migrations**

   ```bash
   npm run migrate
   ```

7. **Start the server**

   ```bash
   npm start
   ```

8. **Verify setup**
   - The server should start on http://localhost:3100
   - You should see a message: `🚀 Server running on http://localhost:3100`
   - Connect to your database to check if tables were created:
     ```bash
     psql -U upark_user -d upark
     # Then run:
     \dt
     ```
     You should see tables like `users` and `parkings`.

### Troubleshooting

- **Connection Refused**: Make sure PostgreSQL service is running on your system
- **Permission Denied**: Check if your username and password in DATABASE_URL are correct
- **Migration Failed**: Ensure PostgreSQL is installed correctly and your user has permission to create tables

### Database Schema

The current schema creates the following tables:

- `users`: For storing user information and authentication
- `parkings`: For storing parking lot information

For more details, check the migration file at `migrations/001_create_tables.sql`.
