const express = require('express');
const pool    = require('../db');
const router  = express.Router();

// List all parkings
router.get('/parkings', async (req, res) => {
  try {
    const { rows } = await pool.query(`SELECT * FROM parkings`);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json([]);
  }
});

module.exports = router;
