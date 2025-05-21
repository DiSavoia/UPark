const express = require("express");
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const nodemailer = require("nodemailer");
const pool = require("../db");
const router = express.Router();

// Configure nodemailer with Gmail
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER, // your Gmail
    pass: process.env.EMAIL_PASS, // your Gmail password or App Password
  },
});

// Register
router.post("/register", async (req, res) => {
  const {
    username,
    password,
    first_name,
    last_name,
    phone,
    email,
    is_manager,
  } = req.body;
  try {
    const hash = await bcrypt.hash(password, 10);
    const { rows } = await pool.query(
      `INSERT INTO users
         (username,password,first_name,last_name,phone,email,is_manager)
       VALUES
         ($1,$2,$3,$4,$5,$6,$7)
       RETURNING id`,
      [username, hash, first_name, last_name, phone, email, is_manager]
    );
    res.json({ success: true, userId: rows[0].id });
  } catch (err) {
    console.error(err);

    // Handle duplicate email error specifically
    if (err.code === "23505" && err.constraint === "users_email_key") {
      return res.status(409).json({
        success: false,
        error:
          "Este correo electrónico ya está registrado. Por favor utilice otro.",
        errorCode: err.code,
      });
    }

    res.status(500).json({ success: false, error: "Server error" });
  }
});

// Login
router.post("/login", async (req, res) => {
  const { username, password } = req.body;
  try {
    const { rows } = await pool.query(`SELECT * FROM users WHERE username=$1`, [
      username,
    ]);
    if (!rows.length)
      return res
        .status(400)
        .json({ success: false, error: "Invalid credentials" });
    const user = rows[0];
    if (!(await bcrypt.compare(password, user.password)))
      return res
        .status(400)
        .json({ success: false, error: "Invalid credentials" });
    // Strip password before sending back
    delete user.password;
    res.json({ success: true, user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// Change password
router.post("/change-password", async (req, res) => {
  const { email, newPassword } = req.body;
  try {
    const hash = await bcrypt.hash(newPassword, 10);
    await pool.query(`UPDATE users SET password=$1 WHERE email=$2`, [
      hash,
      email,
    ]);
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// Request password reset with new password
router.post("/request-reset", async (req, res) => {
  const { email, newPassword, confirmPassword } = req.body;

  try {
    // Validate passwords match
    if (newPassword !== confirmPassword) {
      return res.status(400).json({
        success: false,
        error: "Passwords do not match",
      });
    }

    // Check if user exists
    const { rows } = await pool.query("SELECT id FROM users WHERE email = $1", [
      email,
    ]);

    if (!rows.length) {
      return res.status(404).json({
        success: false,
        error: "Email not found",
      });
    }

    // Generate a random token
    const token = crypto.randomBytes(32).toString("hex");
    const expires = new Date(Date.now() + 3600000); // 1 hour from now

    // Hash the new password and store with token
    const hash = await bcrypt.hash(newPassword, 10);

    // Save token and hashed new password in database
    await pool.query(
      `UPDATE users 
       SET reset_token = $1, 
           reset_token_expires = $2,
           reset_password_hash = $3
       WHERE email = $4`,
      [token, expires, hash, email]
    );

    // Create confirmation link
    const confirmLink = `http://localhost:3100/api/confirm-reset/${token}`;

    // Send email with confirmation button
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

// Confirm password reset with token
router.get("/confirm-reset/:token", async (req, res) => {
  const { token } = req.params;

  try {
    // Find user with valid token and new password hash
    const { rows } = await pool.query(
      `SELECT id, reset_password_hash 
       FROM users 
       WHERE reset_token = $1 
       AND reset_token_expires > NOW()`,
      [token]
    );

    if (!rows.length) {
      return res.status(400).send(`
        <div style="text-align: center; font-family: Arial, sans-serif;">
          <h2>Invalid or Expired Link</h2>
          <p>Please request a new password reset.</p>
        </div>
      `);
    }

    // Update user's password with the stored hash
    await pool.query(
      `UPDATE users 
       SET password = reset_password_hash,
           reset_token = NULL, 
           reset_token_expires = NULL,
           reset_password_hash = NULL 
       WHERE id = $1`,
      [rows[0].id]
    );

    // Send success HTML page
    res.send(`
      <div style="text-align: center; font-family: Arial, sans-serif;">
        <h2>Password Reset Successful!</h2>
        <p>Your password has been updated. You can now close this window and log in with your new password.</p>
      </div>
    `);
  } catch (err) {
    console.error(err);
    res.status(500).send(`
      <div style="text-align: center; font-family: Arial, sans-serif;">
        <h2>Error</h2>
        <p>An error occurred while resetting your password. Please try again.</p>
      </div>
    `);
  }
});

// Get all users HTML table
router.get("/users-table", async (req, res) => {
  try {
    const { rows } = await pool.query(`SELECT * FROM users`);

    let htmlTable = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>UPark Users</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        h1 { color: #333; }
      </style>
    </head>
    <body>
      <h1>UPark Users</h1>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Username</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Is Manager</th>
            <th>Created At</th>
          </tr>
        </thead>
        <tbody>`;

    rows.forEach((user) => {
      htmlTable += `
          <tr>
            <td>${user.id}</td>
            <td>${user.username}</td>
            <td>${user.first_name}</td>
            <td>${user.last_name}</td>
            <td>${user.email}</td>
            <td>${user.phone || ""}</td>
            <td>${user.is_manager ? "Yes" : "No"}</td>
            <td>${
              user.created_at ? new Date(user.created_at).toLocaleString() : ""
            }</td>
          </tr>`;
    });

    htmlTable += `
        </tbody>
      </table>
    </body>
    </html>`;

    res.send(htmlTable);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

module.exports = router;
