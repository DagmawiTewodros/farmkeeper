const crypto = require('crypto');
const { query } = require('../db');

const generateSalt = () => crypto.randomBytes(16).toString('hex');
const generateToken = () => crypto.randomBytes(32).toString('hex');

const hashPassword = (password, salt) => {
  return crypto.createHash('sha256').update(`${salt}${password}`).digest('hex');
};

const register = async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email and password are required.' });
    }

    const existing = await query('SELECT * FROM users WHERE email = $1', [email]);
    if (existing.rowCount > 0) {
      return res.status(409).json({ error: 'Email already registered.' });
    }

    const salt = generateSalt();
    const password_hash = hashPassword(password, salt);
    const token = generateToken();
    const assignedRole = role ?? 'farmer';

    const result = await query(
      `INSERT INTO users (name, email, password_hash, salt, token, role) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`, 
      [name, email, password_hash, salt, token, assignedRole],
    );

    const id = result.rows?.[0]?.id ?? result.lastID;
    res.status(201).json({
      user: { id, name, email, token, role: assignedRole },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required.' });
    }

    const result = await query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rowCount === 0) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const user = result.rows[0];
    const attemptHash = hashPassword(password, user.salt);
    if (attemptHash !== user.password_hash) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const token = generateToken();
    await query('UPDATE users SET token = $1 WHERE id = $2', [token, user.id]);

    res.json({
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        token,
        role: user.role ?? 'farmer',
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const me = async (req, res) => {
  const user = req.user;
  res.json({
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role ?? 'farmer',
      token: user.token,
    },
  });
};

module.exports = { register, login, me };
