const { query } = require('../db');

const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing auth token.' });
  }

  const token = authHeader.slice(7).trim();
  if (!token) {
    return res.status(401).json({ error: 'Invalid auth token.' });
  }

  try {
    const result = await query('SELECT * FROM users WHERE token = $1', [token]);
    if (!result || !result.rowCount || result.rowCount === 0) {
      return res.status(401).json({ error: 'Unauthorized.' });
    }

    req.user = result.rows[0];
    next();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = authMiddleware;
