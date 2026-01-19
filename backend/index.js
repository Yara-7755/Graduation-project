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
  password: "Yamin@94",
  port: 5432,
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
app.get("/user/:id/paths", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      "SELECT path_name FROM user_paths WHERE user_id = $1 ORDER BY selected_at",
      [id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to fetch paths" });
  }
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
app.post("/user/path", async (req, res) => {
  try {
    const { userId, pathName } = req.body;

    if (!userId || !pathName) {
      return res.status(400).json({ message: "Missing data" });
    }

    // prevent duplicate path selection
    const exists = await pool.query(
      "SELECT 1 FROM user_paths WHERE user_id = $1 AND path_name = $2",
      [userId, pathName]
    );

    if (exists.rows.length > 0) {
      return res.status(409).json({ message: "Path already selected" });
    }

    await pool.query(
      "INSERT INTO user_paths (user_id, path_name) VALUES ($1, $2)",
      [userId, pathName]
    );

    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to save path" });
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
// ================== DELETE USER PATHS ==================
app.delete("/user/paths", async (req, res) => {
  try {
    const { userId, paths } = req.body;

    if (!userId || !paths || paths.length === 0) {
      return res.status(400).json({ message: "Invalid request data" });
    }

    await pool.query(
      `
      DELETE FROM user_paths
      WHERE user_id = $1
      AND path_name = ANY($2)
      `,
      [userId, paths]
    );

    res.status(200).json({ message: "Paths deleted successfully" });
  } catch (err) {
    console.error("DELETE PATHS ERROR:", err);
    res.status(500).json({ message: "Failed to delete paths" });
  }
});

// ================== START ==================
app.listen(PORT, async () => {
  await pool.query("SELECT 1");
  console.log(`Server running on http://localhost:${PORT}`);
});
