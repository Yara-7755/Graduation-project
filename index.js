// ================== IMPORTS ==================
import express from "express";
import cors from "cors";
import pkg from "pg";
import dotenv from "dotenv";

dotenv.config();
const { Pool } = pkg;

// ================== DB ==================
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "cognito",
  password: "2003",
  port: 5433,
});

// ================== APP ==================
const app = express();
const PORT = 5001;

app.use(cors());
app.use(express.json());

// ================== HELPERS ==================
function calcLevel(score) {
  if (score >= 70) return "Advanced";
  if (score >= 40) return "Intermediate";
  return "Beginner";
}

// ================== TEST ==================
app.get("/", (req, res) => {
  res.json({ ok: true });
});

// ================== SIGNUP ==================
app.post("/signup", async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const exists = await pool.query(
      "SELECT id FROM users WHERE email = $1",
      [email]
    );

    if (exists.rows.length > 0) {
      return res.status(400).json({ message: "Email already exists" });
    }

    const result = await pool.query(
      `INSERT INTO users (name, email, password)
       VALUES ($1, $2, $3)
       RETURNING id, name, email`,
      [name, email, password]
    );

    res.status(201).json({
      message: "Signup successful",
      user: result.rows[0],
    });
  } catch (err) {
    console.error("SIGNUP ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// ================== LOGIN ==================
app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const result = await pool.query(
      "SELECT id, name, email FROM users WHERE email=$1 AND password=$2",
      [email, password]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    res.json({ user: result.rows[0] });
  } catch (err) {
    console.error("LOGIN ERROR:", err);
    res.status(500).json({ message: "Login failed" });
  }
});

// ================== SAVE USER FIELD ==================
app.post("/user/field", async (req, res) => {
  try {
    const { userId, field } = req.body;

    if (!userId || !field) {
      return res.status(400).json({ message: "Missing data" });
    }

    await pool.query(
      "UPDATE users SET field = $1 WHERE id = $2",
      [field, userId]
    );

    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to save field" });
  }
});

// ================== PLACEMENT TEST ==================

// ✅ GET QUESTIONS
app.get("/placement-test/questions", async (req, res) => {
  try {
    const count = Math.min(Number(req.query.count || 20), 50);

    const result = await pool.query(`
      SELECT id, question, option_a, option_b, option_c, option_d
      FROM questions
      WHERE type = 'general'
      ORDER BY RANDOM()
      LIMIT $1
    `, [count]);

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to load questions" });
  }
});

// ================== SUBMIT PLACEMENT TEST (PROTECTED) ==================
app.post("/placement-test/submit", async (req, res) => {
  try {
    const { userId, answers } = req.body;

    if (!userId || !answers || answers.length === 0) {
      return res.status(400).json({ message: "Invalid submission data" });
    }

    // 🔐 1️⃣ CHECK IF USER ALREADY COMPLETED TEST
    const userCheck = await pool.query(
      "SELECT level FROM users WHERE id = $1",
      [userId]
    );

    if (userCheck.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    if (userCheck.rows[0].level !== null) {
      return res.status(403).json({
        message: "Placement test already completed",
      });
    }

    // 2️⃣ CALCULATE SCORE
    const ids = answers.map(a => a.questionId);

    const db = await pool.query(
      "SELECT id, correct_option FROM questions WHERE id = ANY($1::int[])",
      [ids]
    );

    let correct = 0;
    db.rows.forEach(q => {
      const userAnswer = answers.find(a => a.questionId === q.id);
      if (userAnswer && userAnswer.answer === q.correct_option) {
        correct++;
      }
    });

    const score = Math.round((correct / answers.length) * 100);
    const level = calcLevel(score);

    // 3️⃣ SAVE RESULT
    await pool.query(
      "UPDATE users SET level=$1, placement_score=$2 WHERE id=$3",
      [level, score, userId]
    );

    res.json({ score, level });
  } catch (err) {
    console.error("SUBMIT TEST ERROR:", err);
    res.status(500).json({ message: "Submit failed" });
  }
});

// ================== GET USER DATA ==================
app.get("/user/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `
      SELECT id, name, email, field, level, placement_score
      FROM users
      WHERE id = $1
      `,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error("GET USER ERROR:", err);
    res.status(500).json({ message: "Failed to load user data" });
  }
});

// ================== START ==================
app.listen(PORT, async () => {
  await pool.query("SELECT 1");
  console.log(`Server running on http://localhost:${PORT}`);
});
