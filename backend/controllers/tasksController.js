const { query } = require('../db');

const getTasks = async (req, res) => {
  try {
    const result = await query('SELECT * FROM tasks ORDER BY created_at DESC');
    res.json({ data: result.rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getTask = async (req, res) => {
  try {
    const result = await query('SELECT * FROM tasks WHERE id = $1', [req.params.id]);
    if (result.rowCount === 0) return res.status(404).json({ error: 'Task not found' });
    res.json({ data: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const createTask = async (req, res) => {
  try {
    const { title, description, due_date, priority, is_completed } = req.body;
    const result = await query(
      `INSERT INTO tasks (title, description, due_date, priority, is_completed)
       VALUES ($1, $2, $3, $4, $5)`,
      [title, description || '', due_date || null, priority || 'medium', is_completed ? 1 : 0]
    );

    res.status(201).json({
      id: result.lastID,
      message: 'Task created successfully',
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const updateTask = async (req, res) => {
  try {
    const { title, description, due_date, priority, is_completed } = req.body;
    const result = await query(
      `UPDATE tasks SET title = $1, description = $2, due_date = $3, priority = $4, is_completed = $5
       WHERE id = $6`,
      [title, description || '', due_date || null, priority || 'medium', is_completed ? 1 : 0, req.params.id]
    );

    if (result.changes === 0) return res.status(404).json({ error: 'Task not found' });
    res.json({ message: 'Task updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const deleteTask = async (req, res) => {
  try {
    const result = await query('DELETE FROM tasks WHERE id = $1', [req.params.id]);
    if (result.changes === 0) return res.status(404).json({ error: 'Task not found' });
    res.json({ message: 'Task deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = {
  getTasks,
  getTask,
  createTask,
  updateTask,
  deleteTask,
};
