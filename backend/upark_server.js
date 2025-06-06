// upark_server.js
// Node.js + Express server for UPark CRUD operations with parameterized queries (SQL injection safety)

import express from "express";
import pkg from "pg";
import dotenv from "dotenv";
import bcrypt from "bcrypt";
import nodemailer from "nodemailer";
import crypto from "crypto";
// import authRoutes from "./routes/auth.js";

dotenv.config();
const { Pool } = pkg;

// Create a connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const app = express();
app.use(express.json()); // parse JSON bodies

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// Request logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on("finish", () => {
    const duration = Date.now() - start;
    console.log(`${req.method} ${req.path} ${res.statusCode} - ${duration}ms`);
  });
  next();
});

// Login endpoint
app.post("/api/login", async (req, res) => {
  const { username, password } = req.body;

  try {
    const result = await pool.query("SELECT * FROM users WHERE username = $1", [
      username,
    ]);

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: "Invalid username or password",
      });
    }

    const user = result.rows[0];
    const passwordMatch = await bcrypt.compare(password, user.password_hash);

    if (!passwordMatch) {
      return res.status(401).json({
        success: false,
        error: "Invalid username or password",
      });
    }

    res.json({
      success: true,
      data: user,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: "Internal server error",
    });
  }
});

// -- USERS CRUD --

