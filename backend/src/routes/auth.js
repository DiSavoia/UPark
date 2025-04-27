const express = require('express');
const bcrypt  = require('bcrypt');
const pool    = require('../db');
const router  = express.Router();

// Register
router.post('/register', async (req, res) => {
  const { username, password, first_name, last_name, phone, email, is_manager } = req.body;
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
    res.status(500).json({ success: false, error: 'Server error' });
  }
});

// Login
router.post('/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const { rows } = await pool.query(`SELECT * FROM users WHERE username=$1`, [username]);
    if (!rows.length) return res.status(400).json({ success: false, error: 'Invalid credentials' });
    const user = rows[0];
    if (!await bcrypt.compare(password, user.password))
      return res.status(400).json({ success: false, error: 'Invalid credentials' });
    // Strip password before sending back
    delete user.password;
    res.json({ success: true, user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// Change password
router.post('/change-password', async (req, res) => {
  const { email, newPassword } = req.body;
  try {
    const hash = await bcrypt.hash(newPassword, 10);
    await pool.query(`UPDATE users SET password=$1 WHERE email=$2`, [hash, email]);
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

module.exports = router;
