require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { initializeDB } = require('./db');
const cropsRoutes = require('./routes/cropsRoutes');
const authRoutes = require('./routes/authRoutes');
const journalRoutes = require('./routes/journalRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const exportRoutes = require('./routes/exportRoutes');
const calendarRoutes = require('./routes/calendarRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

initializeDB();

app.get('/', (req, res) => {
  res.json({ 
    message: 'FarmKeeper offline SQLite API is running.',
    status: 'success' 
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/crops', cropsRoutes);
app.use('/api/journal', journalRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/export', exportRoutes);
app.use('/api/calendar', calendarRoutes);

// Start Server locally
app.listen(PORT, () => {
  console.log(`Server is running locally on http://localhost:${PORT}`);
});
