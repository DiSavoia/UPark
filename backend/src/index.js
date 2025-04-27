require('dotenv').config();
const express       = require('express');
const cors          = require('cors');

const authRoutes    = require('./routes/auth');
const parkingRoutes = require('./routes/parking');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api', authRoutes);
app.use('/api', parkingRoutes);

const PORT = process.env.PORT || 3200;
app.listen(PORT, () => console.log(`🚀 Server running on http://localhost:${PORT}`));