// Get all users
app.get("/api/users", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM users");
    res.json({ success: true, data: result.rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

// Get user by ID
app.get("/api/users/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query("SELECT * FROM users WHERE id = $1", [id]);
    if (result.rows.length === 0)
      return res.status(404).json({ success: false, error: "User not found" });
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

// Create new user
app.post("/api/users", async (req, res) => {
  const {
    username,
    password_hash,
    first_name,
    last_name,
    phone,
    email,
    is_manager,
  } = req.body;
  const query = `
    INSERT INTO users
      (username, password_hash, first_name, last_name, phone, email, is_manager)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING *
  `;
  const values = [
    username,
    password_hash,
    first_name,
    last_name,
    phone,
    email,
    is_manager,
  ];
  try {
    const result = await pool.query(query, values);
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (err) {
    console.error(err);
    if (err.code === "23505") {
      // unique_violation
      res
        .status(400)
        .json({ success: false, error: "Username or email already exists" });
    } else {
      res.status(500).json({ success: false, error: "Internal server error" });
    }
  }
});

// Update user
app.put("/api/users/:id", async (req, res) => {
  const { id } = req.params;
  const { first_name, last_name, phone, email, is_manager } = req.body;
  const query = `
    UPDATE users SET
      first_name = $1,
      last_name = $2,
      phone = $3,
      email = $4,
      is_manager = $5,
      updated_at = now()
    WHERE id = $6
    RETURNING *
  `;
  const values = [first_name, last_name, phone, email, is_manager, id];
  try {
    const result = await pool.query(query, values);
    if (result.rows.length === 0)
      return res.status(404).json({ success: false, error: "User not found" });
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

// Delete user
app.delete("/api/users/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      "DELETE FROM users WHERE id = $1 RETURNING *",
      [id]
    );
    if (result.rows.length === 0)
      return res.status(404).json({ success: false, error: "User not found" });
    res.json({ success: true, message: "User deleted" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

// -- PARKINGS CRUD --

app.get("/api/parkings", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM parkings");
    res.json({ success: true, data: result.rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

app.get("/api/parkings/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query("SELECT * FROM parkings WHERE id = $1", [
      id,
    ]);
    if (result.rows.length === 0)
      return res
        .status(404)
        .json({ success: false, error: "Parking not found" });
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

app.post("/api/parkings", async (req, res) => {
  const {
    manager_id,
    name,
    description,
    address,
    latitude,
    longitude,
    total_spaces,
    hourly_rate,
    is_active,
  } = req.body;
  const query = `
    INSERT INTO parkings
      (manager_id, name, description, address, latitude, longitude, total_spaces, hourly_rate, is_active)
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
    RETURNING *
  `;
  const values = [
    manager_id,
    name,
    description,
    address,
    latitude,
    longitude,
    total_spaces,
    hourly_rate,
    is_active ?? true,
  ];
  try {
    const result = await pool.query(query, values);
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

app.put("/api/parkings/:id", async (req, res) => {
  const { id } = req.params;
  const {
    name,
    description,
    address,
    latitude,
    longitude,
    total_spaces,
    hourly_rate,
    is_active,
  } = req.body;
  const query = `
    UPDATE parkings SET
      name = $1,
      description = $2,
      address = $3,
      latitude = $4,
      longitude = $5,
      total_spaces = $6,
      hourly_rate = $7,
      is_active = $8,
      updated_at = now()
    WHERE id = $9
    RETURNING *
  `;
  const values = [
    name,
    description,
    address,
    latitude,
    longitude,
    total_spaces,
    hourly_rate,
    is_active,
    id,
  ];
  try {
    const result = await pool.query(query, values);
    if (result.rows.length === 0)
      return res
        .status(404)
        .json({ success: false, error: "Parking not found" });
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

app.delete("/api/parkings/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      "DELETE FROM parkings WHERE id = $1 RETURNING *",
      [id]
    );
    if (result.rows.length === 0)
      return res
        .status(404)
        .json({ success: false, error: "Parking not found" });
    res.json({ success: true, message: "Parking deleted" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

// -- REVIEWS CRUD --

app.get("/api/reviews", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM review");
    res.json({ success: true, data: result.rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

app.get("/api/reviews/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query("SELECT * FROM review WHERE id = $1", [id]);
    if (result.rows.length === 0)
      return res
        .status(404)
        .json({ success: false, error: "Review not found" });
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

app.post("/api/reviews", async (req, res) => {
  const { user_id, parking_id, rating, comment } = req.body;
  const query = `
    INSERT INTO review
      (user_id, parking_id, rating, comment)
    VALUES ($1,$2,$3,$4)
    RETURNING *
  `;
  const values = [user_id, parking_id, rating, comment];
  try {
    const result = await pool.query(query, values);
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

app.put("/api/reviews/:id", async (req, res) => {
  const { id } = req.params;
  const { rating, comment } = req.body;
  const query = `
    UPDATE review SET
      rating = $1,
      comment = $2,
      created_at = now()
    WHERE id = $3
    RETURNING *
  `;
  const values = [rating, comment, id];
  try {
    const result = await pool.query(query, values);
    if (result.rows.length === 0)
      return res
        .status(404)
        .json({ success: false, error: "Review not found" });
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

app.delete("/api/reviews/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      "DELETE FROM review WHERE id = $1 RETURNING *",
      [id]
    );
    if (result.rows.length === 0)
      return res
        .status(404)
        .json({ success: false, error: "Review not found" });
    res.json({ success: true, message: "Review deleted" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

// Password change endpoint
app.post("/api/change-password", async (req, res) => {
  const { email, newPassword } = req.body;
  try {
    const hash = await bcrypt.hash(newPassword, 10);
    const result = await pool.query(
      "UPDATE users SET password_hash = $1 WHERE email = $2 RETURNING *",
      [hash, email]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "User not found",
      });
    }
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

// Request password reset endpoint
app.post("/api/request-reset", async (req, res) => {
  const { email, newPassword, confirmPassword } = req.body;

  try {
    if (newPassword !== confirmPassword) {
      return res.status(400).json({
        success: false,
        error: "Passwords do not match",
      });
    }

    const { rows } = await pool.query("SELECT id FROM users WHERE email = $1", [
      email,
    ]);

    if (!rows.length) {
      return res.status(404).json({
        success: false,
        error: "Email not found",
      });
    }

    const token = crypto.randomBytes(32).toString("hex");
    const expires = new Date(Date.now() + 3600000);
    const hash = await bcrypt.hash(newPassword, 10);

    await pool.query(
      `UPDATE users 
       SET reset_token = $1, 
           reset_token_expires = $2,
           reset_password_hash = $3
       WHERE email = $4`,
      [token, expires, hash, email]
    );

    const confirmLink = `http://18.218.68.253/api/confirm-reset/${token}`;

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: "Confirm Your UPark Password Reset",
      html: `
        <div style="text-align: center; font-family: Arial, sans-serif;">
          <h2>UPark Password Reset</h2>
          <p>Click the button below to confirm your password reset:</p>
          <a href="${confirmLink}" 
             style="background-color: #4CAF50; 
                    color: white; 
                    padding: 14px 20px; 
                    margin: 8px 0; 
                    border: none; 
                    cursor: pointer; 
                    text-decoration: none; 
                    display: inline-block;">
            Confirm Password Reset
          </a>
          <p>If you didn't request this change, please ignore this email.</p>
          <p>This link will expire in 1 hour.</p>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);

    res.json({
      success: true,
      message: "Please check your email to confirm the password reset",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: "Server error while requesting password reset",
    });
  }
});

// Confirm password reset endpoint
app.get("/api/confirm-reset/:token", async (req, res) => {
  const { token } = req.params;
  console.log("Received token:", token);

  try {
    const { rows } = await pool.query(
      `SELECT id, email, reset_password_hash, password_hash
       FROM users 
       WHERE reset_token = $1 
       AND reset_token_expires > NOW()`,
      [token]
    );

    console.log("Query result:", rows);

    if (!rows.length) {
      console.log("Invalid or expired token:", token);
      return res.status(400).send(`
        <div style="text-align: center; font-family: Arial, sans-serif;">
          <h2>Invalid or Expired Link</h2>
          <p>Please request a new password reset.</p>
        </div>
      `);
    }

    console.log("Found user for token:", rows[0].email);
    console.log("Current password_hash:", rows[0].password_hash);
    console.log("New reset_password_hash:", rows[0].reset_password_hash);

    if (!rows[0].reset_password_hash) {
      console.log("No reset_password_hash found for user:", rows[0].email);
      throw new Error("No reset password hash found");
    }

    const updateResult = await pool.query(
      `UPDATE users 
       SET password_hash = $1,
           reset_token = NULL, 
           reset_token_expires = NULL,
           reset_password_hash = NULL 
       WHERE id = $2
       RETURNING id, email, password_hash`,
      [rows[0].reset_password_hash, rows[0].id]
    );

    console.log("Update result:", updateResult.rows);

    if (updateResult.rows.length === 0) {
      console.log("Failed to update password for user:", rows[0].email);
      throw new Error("Failed to update password");
    }

    console.log(
      "Successfully updated password for user:",
      updateResult.rows[0].email
    );
    console.log(
      "New password_hash after update:",
      updateResult.rows[0].password_hash
    );

    res.send(`
      <div style="text-align: center; font-family: Arial, sans-serif;">
        <h2>Password Reset Successful!</h2>
        <p>Your password has been updated. You can now close this window and log in with your new password.</p>
      </div>
    `);
  } catch (err) {
    console.error("Error in confirm-reset:", err);
    res.status(500).send(`
      <div style="text-align: center; font-family: Arial, sans-serif;">
        <h2>Error</h2>
        <p>An error occurred while resetting your password. Please try again.</p>
      </div>
    `);
  }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`UPark API server listening on port ${PORT}`);
});
