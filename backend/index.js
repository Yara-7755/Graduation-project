import express from "express";
import cors from "cors";
import pkg from "pg";
import dotenv from "dotenv";
import { OAuth2Client } from "google-auth-library";
import { analyzeQuizPerformance } from "./services/analysisService.js";
import { generateCodeQuiz } from "./services/quizGenerationService.js";
import { callAI } from "./services/aiService.js";

dotenv.config();

const { Pool } = pkg;

// ================== DB ==================
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: Number(process.env.DB_PORT),
});

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// ================== APP ==================
const app = express();
const PORT = process.env.PORT || 5001;

app.use(cors());
app.use(express.json());

// ================== HELPERS ==================
function buildChatbotFallbackReply(message, userContext) {
  const text = String(message || "").toLowerCase();

  if (text.includes("frontend") && text.includes("backend")) {
    return `Frontend focuses on user interfaces and what users see and interact with. Backend focuses on APIs, server logic, databases, and system functionality behind the scenes.

Choose Frontend if you enjoy design and interaction.
Choose Backend if you enjoy logic, systems, and building core functionality.`;
  }

  if (
    text.includes("recommend") ||
    text.includes("choose") ||
    text.includes("field")
  ) {
    return `Here is a quick guide for choosing a path:

Frontend Development: best for visual interfaces and interaction.
Backend Development: best for system logic, APIs, and data flow.
Programming Fundamentals: best if you want stronger coding basics first.
Mobile Development: best for building apps for phones and tablets.
Databases: best for structured data and SQL.
Cyber Security: best for protection and secure systems.
UI/UX Design: best for design and user experience.
Cloud Computing: best for deployment and scalable infrastructure.

Current user level: ${userContext?.level || "Not determined yet"}
Current selected field: ${userContext?.field || "Not selected yet"}`;
  }

  if (text.includes("next") || text.includes("learn")) {
    return `A good next step in Cognito is:
1. Complete the placement test
2. Review your level
3. Explore the available paths
4. Choose the most suitable field
5. Continue through your roadmap topic by topic

Your current level is: ${userContext?.level || "Not determined yet"}`;
  }

  if (text.includes("path") || text.includes("available")) {
    return `Cognito currently includes these paths:
Frontend Development, Backend Development, Databases, Programming Fundamentals, Cyber Security, Mobile Development, UI/UX Design, and Cloud Computing.

You can ask me to compare any two of them.`;
  }

  return `I’m having trouble reaching the live AI service right now, but I can still help you with built-in guidance about:
- available paths
- Frontend vs Backend
- what to learn next
- how to choose your field`;
}

function normalizeText(value) {
  return String(value || "")
    .replace(/\s+/g, " ")
    .trim()
    .toLowerCase();
}

function parsePositiveInt(value) {
  const n = Number(value);
  return Number.isInteger(n) && n > 0 ? n : null;
}

function getWeakAreasFromHistory(historyRows) {
  const wrongOnly = historyRows.filter((row) => row.was_correct === false);
  const counts = {};

  for (const row of wrongOnly) {
    const tag = row.weakness_tag || "general";
    counts[tag] = (counts[tag] || 0) + 1;
  }

  return Object.entries(counts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 3)
    .map(([tag]) => tag);
}

function getDifficultyStep(level, wrongHistoryCount) {
  if (level === "Beginner") {
    if (wrongHistoryCount >= 6) return 1;
    if (wrongHistoryCount >= 3) return 2;
    return 3;
  }

  if (level === "Intermediate") {
    if (wrongHistoryCount >= 6) return 1;
    if (wrongHistoryCount >= 3) return 2;
    return 3;
  }

  if (wrongHistoryCount >= 6) return 1;
  if (wrongHistoryCount >= 3) return 2;
  return 3;
}

function calcLevel(score) {
  if (score >= 70) return "Advanced";
  if (score >= 40) return "Intermediate";
  return "Beginner";
}

function isValidFullName(name) {
  if (!name) return false;
  const parts = name.trim().split(/\s+/);
  return parts.length >= 2;
}

function isValidPhone(phone) {
  if (!phone) return false;
  return /^[0-9+\-\s]{8,20}$/.test(phone.trim());
}

function getRequestUserRole(req) {
  return String(req.headers["x-user-role"] || "").trim().toLowerCase();
}

function getRequestUserId(req) {
  const raw = req.headers["x-user-id"];
  const n = Number(raw);
  return Number.isInteger(n) ? n : null;
}

function requireAdmin(req, res, next) {
  const role = getRequestUserRole(req);

  if (role !== "admin") {
    return res.status(403).json({ message: "Access denied. Admins only." });
  }

  next();
}

const allowedPaths = [
  "Frontend Development",
  "Backend Development",
  "Databases",
  "Programming Fundamentals",
  "Cyber Security",
  "Mobile Development",
  "Cloud Computing",
  "UI/UX Design",
];

const fullCodeSupportFields = [
  "Frontend Development",
  "Backend Development",
  "Programming Fundamentals",
  "Mobile Development",
];

function supportsCodeQuiz(fieldName) {
  if (!fieldName) return false;
  return fullCodeSupportFields.includes(fieldName);
}

async function ensureFirstTopicUnlockedForRoadmap(client, userId, roadmapId) {
  const firstTopicResult = await client.query(
    `
    SELECT id
    FROM roadmap_topics
    WHERE roadmap_id = $1 AND is_active = true
    ORDER BY topic_order ASC
    LIMIT 1
    `,
    [roadmapId]
  );

  if (firstTopicResult.rows.length === 0) return;

  const firstTopicId = firstTopicResult.rows[0].id;

  await client.query(
    `
    INSERT INTO user_topic_progress (user_id, topic_id, status, score, completed_at)
    VALUES ($1, $2, 'unlocked', 0, NULL)
    ON CONFLICT (user_id, topic_id)
    DO UPDATE SET status = CASE
      WHEN user_topic_progress.status = 'completed' THEN 'completed'
      ELSE 'unlocked'
    END
    `,
    [userId, firstTopicId]
  );
}

async function getTopicAccessStatus(client, userId, topicId) {
  const topicResult = await client.query(
    `
    SELECT id, roadmap_id, topic_order, is_active
    FROM roadmap_topics
    WHERE id = $1
    LIMIT 1
    `,
    [topicId]
  );

  if (topicResult.rows.length === 0) {
    return { found: false, status: "locked" };
  }

  const topic = topicResult.rows[0];

  if (!topic.is_active) {
    return { found: true, status: "locked", topic };
  }

  const progressResult = await client.query(
    `
    SELECT status, score, completed_at
    FROM user_topic_progress
    WHERE user_id = $1 AND topic_id = $2
    LIMIT 1
    `,
    [userId, topicId]
  );

  if (progressResult.rows.length > 0) {
    return {
      found: true,
      status: progressResult.rows[0].status,
      topic,
      progress: progressResult.rows[0],
    };
  }

  if (Number(topic.topic_order) === 1) {
    return { found: true, status: "unlocked", topic };
  }

  const previousTopicResult = await client.query(
    `
    SELECT id
    FROM roadmap_topics
    WHERE roadmap_id = $1
      AND topic_order = $2
      AND is_active = true
    LIMIT 1
    `,
    [topic.roadmap_id, Number(topic.topic_order) - 1]
  );

  if (previousTopicResult.rows.length === 0) {
    return { found: true, status: "locked", topic };
  }

  const previousTopicId = previousTopicResult.rows[0].id;

  const previousProgressResult = await client.query(
    `
    SELECT status
    FROM user_topic_progress
    WHERE user_id = $1 AND topic_id = $2
    LIMIT 1
    `,
    [userId, previousTopicId]
  );

  const previousCompleted =
    previousProgressResult.rows.length > 0 &&
    previousProgressResult.rows[0].status === "completed";

  return {
    found: true,
    status: previousCompleted ? "unlocked" : "locked",
    topic,
  };
}

async function getRoadmapTopicsWithStatus(client, roadmapId, userId) {
  const topicsResult = await client.query(
    `
    SELECT 
      rt.id,
      rt.title,
      rt.description,
      rt.topic_order,
      rt.is_active,
      COALESCE(utp.status, NULL) AS saved_status,
      COALESCE(utp.score, 0) AS score,
      utp.completed_at
    FROM roadmap_topics rt
    LEFT JOIN user_topic_progress utp
      ON rt.id = utp.topic_id AND utp.user_id = $2
    WHERE rt.roadmap_id = $1
      AND rt.is_active = true
    ORDER BY rt.topic_order ASC
    `,
    [roadmapId, userId]
  );

  const topics = topicsResult.rows.map((row) => ({ ...row }));

  for (let i = 0; i < topics.length; i++) {
    const current = topics[i];

    if (current.saved_status === "completed") {
      current.status = "completed";
      continue;
    }

    if (current.saved_status === "unlocked") {
      current.status = "unlocked";
      continue;
    }

    if (i === 0) {
      current.status = "unlocked";
    } else {
      const previous = topics[i - 1];
      current.status = previous.status === "completed" ? "unlocked" : "locked";
    }
  }

  return topics.map(({ saved_status, ...topic }) => topic);
}

async function getTopicTitleAndLevel(client, topicId) {
  const result = await client.query(
    `
    SELECT rt.id, rt.title, r.level, r.field_name
    FROM roadmap_topics rt
    JOIN roadmaps r ON rt.roadmap_id = r.id
    WHERE rt.id = $1
    LIMIT 1
    `,
    [topicId]
  );

  if (result.rows.length === 0) return null;
  return result.rows[0];
}

async function getTopicDbQuestions(client, topicId, limit = 10) {
  const result = await client.query(
    `
    SELECT id, question, option_a, option_b, option_c, option_d
    FROM questions
    WHERE topic_id = $1
      AND quiz_type = 'topic'
    ORDER BY RANDOM()
    LIMIT $2
    `,
    [topicId, limit]
  );

  return result.rows;
}

async function getUserRoleFromDb(userId) {
  if (!userId) return "user";

  try {
    const result = await pool.query(
      `
      SELECT role
      FROM users
      WHERE id = $1
      LIMIT 1
      `,
      [userId]
    );

    return result.rows[0]?.role || "user";
  } catch {
    return "user";
  }
}

// ================== TEST ==================
app.get("/", (req, res) => {
  res.json({ ok: true, message: "Cognito backend is running" });
});

app.get("/debug-server", (req, res) => {
  res.json({ ok: true, message: "ACTIVE BACKEND FILE WORKING" });
});

// ================== GET USER PATHS ==================
app.get("/user/:id/paths", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `
      SELECT path_name
      FROM user_paths
      WHERE user_id = $1
      ORDER BY selected_at ASC, id ASC
      `,
      [id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error("GET USER PATHS ERROR:", err);
    res.status(500).json({ message: "Failed to fetch paths" });
  }
});

// ================== SIGNUP ==================
app.post("/signup", async (req, res) => {
  try {
    const {
      name,
      email,
      password,
      phone,
      universityMajor,
      accountType,
      adminCode,
    } = req.body;

    if (!name || !email || !password || !phone || !universityMajor) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    if (!isValidFullName(name)) {
      return res.status(400).json({
        message: "Full name must contain at least two parts",
      });
    }

    if (!isValidPhone(phone)) {
      return res.status(400).json({
        message: "Invalid phone number",
      });
    }

    const exists = await pool.query("SELECT id FROM users WHERE email = $1", [
      email,
    ]);

    if (exists.rows.length > 0) {
      return res.status(400).json({ message: "Email already exists" });
    }

    // ✅ تحديد الرول
    let role = "user";

    if (accountType === "admin") {
      if (adminCode !== process.env.ADMIN_SECRET_CODE) {
        return res.status(403).json({ message: "Invalid admin code" });
      }
      role = "admin";
    }

    const result = await pool.query(
      `INSERT INTO users (name, email, password, phone, university_major, auth_provider, role)
       VALUES ($1, $2, $3, $4, $5, 'local', $6)
       RETURNING id, name, email, phone, university_major, field, level, placement_score, google_id, auth_provider, avatar_url, role`,
      [name, email, password, phone, universityMajor, role]
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
      `SELECT id, name, email, phone, university_major, field, level, placement_score, google_id, auth_provider, avatar_url, role
       FROM users
       WHERE email = $1 AND password = $2`,
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

// ================== GOOGLE AUTH ==================
app.post("/auth/google", async (req, res) => {
  try {
    const { credential } = req.body;

    if (!credential) {
      return res.status(400).json({ message: "Missing Google credential" });
    }

    const ticket = await googleClient.verifyIdToken({
      idToken: credential,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();

    if (!payload) {
      return res.status(401).json({ message: "Invalid Google token" });
    }

    const { sub, email, name, picture, email_verified } = payload;

    if (!email || !email_verified) {
      return res.status(400).json({
        message: "Google account email is not verified",
      });
    }

    let result = await pool.query(
      `SELECT id, name, email, phone, university_major, field, level, placement_score, google_id, auth_provider, avatar_url, role
       FROM users
       WHERE google_id = $1`,
      [sub]
    );

    if (result.rows.length === 0) {
      result = await pool.query(
        `SELECT id, name, email, phone, university_major, field, level, placement_score, google_id, auth_provider, avatar_url, role
         FROM users
         WHERE email = $1`,
        [email]
      );
    }

    let user;

    if (result.rows.length > 0) {
      const existingUser = result.rows[0];

      const updated = await pool.query(
        `UPDATE users
         SET google_id = COALESCE(google_id, $1),
             auth_provider = 'google',
             avatar_url = COALESCE($2, avatar_url),
             name = COALESCE(name, $3)
         WHERE id = $4
         RETURNING id, name, email, phone, university_major, field, level, placement_score, google_id, auth_provider, avatar_url, role`,
        [sub, picture || null, name || "Google User", existingUser.id]
      );

      user = updated.rows[0];
    } else {
      const inserted = await pool.query(
        `INSERT INTO users (name, email, password, google_id, auth_provider, avatar_url, role)
         VALUES ($1, $2, $3, $4, 'google', $5, 'user')
         RETURNING id, name, email, phone, university_major, field, level, placement_score, google_id, auth_provider, avatar_url, role`,
        [name || "Google User", email, "GOOGLE_AUTH", sub, picture || null]
      );

      user = inserted.rows[0];
    }

    res.json({
      message: "Google authentication successful",
      user,
    });
  } catch (err) {
    console.error("GOOGLE AUTH ERROR:", err);
    res.status(500).json({ message: "Google authentication failed" });
  }
});

// ================== SAVE USER PATH + INIT ROADMAP ==================
app.post("/user/path", async (req, res) => {
  const client = await pool.connect();

  try {
    const { userId, pathName } = req.body;

    if (!userId || !pathName) {
      return res.status(400).json({ message: "Missing data" });
    }

    if (!allowedPaths.includes(pathName)) {
      return res.status(400).json({
        message: `Invalid path selected: ${pathName}`,
      });
    }

    await client.query("BEGIN");

    const userCheck = await client.query(
      "SELECT id, field, level FROM users WHERE id = $1",
      [userId]
    );

    if (userCheck.rows.length === 0) {
      await client.query("ROLLBACK");
      return res.status(404).json({ message: "User not found" });
    }

    const currentMainField = userCheck.rows[0].field;
    const userLevel = userCheck.rows[0].level;

    const exists = await client.query(
      "SELECT 1 FROM user_paths WHERE user_id = $1 AND path_name = $2",
      [userId, pathName]
    );

    if (exists.rows.length === 0) {
      await client.query(
        "INSERT INTO user_paths (user_id, path_name) VALUES ($1, $2)",
        [userId, pathName]
      );
    }

    if (!currentMainField) {
      await client.query("UPDATE users SET field = $1 WHERE id = $2", [
        pathName,
        userId,
      ]);
    }

    if (userLevel) {
      const roadmap = await client.query(
        `
        SELECT id
        FROM roadmaps
        WHERE field_name = $1 AND level = $2
        LIMIT 1
        `,
        [pathName, userLevel]
      );

      if (roadmap.rows.length > 0) {
        await ensureFirstTopicUnlockedForRoadmap(
          client,
          userId,
          roadmap.rows[0].id
        );
      }
    }

    await client.query("COMMIT");

    res.json({
      success: true,
      message: "Path saved successfully",
      mainField: currentMainField || pathName,
      addedPath: pathName,
    });
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("SAVE USER PATH ERROR:", err);
    res.status(500).json({
      message: err.message || "Failed to save path",
    });
  } finally {
    client.release();
  }
});

// ================== COMPLETE PROFILE ==================
app.put("/user/complete-profile", async (req, res) => {
  try {
    const { userId, phone, universityMajor } = req.body;

    if (!userId || !phone || !universityMajor) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    if (!isValidPhone(phone)) {
      return res.status(400).json({ message: "Invalid phone number" });
    }

    const userCheck = await pool.query(
      "SELECT id, level FROM users WHERE id = $1",
      [userId]
    );

    if (userCheck.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    const result = await pool.query(
      `UPDATE users
       SET phone = $1, university_major = $2
       WHERE id = $3
       RETURNING id, name, email, phone, university_major, field, level, placement_score, google_id, auth_provider, avatar_url, role`,
      [phone, universityMajor, userId]
    );

    res.json({
      message: "Profile completed successfully",
      user: result.rows[0],
    });
  } catch (err) {
    console.error("COMPLETE PROFILE ERROR:", err);
    res.status(500).json({ message: "Failed to complete profile" });
  }
});

// ================== SUBMIT PLACEMENT TEST ==================
app.post("/placement-test/submit", async (req, res) => {
  const client = await pool.connect();

  try {
    const { userId, answers } = req.body;

    if (!userId || !Array.isArray(answers) || answers.length === 0) {
      return res.status(400).json({ message: "Invalid submission data" });
    }

    const userCheck = await client.query(
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

    const ids = answers
      .map((a) => Number(a.questionId))
      .filter((id) => Number.isInteger(id) && id > 0);

    if (ids.length === 0) {
      return res.status(400).json({ message: "No valid question ids" });
    }

    const db = await client.query(
      `
      SELECT id, correct_option, difficulty
      FROM placement_questions
      WHERE id = ANY($1::int[])
        AND is_active = true
      `,
      [ids]
    );

    if (db.rows.length === 0) {
      return res.status(400).json({
        message: "No matching placement questions found",
      });
    }

    let totalPoints = 0;
    let earnedPoints = 0;

    db.rows.forEach((q) => {
      const userAnswer = answers.find(
        (a) => Number(a.questionId) === Number(q.id)
      );

      let weight = 1;
      if (q.difficulty === "medium") weight = 2;
      if (q.difficulty === "hard") weight = 3;

      totalPoints += weight;

      if (
        userAnswer &&
        String(userAnswer.answer).trim().toUpperCase() ===
          String(q.correct_option).trim().toUpperCase()
      ) {
        earnedPoints += weight;
      }
    });

    const score =
      totalPoints > 0
        ? Math.round((earnedPoints / totalPoints) * 100)
        : 0;

    const level = calcLevel(score);

    await client.query("BEGIN");

    await client.query(
      "UPDATE users SET level = $1, placement_score = $2 WHERE id = $3",
      [level, score, userId]
    );

    const userPathsResult = await client.query(
      `
      SELECT path_name
      FROM user_paths
      WHERE user_id = $1
      ORDER BY selected_at ASC, id ASC
      `,
      [userId]
    );

    for (const row of userPathsResult.rows) {
      const roadmapResult = await client.query(
        `
        SELECT id
        FROM roadmaps
        WHERE field_name = $1 AND level = $2
        LIMIT 1
        `,
        [row.path_name, level]
      );

      if (roadmapResult.rows.length > 0) {
        await ensureFirstTopicUnlockedForRoadmap(
          client,
          userId,
          roadmapResult.rows[0].id
        );
      }
    }

    await client.query("COMMIT");

    res.json({ score, level });
  } catch (err) {
    try {
      await client.query("ROLLBACK");
    } catch (rollbackErr) {
      console.error("ROLLBACK ERROR:", rollbackErr);
    }

    console.error("SUBMIT PLACEMENT TEST ERROR:", err);
    res.status(500).json({
      message: err.message || "Submit failed",
    });
  } finally {
    client.release();
  }
});
// ================== GET USER DATA ==================
app.get("/user/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT id, name, email, phone, university_major, field, level, placement_score, google_id, auth_provider, avatar_url, role
       FROM users
       WHERE id = $1`,
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

// ================== GET USER GRADES SUMMARY ==================
app.get("/user/:id/grades-summary", async (req, res) => {
  try {
    const { id } = req.params;

    const userResult = await pool.query(
      `
      SELECT id, name, email, field, level, placement_score
      FROM users
      WHERE id = $1
      LIMIT 1
      `,
      [id]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    const user = userResult.rows[0];

    if (!user.field || !user.level) {
      return res.json({
        user,
        summary: {
          placement_score: user.placement_score ?? 0,
          current_level: user.level || "Not determined yet",
          completed_topics: 0,
          attempted_topics: 0,
          average_topic_score: 0,
        },
        topic_scores: [],
      });
    }

    const topicScoresResult = await pool.query(
      `
      SELECT
        rt.id AS topic_id,
        rt.title AS topic_title,
        r.field_name,
        COALESCE(
          utp.status,
          CASE WHEN rt.topic_order = 1 THEN 'unlocked' ELSE 'locked' END
        ) AS status,
        COALESCE(utp.score, 0) AS score,
        utp.completed_at,
        rt.topic_order
      FROM roadmap_topics rt
      JOIN roadmaps r ON rt.roadmap_id = r.id
      LEFT JOIN user_topic_progress utp
        ON utp.topic_id = rt.id AND utp.user_id = $1
      WHERE rt.is_active = true
        AND r.field_name = $2
        AND r.level = $3
      ORDER BY rt.topic_order ASC
      `,
      [id, user.field, user.level]
    );

    const attemptedTopics = topicScoresResult.rows.filter(
      (row) =>
        row.score !== null &&
        row.score !== undefined &&
        Number(row.score) > 0
    );

    const averageTopicScore = attemptedTopics.length
      ? Math.round(
          attemptedTopics.reduce(
            (sum, row) => sum + Number(row.score || 0),
            0
          ) / attemptedTopics.length
        )
      : 0;

    const completedTopics = topicScoresResult.rows.filter(
      (row) => row.status === "completed"
    ).length;

    res.json({
      user,
      summary: {
        placement_score: user.placement_score ?? 0,
        current_level: user.level || "Not determined yet",
        completed_topics: completedTopics,
        attempted_topics: attemptedTopics.length,
        average_topic_score: averageTopicScore,
      },
      topic_scores: topicScoresResult.rows,
    });
  } catch (err) {
    console.error("GET USER GRADES SUMMARY ERROR:", err);
    res.status(500).json({ message: "Failed to load grades summary" });
  }
});
// ================== ADMIN: UPDATE RESOURCE ==================
app.put("/admin/resources/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { topic_id, title, url, type, level } = req.body;

    if (!id) {
      return res.status(400).json({ message: "Missing resource id" });
    }

    await pool.query(
      `
      UPDATE resources
      SET topic_id = $1,
          title = $2,
          url = $3,
          type = $4,
          level = $5
      WHERE id = $6
      `,
      [topic_id, title, url, type, level, id]
    );

    res.json({ message: "Resource updated successfully" });
  } catch (err) {
    console.error("UPDATE RESOURCE ERROR:", err);
    res.status(500).json({ message: "Failed to update resource" });
  }
});
// ================== ADMIN: GET LEARNERS ==================
app.get("/admin/learners", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        id,
        name,
        email,
        field,
        level,
        placement_score
      FROM users
      WHERE role = 'user'
      ORDER BY id DESC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("GET LEARNERS ERROR:", err);
    res.status(500).json({ message: "Failed to fetch learners" });
  }
});
// ================== ADMIN: STATS ==================
app.get("/admin/stats", requireAdmin, async (req, res) => {
  try {
    const users = await pool.query(`SELECT COUNT(*) FROM users WHERE role='user'`);
    const topics = await pool.query(`SELECT COUNT(*) FROM roadmap_topics`);
    const questions = await pool.query(`SELECT COUNT(*) FROM questions`);
    const resources = await pool.query(`SELECT COUNT(*) FROM resources`);

    res.json({
      usersCount: Number(users.rows[0].count),
      topicsCount: Number(topics.rows[0].count),
      questionsCount: Number(questions.rows[0].count),
      resourcesCount: Number(resources.rows[0].count),
      completedQuizzesCount: 0,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to fetch stats" });
  }
});

// ================== ADMIN: GET TOPICS ==================
app.get("/admin/topics", requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, title, description, topic_order AS order_number, is_active,
      (SELECT field_name FROM roadmaps WHERE id = roadmap_id LIMIT 1) AS field,
      (SELECT level FROM roadmaps WHERE id = roadmap_id LIMIT 1) AS level
      FROM roadmap_topics
      ORDER BY topic_order ASC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to fetch topics" });
  }
});

// ================== ADMIN: GET QUESTIONS ==================
app.get("/admin/questions", requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM questions
      ORDER BY id DESC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to fetch questions" });
  }
});

// ================== ADMIN: GET RESOURCES ==================
app.get("/admin/resources", requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM resources
      ORDER BY id DESC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to fetch resources" });
  }
});

// ================== ADMIN: ANALYTICS ==================
app.get("/admin/analytics", requireAdmin, async (req, res) => {
  try {
    const usersByLevel = await pool.query(`
      SELECT level, COUNT(*) FROM users GROUP BY level
    `);

    const topFields = await pool.query(`
      SELECT field, COUNT(*) FROM users GROUP BY field ORDER BY COUNT(*) DESC LIMIT 5
    `);

    res.json({
      usersByLevel: usersByLevel.rows,
      topFields: topFields.rows,
      avgQuizScore: 0,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to fetch analytics" });
  }
});

// ================== GET USER CALENDAR SUMMARY ==================
app.get("/user/:id/calendar-summary", async (req, res) => {
  try {
    const { id } = req.params;

    const userResult = await pool.query(
      `
      SELECT id, name, field, level
      FROM users
      WHERE id = $1
      LIMIT 1
      `,
      [id]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    const user = userResult.rows[0];

    if (!user.field || !user.level) {
      return res.json({
        user,
        weekly_plan: [],
        message: "User has not completed field or level setup yet",
      });
    }

    const roadmapResult = await pool.query(
      `
      SELECT rt.id, rt.title, rt.topic_order, r.field_name
      FROM roadmap_topics rt
      JOIN roadmaps r ON rt.roadmap_id = r.id
      WHERE r.field_name = $1
        AND r.level = $2
        AND rt.is_active = true
      ORDER BY rt.topic_order ASC
      `,
      [user.field, user.level]
    );

    const progressResult = await pool.query(
      `
      SELECT topic_id, status, score, completed_at
      FROM user_topic_progress
      WHERE user_id = $1
      `,
      [id]
    );

    const progressMap = new Map(
      progressResult.rows.map((row) => [Number(row.topic_id), row])
    );

    const topics = roadmapResult.rows || [];

    const planDays = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Saturday",
    ];

    const weeklyPlan = topics.slice(0, 6).map((topic, index) => {
      const progress = progressMap.get(Number(topic.id));

      let status = "locked";
      if (progress?.status) {
        status = progress.status;
      } else if (index === 0) {
        status = "unlocked";
      } else {
        const prevTopic = topics[index - 1];
        const prevProgress = prevTopic
          ? progressMap.get(Number(prevTopic.id))
          : null;

        if (prevProgress?.status === "completed") {
          status = "unlocked";
        }
      }

      return {
        day: planDays[index % planDays.length],
        topic_id: topic.id,
        topic_title: topic.title,
        topic_order: topic.topic_order,
        field_name: topic.field_name,
        status,
        score: progress?.score ?? 0,
        completed_at: progress?.completed_at || null,
      };
    });

    res.json({
      user,
      weekly_plan: weeklyPlan,
    });
  } catch (err) {
    console.error("GET USER CALENDAR SUMMARY ERROR:", err);
    res.status(500).json({ message: "Failed to load calendar summary" });
  }
});

// ================== DELETE USER PATHS ==================
app.delete("/user/paths", async (req, res) => {
  const client = await pool.connect();

  try {
    const { userId, paths } = req.body;

    if (!userId || !Array.isArray(paths) || paths.length === 0) {
      return res.status(400).json({ message: "Invalid request data" });
    }

    await client.query("BEGIN");

    const userResult = await client.query(
      `
      SELECT field, level
      FROM users
      WHERE id = $1
      `,
      [userId]
    );

    if (userResult.rows.length === 0) {
      await client.query("ROLLBACK");
      return res.status(404).json({ message: "User not found" });
    }

    const currentField = userResult.rows[0].field;
    const currentLevel = userResult.rows[0].level;
    const deletingMainField = currentField && paths.includes(currentField);

    await client.query(
      `
      DELETE FROM user_paths
      WHERE user_id = $1
        AND path_name = ANY($2)
      `,
      [userId, paths]
    );

    if (currentLevel) {
      for (const deletedPath of paths) {
        const roadmapResult = await client.query(
          `
          SELECT id
          FROM roadmaps
          WHERE field_name = $1 AND level = $2
          LIMIT 1
          `,
          [deletedPath, currentLevel]
        );

        if (roadmapResult.rows.length > 0) {
          const roadmapId = roadmapResult.rows[0].id;

          await client.query(
            `
            DELETE FROM user_topic_progress
            WHERE user_id = $1
              AND topic_id IN (
                SELECT id
                FROM roadmap_topics
                WHERE roadmap_id = $2
              )
            `,
            [userId, roadmapId]
          );
        }
      }
    }

    if (deletingMainField) {
      const remainingPathsResult = await client.query(
        `
        SELECT path_name
        FROM user_paths
        WHERE user_id = $1
        ORDER BY selected_at ASC, id ASC
        LIMIT 1
        `,
        [userId]
      );

      const newMainField =
        remainingPathsResult.rows.length > 0
          ? remainingPathsResult.rows[0].path_name
          : null;

      await client.query(
        `
        UPDATE users
        SET field = $1
        WHERE id = $2
        `,
        [newMainField, userId]
      );
    }

    await client.query("COMMIT");

    res.status(200).json({
      message: "Paths deleted successfully",
      clearedMainField: deletingMainField,
    });
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("DELETE PATHS ERROR:", err);
    res.status(500).json({ message: "Failed to delete paths" });
  } finally {
    client.release();
  }
});

// ================== GET PLACEMENT TEST QUESTIONS ==================
app.get("/placement-test/questions", async (req, res) => {
  try {
    const easy = await pool.query(`
      SELECT id, question, option_a, option_b, option_c, option_d
      FROM placement_questions
      WHERE is_active = true AND difficulty = 'easy'
      ORDER BY RANDOM()
      LIMIT 10
    `);

    const medium = await pool.query(`
      SELECT id, question, option_a, option_b, option_c, option_d
      FROM placement_questions
      WHERE is_active = true AND difficulty = 'medium'
      ORDER BY RANDOM()
      LIMIT 10
    `);

    const hard = await pool.query(`
      SELECT id, question, option_a, option_b, option_c, option_d
      FROM placement_questions
      WHERE is_active = true AND difficulty = 'hard'
      ORDER BY RANDOM()
      LIMIT 5
    `);

    const questions = [...easy.rows, ...medium.rows, ...hard.rows];
    const shuffled = questions.sort(() => Math.random() - 0.5);

    res.json(shuffled);
  } catch (err) {
    console.error("LOAD PLACEMENT QUESTIONS ERROR:", err);
    res.status(500).json({ message: "Failed to load placement questions" });
  }
});
// ================== GET ROADMAP ==================
app.get("/roadmap/:field/:level/:userId", async (req, res) => {
  const client = await pool.connect();

  try {
    const { field, level, userId } = req.params;

    const roadmapResult = await client.query(
      `
      SELECT id, field_name, level, title, description
      FROM roadmaps
      WHERE field_name ILIKE $1 AND level ILIKE $2
      LIMIT 1
      `,
      [field, level]
    );

    if (roadmapResult.rows.length === 0) {
      return res.status(404).json({ message: "Roadmap not found" });
    }

    const roadmap = roadmapResult.rows[0];

    await ensureFirstTopicUnlockedForRoadmap(client, userId, roadmap.id);

    const topics = await getRoadmapTopicsWithStatus(client, roadmap.id, userId);
    const topicIds = topics.map((t) => t.id);

    let resourcesRows = [];
    if (topicIds.length > 0) {
      const resourcesResult = await client.query(
        `
        SELECT id, topic_id, title, url, type
        FROM resources
        WHERE topic_id = ANY($1::int[])
        ORDER BY id ASC
        `,
        [topicIds]
      );
      resourcesRows = resourcesResult.rows;
    }

    const topicsWithResources = topics.map((topic) => ({
      ...topic,
      resources: resourcesRows.filter((r) => Number(r.topic_id) === Number(topic.id)),
    }));

    res.json({
      roadmap,
      topics: topicsWithResources,
    });
  } catch (err) {
    console.error("GET ROADMAP ERROR:", err);
    res.status(500).json({ message: "Failed to load roadmap" });
  } finally {
    client.release();
  }
});

// ================== GET TOPIC ACCESS ==================
app.get("/topic/:topicId/access/:userId", async (req, res) => {
  const client = await pool.connect();

  try {
    const { topicId, userId } = req.params;

    const access = await getTopicAccessStatus(client, userId, topicId);

    if (!access.found) {
      return res.status(404).json({ message: "Topic not found" });
    }

    const titleResult = await client.query(
      `
      SELECT id, title
      FROM roadmap_topics
      WHERE id = $1
      LIMIT 1
      `,
      [topicId]
    );

    res.json({
      id: Number(topicId),
      title: titleResult.rows[0]?.title || "",
      status: access.status,
    });
  } catch (err) {
    console.error("GET TOPIC ACCESS ERROR:", err);
    res.status(500).json({ message: "Failed to check topic access" });
  } finally {
    client.release();
  }
});

// ================== GET TOPIC DETAILS ==================
app.get("/topic/:topicId/details/:userId", async (req, res) => {
  const client = await pool.connect();

  try {
    const { topicId, userId } = req.params;

    const access = await getTopicAccessStatus(client, userId, topicId);

    if (!access.found) {
      return res.status(404).json({ message: "Topic not found" });
    }

    const topicResult = await client.query(
      `
      SELECT id, title, description, topic_order
      FROM roadmap_topics
      WHERE id = $1
      LIMIT 1
      `,
      [topicId]
    );

    if (topicResult.rows.length === 0) {
      return res.status(404).json({ message: "Topic not found" });
    }

    const resourcesResult = await client.query(
      `
      SELECT id, topic_id, title, url, type
      FROM resources
      WHERE topic_id = $1
      ORDER BY id ASC
      `,
      [topicId]
    );

    const quizCountResult = await client.query(
      `
      SELECT COUNT(*)::int AS total
      FROM questions
      WHERE topic_id = $1
        AND quiz_type = 'topic'
      `,
      [topicId]
    );

    const topic = topicResult.rows[0];
    const quizCount = quizCountResult.rows[0]?.total || 0;

    res.json({
      topic,
      status: access.status,
      resources: resourcesResult.rows || [],
      hasQuiz: quizCount > 0,
      quizCount,
      about: `This topic helps you understand the core concepts of ${topic.title}. Start by watching the resources below, then test your understanding through the quiz.`,
    });
  } catch (err) {
    console.error("GET TOPIC DETAILS ERROR:", err);
    res.status(500).json({ message: "Failed to load topic details" });
  } finally {
    client.release();
  }
});

// ================== GET TOPIC QUESTIONS ==================
app.get("/topic/:topicId/questions/:userId", async (req, res) => {
  const client = await pool.connect();

  try {
    const { topicId, userId } = req.params;

    const access = await getTopicAccessStatus(client, userId, topicId);

    if (!access.found) {
      return res.status(404).json({ message: "Topic not found" });
    }

    if (access.status === "locked") {
      return res.status(403).json({ message: "This topic is locked" });
    }

    const result = await client.query(
      `
      SELECT id, question, option_a, option_b, option_c, option_d
      FROM questions
      WHERE topic_id = $1
        AND quiz_type = 'topic'
      ORDER BY RANDOM()
      LIMIT 10
      `,
      [topicId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error("GET TOPIC QUESTIONS ERROR:", err);
    res.status(500).json({ message: "Failed to load questions" });
  } finally {
    client.release();
  }
});

// ================== SUBMIT TOPIC QUIZ ==================
app.post("/topic/submit-quiz", async (req, res) => {
  const client = await pool.connect();

  try {
    const { userId, topicId, answers } = req.body;

    if (!userId || !topicId || !answers || answers.length === 0) {
      return res.status(400).json({ message: "Invalid submission data" });
    }

    const access = await getTopicAccessStatus(client, userId, topicId);

    if (!access.found) {
      return res.status(404).json({ message: "Topic not found" });
    }

    if (access.status === "locked") {
      return res.status(403).json({ message: "This topic is locked" });
    }

    const submittedQuestionIds = answers.map((a) => Number(a.questionId));

    const dbQuestions = await client.query(
      `
      SELECT id, question, correct_option
      FROM questions
      WHERE topic_id = $1
        AND quiz_type = 'topic'
        AND id = ANY($2::int[])
      `,
      [topicId, submittedQuestionIds]
    );

    if (dbQuestions.rows.length === 0) {
      return res
        .status(404)
        .json({ message: "No questions found for this topic" });
    }

    let correct = 0;
    const wrongAnswers = [];

    answers.forEach((a) => {
      const q = dbQuestions.rows.find(
        (q) => Number(q.id) === Number(a.questionId)
      );

      if (!q) return;

      const selectedAnswer = a.answer;

      const isCorrect =
        selectedAnswer &&
        String(selectedAnswer).trim().toUpperCase() ===
          String(q.correct_option).trim().toUpperCase();

      if (isCorrect) {
        correct++;
      } else {
        wrongAnswers.push({
          question: q.question,
          userAnswer: selectedAnswer,
          correctAnswer: q.correct_option,
        });
      }
    });

    const score = Math.round((correct / answers.length) * 100);
    const passed = score >= 60;
    let nextTopicId = null;

    const topicInfoResult = await client.query(
      `
      SELECT title
      FROM roadmap_topics
      WHERE id = $1
      LIMIT 1
      `,
      [topicId]
    );

    const topicTitle = topicInfoResult.rows[0]?.title || `Topic ${topicId}`;

    let analysis = null;

    try {
      analysis = await analyzeQuizPerformance({
        topicTitle,
        score,
        totalQuestions: answers.length,
        correctCount: correct,
        wrongAnswers,
      });
    } catch (aiErr) {
      console.error("AI ANALYSIS ERROR:", aiErr.message);
      analysis = "AI analysis is temporarily unavailable.";
    }

    await client.query("BEGIN");

    await client.query(
      `
      INSERT INTO user_topic_progress (user_id, topic_id, status, score, completed_at)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (user_id, topic_id)
      DO UPDATE SET
        status = EXCLUDED.status,
        score = EXCLUDED.score,
        completed_at = EXCLUDED.completed_at
      `,
      [
        userId,
        topicId,
        passed ? "completed" : "unlocked",
        score,
        passed ? new Date() : null,
      ]
    );

    if (passed) {
      const nextTopic = await client.query(
        `
        SELECT rt2.id
        FROM roadmap_topics rt1
        JOIN roadmap_topics rt2
          ON rt2.roadmap_id = rt1.roadmap_id
         AND rt2.topic_order = rt1.topic_order + 1
         AND rt2.is_active = true
        WHERE rt1.id = $1
        LIMIT 1
        `,
        [topicId]
      );

      if (nextTopic.rows.length > 0) {
        nextTopicId = nextTopic.rows[0].id;

        await client.query(
          `
          INSERT INTO user_topic_progress (user_id, topic_id, status, score, completed_at)
          VALUES ($1, $2, 'unlocked', 0, NULL)
          ON CONFLICT (user_id, topic_id)
          DO UPDATE SET
            status = CASE
              WHEN user_topic_progress.status = 'completed' THEN 'completed'
              ELSE 'unlocked'
            END
          `,
          [userId, nextTopicId]
        );
      }
    }

    await client.query("COMMIT");

    res.json({
      score,
      passed,
      nextTopicId,
      analysis,
      message: passed
        ? "Quiz passed successfully, next topic unlocked"
        : "Quiz not passed, try again",
    });
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("SUBMIT TOPIC QUIZ ERROR:", err);
    res.status(500).json({ message: "Failed to submit quiz" });
  } finally {
    client.release();
  }
});

// ================== AI GENERATE QUIZ ==================
app.post("/ai/generate-quiz", async (req, res) => {
  const client = await pool.connect();

  try {
    const { userId, topicId, count } = req.body;
    const questionCount = Number(count) || 5;

    if (!userId || !topicId) {
      return res.status(400).json({ message: "Missing data" });
    }

    const access = await getTopicAccessStatus(client, userId, topicId);

    if (!access.found) {
      return res.status(404).json({ message: "Topic not found" });
    }

    if (access.status === "locked") {
      return res.status(403).json({ message: "This topic is locked" });
    }

    const topicInfo = await getTopicTitleAndLevel(client, topicId);

    if (!topicInfo) {
      return res.status(404).json({ message: "Topic not found" });
    }

    const recentHistoryResult = await client.query(
      `
      SELECT question_text, weakness_tag, was_correct
      FROM user_question_history
      WHERE user_id = $1 AND topic_id = $2
      ORDER BY created_at DESC
      LIMIT 30
      `,
      [userId, topicId]
    );

    const recentHistory = recentHistoryResult.rows || [];
    const excludedQuestions = recentHistory
      .map((row) => row.question_text)
      .filter(Boolean);

    const weakAreas = getWeakAreasFromHistory(recentHistory);
    const wrongHistoryCount = recentHistory.filter(
      (row) => row.was_correct === false
    ).length;

    const difficultyStep = getDifficultyStep(
      topicInfo.level || "Beginner",
      wrongHistoryCount
    );

    const allowCodeQuiz = supportsCodeQuiz(topicInfo.field_name);

    let generatedQuestions = [];

    if (allowCodeQuiz) {
      try {
        generatedQuestions = await generateCodeQuiz({
          topicTitle: topicInfo.title,
          level: topicInfo.level || "Beginner",
          fieldName: topicInfo.field_name,
          count: questionCount,
          excludedQuestions,
          weakAreas,
          difficultyStep,
        });
      } catch (aiErr) {
        console.error("AI GENERATE QUIZ ERROR:", aiErr.message);
        generatedQuestions = [];
      }
    }

    if (!Array.isArray(generatedQuestions) || generatedQuestions.length === 0) {
      const fallbackQuestions = await getTopicDbQuestions(
        client,
        topicId,
        questionCount
      );

      return res.json({
        source: "database_fallback",
        questions: fallbackQuestions,
      });
    }

    const insertedQuestions = [];
    const generationBatchId = `${Date.now()}-${userId}-${topicId}`;

    for (const q of generatedQuestions) {
      const duplicateCheck = await client.query(
        `
        SELECT 1
        FROM user_question_history
        WHERE user_id = $1
          AND topic_id = $2
          AND question_hash = $3
        LIMIT 1
        `,
        [userId, topicId, q.question_hash]
      );

      if (duplicateCheck.rows.length > 0) {
        continue;
      }

      const insertResult = await client.query(
        `
        INSERT INTO generated_questions (
          user_id,
          topic_id,
          question_text,
          code_snippet,
          option_a,
          option_b,
          option_c,
          option_d,
          correct_option,
          explanation,
          question_type,
          difficulty,
          question_hash,
          generation_batch_id,
          weakness_tag,
          difficulty_step
        )
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
        RETURNING *
        `,
        [
          userId,
          topicId,
          q.question_text,
          q.code_snippet || null,
          q.option_a,
          q.option_b,
          q.option_c,
          q.option_d,
          q.correct_option,
          q.explanation || null,
          q.question_type || "mcq",
          q.difficulty || topicInfo.level || "Beginner",
          q.question_hash,
          generationBatchId,
          q.weakness_tag || "general",
          q.difficulty_step || 1,
        ]
      );

      const row = insertResult.rows[0];

      insertedQuestions.push({
        id: row.id,
        question: row.code_snippet
          ? `${row.question_text}\n\n${row.code_snippet}`
          : row.question_text,
        option_a: row.option_a,
        option_b: row.option_b,
        option_c: row.option_c,
        option_d: row.option_d,
      });

      if (insertedQuestions.length >= questionCount) {
        break;
      }
    }

    if (insertedQuestions.length === 0) {
      const fallbackQuestions = await getTopicDbQuestions(
        client,
        topicId,
        questionCount
      );

      return res.json({
        source: "database_fallback",
        questions: fallbackQuestions,
      });
    }

    res.json({
      source: "ai",
      questions: insertedQuestions,
    });
  } catch (err) {
    console.error("AI GENERATE QUIZ ROUTE ERROR:", err);
    res.status(500).json({
      message: err.message || "Failed to generate AI quiz",
    });
  } finally {
    client.release();
  }
});
// ================== AI STUDY PLAN ==================
app.post("/ai/study-plan", async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({ message: "Missing userId" });
    }

    const userResult = await pool.query(
      `
      SELECT id, name, field, level, placement_score
      FROM users
      WHERE id = $1
      LIMIT 1
      `,
      [userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    const user = userResult.rows[0];

    if (!user.field || !user.level) {
      return res.json({
        plan: [],
        message: "User has not completed field or level setup yet",
      });
    }

    const roadmapResult = await pool.query(
      `
      SELECT rt.id, rt.title, rt.topic_order, r.field_name
      FROM roadmap_topics rt
      JOIN roadmaps r ON rt.roadmap_id = r.id
      WHERE r.field_name = $1
        AND r.level = $2
        AND rt.is_active = true
      ORDER BY rt.topic_order ASC
      LIMIT 6
      `,
      [user.field, user.level]
    );

    const progressResult = await pool.query(
      `
      SELECT topic_id, status, score, completed_at
      FROM user_topic_progress
      WHERE user_id = $1
      `,
      [userId]
    );

    const progressMap = new Map(
      progressResult.rows.map((row) => [Number(row.topic_id), row])
    );

    const topics = roadmapResult.rows || [];

    if (topics.length === 0) {
      return res.json({
        plan: [],
        message: "No roadmap topics found for this user",
      });
    }

    const topicsForPrompt = topics.map((topic, index) => {
      const progress = progressMap.get(Number(topic.id));

      let status = "locked";
      if (progress?.status) {
        status = progress.status;
      } else if (index === 0) {
        status = "unlocked";
      } else {
        const prevTopic = topics[index - 1];
        const prevProgress = prevTopic
          ? progressMap.get(Number(prevTopic.id))
          : null;

        if (prevProgress?.status === "completed") {
          status = "unlocked";
        }
      }

      return {
        topic_id: topic.id,
        topic_title: topic.title,
        topic_order: topic.topic_order,
        status,
        score: progress?.score ?? 0,
      };
    });

    const messages = [
      {
        role: "system",
        content: `
You are an AI study planner inside Cognito, an adaptive learning platform for IT students.

Your task:
- Create a realistic weekly study plan for the student.
- Base the plan on the user's field, level, and roadmap topics.
- Prioritize unlocked topics first.
- If some topics are completed, include review or quiz practice where suitable.
- Keep the plan student-friendly, practical, and balanced.

Return ONLY valid JSON.
Do not add markdown.
Do not add explanation outside JSON.

Return this exact structure:
[
  {
    "day": "Sunday",
    "title": "Short session title",
    "focus": "Main focus area",
    "duration": "1.5 hrs",
    "time": "6:00 PM - 7:30 PM",
    "description": "One short helpful description",
    "tasks": ["Task 1", "Task 2", "Task 3"]
  }
]

Rules:
- Return 6 or 7 items.
- Use real weekday names.
- Keep tasks short and actionable.
- Keep durations realistic.
- If the user is Beginner, make the plan lighter.
- If Intermediate or Advanced, allow more practice and quizzes.
        `.trim(),
      },
      {
        role: "user",
        content: `
Student context:
Name: ${user.name || "Student"}
Field: ${user.field}
Level: ${user.level}
Placement Score: ${
          user.placement_score !== null && user.placement_score !== undefined
            ? user.placement_score
            : "N/A"
        }

Roadmap topics and progress:
${JSON.stringify(topicsForPrompt, null, 2)}
        `.trim(),
      },
    ];

    const aiText = await callAI(messages);

    if (!aiText || aiText === "AI service is currently unavailable.") {
      return res.json({
        plan: [],
        message: "AI service is currently unavailable.",
      });
    }

    let parsedPlan = [];

    try {
      parsedPlan = JSON.parse(aiText);
    } catch (parseError) {
      console.error("AI STUDY PLAN PARSE ERROR:", parseError.message);
      return res.json({
        plan: [],
        message: "AI returned invalid plan format",
      });
    }

    if (!Array.isArray(parsedPlan)) {
      return res.json({
        plan: [],
        message: "AI returned unexpected plan format",
      });
    }

    return res.json({
      plan: parsedPlan,
    });
  } catch (err) {
    console.error("AI STUDY PLAN ERROR:", err);
    return res.status(500).json({ message: "Failed to generate study plan" });
  }
});
// ================== AI SUBMIT QUIZ ==================
app.post("/ai/submit-quiz", async (req, res) => {
  const client = await pool.connect();

  try {
    const { userId, topicId, answers } = req.body;

    if (!userId || !topicId || !answers || answers.length === 0) {
      return res.status(400).json({ message: "Invalid submission data" });
    }

    const access = await getTopicAccessStatus(client, userId, topicId);

    if (!access.found) {
      return res.status(404).json({ message: "Topic not found" });
    }

    if (access.status === "locked") {
      return res.status(403).json({ message: "This topic is locked" });
    }

    const submittedQuestionIds = answers.map((a) => Number(a.questionId));

    const generatedResult = await client.query(
      `
      SELECT id, question_text, code_snippet, correct_option, explanation
      FROM generated_questions
      WHERE user_id = $1
        AND topic_id = $2
        AND id = ANY($3::int[])
      `,
      [userId, topicId, submittedQuestionIds]
    );

    const useGeneratedQuestions = generatedResult.rows.length > 0;

    let quizRows = [];
    let wrongAnswers = [];
    let correct = 0;

    if (useGeneratedQuestions) {
      quizRows = generatedResult.rows;

      answers.forEach((a) => {
        const q = quizRows.find(
          (row) => Number(row.id) === Number(a.questionId)
        );
        if (!q) return;

        const selectedAnswer = a.answer;
        const isCorrect =
          selectedAnswer &&
          String(selectedAnswer).trim().toUpperCase() ===
            String(q.correct_option).trim().toUpperCase();

        if (isCorrect) {
          correct++;
        } else {
          wrongAnswers.push({
            question: q.code_snippet
              ? `${q.question_text}\n\n${q.code_snippet}`
              : q.question_text,
            userAnswer: selectedAnswer,
            correctAnswer: q.correct_option,
          });
        }
      });
    } else {
      const dbQuestions = await client.query(
        `
        SELECT id, question, correct_option
        FROM questions
        WHERE topic_id = $1
          AND quiz_type = 'topic'
          AND id = ANY($2::int[])
        `,
        [topicId, submittedQuestionIds]
      );

      if (dbQuestions.rows.length === 0) {
        return res.status(404).json({
          message: "No AI or fallback questions found for this submission",
        });
      }

      quizRows = dbQuestions.rows;

      answers.forEach((a) => {
        const q = quizRows.find(
          (row) => Number(row.id) === Number(a.questionId)
        );
        if (!q) return;

        const selectedAnswer = a.answer;
        const isCorrect =
          selectedAnswer &&
          String(selectedAnswer).trim().toUpperCase() ===
            String(q.correct_option).trim().toUpperCase();

        if (isCorrect) {
          correct++;
        } else {
          wrongAnswers.push({
            question: q.question,
            userAnswer: selectedAnswer,
            correctAnswer: q.correct_option,
          });
        }
      });
    }

    const score = Math.round((correct / answers.length) * 100);
    const passed = score >= 60;
    let nextTopicId = null;

    const topicInfoResult = await client.query(
      `
      SELECT title
      FROM roadmap_topics
      WHERE id = $1
      LIMIT 1
      `,
      [topicId]
    );

    const topicTitle = topicInfoResult.rows[0]?.title || `Topic ${topicId}`;

    let analysis = null;

    try {
      analysis = await analyzeQuizPerformance({
        topicTitle: `${topicTitle} ${
          useGeneratedQuestions ? "(AI Quiz)" : "(Fallback Quiz)"
        }`,
        score,
        totalQuestions: answers.length,
        correctCount: correct,
        wrongAnswers,
      });
    } catch (aiErr) {
      console.error("AI ANALYSIS ERROR:", aiErr.message);
      analysis = "AI analysis is temporarily unavailable.";
    }

    await client.query("BEGIN");

    if (useGeneratedQuestions) {
      for (const answerItem of answers) {
        const q = generatedResult.rows.find(
          (row) => Number(row.id) === Number(answerItem.questionId)
        );

        if (!q) continue;

        const selectedAnswer = answerItem.answer;
        const isCorrect =
          selectedAnswer &&
          String(selectedAnswer).trim().toUpperCase() ===
            String(q.correct_option).trim().toUpperCase();

        const generatedQuestionMeta = await client.query(
          `
          SELECT question_hash, question_type, difficulty, weakness_tag, difficulty_step
          FROM generated_questions
          WHERE id = $1
          LIMIT 1
          `,
          [q.id]
        );

        const meta = generatedQuestionMeta.rows[0];

        await client.query(
          `
          INSERT INTO user_question_history (
            user_id,
            topic_id,
            generated_question_id,
            question_hash,
            question_text,
            question_type,
            weakness_tag,
            difficulty,
            difficulty_step,
            user_answer,
            correct_answer,
            was_correct
          )
          VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
          `,
          [
            userId,
            topicId,
            q.id,
            meta?.question_hash || `fallback-${q.id}`,
            q.code_snippet
              ? `${q.question_text}\n\n${q.code_snippet}`
              : q.question_text,
            meta?.question_type || "mcq",
            meta?.weakness_tag || "general",
            meta?.difficulty || "medium",
            meta?.difficulty_step || 1,
            selectedAnswer || null,
            q.correct_option,
            Boolean(isCorrect),
          ]
        );
      }
    }

    await client.query(
      `
      INSERT INTO user_topic_progress (user_id, topic_id, status, score, completed_at)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (user_id, topic_id)
      DO UPDATE SET
        status = EXCLUDED.status,
        score = EXCLUDED.score,
        completed_at = EXCLUDED.completed_at
      `,
      [
        userId,
        topicId,
        passed ? "completed" : "unlocked",
        score,
        passed ? new Date() : null,
      ]
    );

    if (passed) {
      const nextTopic = await client.query(
        `
        SELECT rt2.id
        FROM roadmap_topics rt1
        JOIN roadmap_topics rt2
          ON rt2.roadmap_id = rt1.roadmap_id
         AND rt2.topic_order = rt1.topic_order + 1
         AND rt2.is_active = true
        WHERE rt1.id = $1
        LIMIT 1
        `,
        [topicId]
      );

      if (nextTopic.rows.length > 0) {
        nextTopicId = nextTopic.rows[0].id;

        await client.query(
          `
          INSERT INTO user_topic_progress (user_id, topic_id, status, score, completed_at)
          VALUES ($1, $2, 'unlocked', 0, NULL)
          ON CONFLICT (user_id, topic_id)
          DO UPDATE SET
            status = CASE
              WHEN user_topic_progress.status = 'completed' THEN 'completed'
              ELSE 'unlocked'
            END
          `,
          [userId, nextTopicId]
        );
      }
    }

    await client.query("COMMIT");

    res.json({
      score,
      passed,
      nextTopicId,
      analysis,
      message: passed
        ? "AI quiz passed successfully, next topic unlocked"
        : "AI quiz not passed, try again",
    });
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("AI SUBMIT QUIZ ERROR:", err);
    res
      .status(500)
      .json({ message: err.message || "Failed to submit AI quiz" });
  } finally {
    client.release();
  }
});

// ================== GENERATE AI CODE QUIZ ==================
app.post("/topic/:topicId/generate-code-quiz", async (req, res) => {
  const client = await pool.connect();

  try {
    const { topicId } = req.params;
    const { userId } = req.body;

    if (!userId || !topicId) {
      return res.status(400).json({ message: "Missing data" });
    }

    const access = await getTopicAccessStatus(client, userId, topicId);

    if (!access.found) {
      return res.status(404).json({ message: "Topic not found" });
    }

    if (access.status === "locked") {
      return res.status(403).json({ message: "This topic is locked" });
    }

    const topicResult = await client.query(
      `
      SELECT rt.id, rt.title, r.level, r.field_name
      FROM roadmap_topics rt
      JOIN roadmaps r ON rt.roadmap_id = r.id
      WHERE rt.id = $1
      LIMIT 1
      `,
      [topicId]
    );

    if (topicResult.rows.length === 0) {
      return res.status(404).json({ message: "Topic not found" });
    }

    const topic = topicResult.rows[0];

    if (!supportsCodeQuiz(topic.field_name)) {
      return res.status(400).json({
        message:
          "Code quiz is only fully supported for Frontend Development, Backend Development, Programming Fundamentals, and Mobile Development",
      });
    }

    const recentHistoryResult = await client.query(
      `
      SELECT question_text, weakness_tag, was_correct
      FROM user_question_history
      WHERE user_id = $1 AND topic_id = $2
      ORDER BY created_at DESC
      LIMIT 30
      `,
      [userId, topicId]
    );

    const recentHistory = recentHistoryResult.rows || [];
    const excludedQuestions = recentHistory
      .map((row) => row.question_text)
      .filter(Boolean);

    const weakAreas = getWeakAreasFromHistory(recentHistory);
    const wrongHistoryCount = recentHistory.filter(
      (row) => row.was_correct === false
    ).length;

    const difficultyStep = getDifficultyStep(
      topic.level || "Beginner",
      wrongHistoryCount
    );

    const generatedQuestions = await generateCodeQuiz({
      topicTitle: topic.title,
      level: topic.level || "Beginner",
      fieldName: topic.field_name,
      count: 5,
      excludedQuestions,
      weakAreas,
      difficultyStep,
    });

    const insertedQuestions = [];
    const generationBatchId = `${Date.now()}-${userId}-${topicId}-manual`;

    for (const q of generatedQuestions) {
      const duplicateCheck = await client.query(
        `
        SELECT 1
        FROM user_question_history
        WHERE user_id = $1
          AND topic_id = $2
          AND question_hash = $3
        LIMIT 1
        `,
        [userId, topicId, q.question_hash]
      );

      if (duplicateCheck.rows.length > 0) {
        continue;
      }

      const insertResult = await client.query(
        `
        INSERT INTO generated_questions (
          user_id,
          topic_id,
          question_text,
          code_snippet,
          option_a,
          option_b,
          option_c,
          option_d,
          correct_option,
          explanation,
          question_type,
          difficulty,
          question_hash,
          generation_batch_id,
          weakness_tag,
          difficulty_step
        )
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
        RETURNING *
        `,
        [
          userId,
          topicId,
          q.question_text,
          q.code_snippet || null,
          q.option_a,
          q.option_b,
          q.option_c,
          q.option_d,
          q.correct_option,
          q.explanation || null,
          q.question_type || "mcq",
          q.difficulty || topic.level || "Beginner",
          q.question_hash,
          generationBatchId,
          q.weakness_tag || "general",
          q.difficulty_step || 1,
        ]
      );

      insertedQuestions.push(insertResult.rows[0]);
    }

    res.json({
      message: "AI code quiz generated successfully",
      questions: insertedQuestions,
    });
  } catch (err) {
    console.error("GENERATE CODE QUIZ ERROR:", err);
    res.status(500).json({ message: "Failed to generate code quiz" });
  } finally {
    client.release();
  }
});

// ================== AI CHATBOT ==================
app.post("/ai/chatbot", async (req, res) => {
  try {
    const { userId, message, history = [] } = req.body;

    if (!message || !String(message).trim()) {
      return res.status(400).json({ message: "Message is required" });
    }

    let userContext = null;

    if (userId) {
      const userResult = await pool.query(
        `
        SELECT id, name, field, level, placement_score
        FROM users
        WHERE id = $1
        LIMIT 1
        `,
        [userId]
      );

      userContext = userResult.rows[0] || null;
    }

    const safeHistory = Array.isArray(history)
      ? history
          .filter(
            (msg) =>
              msg &&
              (msg.role === "user" || msg.role === "assistant") &&
              typeof msg.content === "string"
          )
          .slice(-8)
      : [];

    const systemPrompt = `
You are Cognito Assistant, an AI helper inside an adaptive learning platform for IT students.

Your role:
- Help students understand available learning paths.
- Compare fields like Frontend, Backend, Programming Fundamentals, Databases, Cyber Security, Mobile Development, UI/UX Design, and Cloud Computing.
- Recommend suitable paths based on interests and current level.
- Explain what the student should learn next in a simple and guided way.
- Keep answers focused on Cognito and learning guidance.
- Do not behave like a general open-ended chatbot.
- Keep answers clear, practical, friendly, and not too long.
- When the user asks about choosing a path, explain differences in simple terms.
- When useful, refer to the user's level and current field if available.
- If the user asks about roadmap or next step, guide them based on their current status.
    `.trim();

    const contextPrompt = `
User context:
- Name: ${userContext?.name || "Unknown"}
- Current Field: ${userContext?.field || "Not selected yet"}
- Current Level: ${userContext?.level || "Not determined yet"}
- Placement Score: ${
      userContext?.placement_score !== null &&
      userContext?.placement_score !== undefined
        ? userContext.placement_score
        : "N/A"
    }
    `.trim();

    const messages = [
      { role: "system", content: systemPrompt },
      { role: "system", content: contextPrompt },
      ...safeHistory,
      { role: "user", content: String(message).trim() },
    ];

    const reply = await callAI(messages);

    if (!reply || reply === "AI service is currently unavailable.") {
      return res.json({
        reply: buildChatbotFallbackReply(message, userContext),
        fallback: true,
      });
    }

    return res.json({ reply });
  } catch (error) {
    console.error("CHATBOT ROUTE ERROR:", error);

    return res.json({
      reply: buildChatbotFallbackReply(req.body?.message, null),
      fallback: true,
    });
  }
});

async function getOrCreateRoadmap(field, level) {
  const existing = await pool.query(
    `
    SELECT id
    FROM roadmaps
    WHERE field_name = $1 AND level = $2
    LIMIT 1
    `,
    [field, level]
  );

  if (existing.rows.length > 0) {
    return existing.rows[0].id;
  }

  const inserted = await pool.query(
    `
    INSERT INTO roadmaps (field_name, level, title, description)
    VALUES ($1, $2, $3, $4)
    RETURNING id
    `,
    [
      field,
      level,
      `${field} - ${level}`,
      `Auto-created roadmap for ${field} (${level})`,
    ]
  );

  return inserted.rows[0].id;
}

// ================== ADMIN: CHECK ACCESS ==================
app.get("/admin/check-access", async (req, res) => {
  try {
    const headerRole = getRequestUserRole(req);
    const headerUserId = getRequestUserId(req);

    let finalRole = headerRole;

    if (!finalRole && headerUserId) {
      finalRole = await getUserRoleFromDb(headerUserId);
    }

    res.json({
      allowed: finalRole === "admin",
      role: finalRole || "user",
    });
  } catch (err) {
    console.error("ADMIN CHECK ACCESS ERROR:", err);
    res.status(500).json({ message: "Failed to check admin access" });
  }
});

// ================== ADMIN: STATS ==================
app.get("/admin/stats", requireAdmin, async (req, res) => {
  try {
    const users = await pool.query(`SELECT COUNT(*)::int AS count FROM users WHERE role = 'user'`);
    const topics = await pool.query(`SELECT COUNT(*)::int AS count FROM roadmap_topics`);
    const questions = await pool.query(`SELECT COUNT(*)::int AS count FROM questions`);
    const resources = await pool.query(`SELECT COUNT(*)::int AS count FROM resources`);
    const completedQuizzes = await pool.query(`
      SELECT COUNT(*)::int AS count
      FROM user_topic_progress
      WHERE status = 'completed'
    `);

    res.json({
      usersCount: users.rows[0]?.count || 0,
      topicsCount: topics.rows[0]?.count || 0,
      questionsCount: questions.rows[0]?.count || 0,
      resourcesCount: resources.rows[0]?.count || 0,
      completedQuizzesCount: completedQuizzes.rows[0]?.count || 0,
    });
  } catch (err) {
    console.error("ADMIN STATS ERROR:", err);
    res.status(500).json({ message: "Failed to fetch stats" });
  }
});

// ================== ADMIN: GET TOPICS ==================
app.get("/admin/topics", requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        rt.id,
        rt.title,
        rt.description,
        rt.topic_order AS order_number,
        rt.is_active,
        r.field_name AS field,
        r.level
      FROM roadmap_topics rt
      JOIN roadmaps r ON r.id = rt.roadmap_id
      ORDER BY r.field_name ASC, r.level ASC, rt.topic_order ASC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("ADMIN GET TOPICS ERROR:", err);
    res.status(500).json({ message: "Failed to fetch topics" });
  }
});

// ================== ADMIN: CREATE TOPIC ==================
app.post("/admin/topics", requireAdmin, async (req, res) => {
  try {
    const { title, description, field, level, order_number } = req.body;

    if (!title || !field || !level || !order_number) {
      return res.status(400).json({ message: "Missing required topic fields" });
    }

    const roadmapId = await getOrCreateRoadmap(field.trim(), level.trim());

    const result = await pool.query(
      `
      INSERT INTO roadmap_topics (roadmap_id, title, description, topic_order, is_active)
      VALUES ($1, $2, $3, $4, true)
      RETURNING *
      `,
      [
        roadmapId,
        title.trim(),
        description?.trim() || "",
        Number(order_number),
      ]
    );

    res.status(201).json({
      message: "Topic created successfully",
      topic: result.rows[0],
    });
  } catch (err) {
    console.error("ADMIN CREATE TOPIC ERROR:", err);
    res.status(500).json({ message: "Failed to create topic" });
  }
});

// ================== ADMIN: UPDATE TOPIC ==================
app.put("/admin/topics/:id", requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, field, level, order_number } = req.body;

    if (!title || !field || !level || !order_number) {
      return res.status(400).json({ message: "Missing required topic fields" });
    }

    const roadmapId = await getOrCreateRoadmap(field.trim(), level.trim());

    const result = await pool.query(
      `
      UPDATE roadmap_topics
      SET roadmap_id = $1,
          title = $2,
          description = $3,
          topic_order = $4
      WHERE id = $5
      RETURNING *
      `,
      [
        roadmapId,
        title.trim(),
        description?.trim() || "",
        Number(order_number),
        id,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Topic not found" });
    }

    res.json({
      message: "Topic updated successfully",
      topic: result.rows[0],
    });
  } catch (err) {
    console.error("ADMIN UPDATE TOPIC ERROR:", err);
    res.status(500).json({ message: "Failed to update topic" });
  }
});

// ================== ADMIN: DELETE TOPIC ==================
app.delete("/admin/topics/:id", requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    await pool.query(`DELETE FROM resources WHERE topic_id = $1`, [id]);
    await pool.query(`DELETE FROM questions WHERE topic_id = $1`, [id]);
    await pool.query(`DELETE FROM user_topic_progress WHERE topic_id = $1`, [id]);

    const result = await pool.query(
      `DELETE FROM roadmap_topics WHERE id = $1 RETURNING id`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Topic not found" });
    }

    res.json({ message: "Topic deleted successfully" });
  } catch (err) {
    console.error("ADMIN DELETE TOPIC ERROR:", err);
    res.status(500).json({ message: "Failed to delete topic" });
  }
});

// ================== ADMIN: GET QUESTIONS ==================
app.get("/admin/questions", requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        q.*,
        rt.title AS topic_title
      FROM questions q
      LEFT JOIN roadmap_topics rt ON rt.id = q.topic_id
      ORDER BY q.id DESC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("ADMIN GET QUESTIONS ERROR:", err);
    res.status(500).json({ message: "Failed to fetch questions" });
  }
});

// ================== ADMIN: CREATE QUESTION ==================
app.post("/admin/questions", requireAdmin, async (req, res) => {
  try {
    const {
      topic_id,
      question,
      option_a,
      option_b,
      option_c,
      option_d,
      correct_option,
      difficulty,
      quiz_type,
    } = req.body;

    if (
      !topic_id ||
      !question ||
      !option_a ||
      !option_b ||
      !option_c ||
      !option_d ||
      !correct_option
    ) {
      return res.status(400).json({ message: "Missing required question fields" });
    }

    const result = await pool.query(
      `
      INSERT INTO questions (
        topic_id, question, option_a, option_b, option_c, option_d,
        correct_option, difficulty, quiz_type
      )
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
      RETURNING *
      `,
      [
        Number(topic_id),
        question.trim(),
        option_a.trim(),
        option_b.trim(),
        option_c.trim(),
        option_d.trim(),
        correct_option,
        difficulty || "Beginner",
        quiz_type || "topic",
      ]
    );

    res.status(201).json({
      message: "Question created successfully",
      question: result.rows[0],
    });
  } catch (err) {
    console.error("ADMIN CREATE QUESTION ERROR:", err);
    res.status(500).json({ message: "Failed to create question" });
  }
});

// ================== ADMIN: UPDATE QUESTION ==================
app.put("/admin/questions/:id", requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const {
      topic_id,
      question,
      option_a,
      option_b,
      option_c,
      option_d,
      correct_option,
      difficulty,
      quiz_type,
    } = req.body;

    if (
      !topic_id ||
      !question ||
      !option_a ||
      !option_b ||
      !option_c ||
      !option_d ||
      !correct_option
    ) {
      return res.status(400).json({ message: "Missing required question fields" });
    }

    const result = await pool.query(
      `
      UPDATE questions
      SET topic_id = $1,
          question = $2,
          option_a = $3,
          option_b = $4,
          option_c = $5,
          option_d = $6,
          correct_option = $7,
          difficulty = $8,
          quiz_type = $9
      WHERE id = $10
      RETURNING *
      `,
      [
        Number(topic_id),
        question.trim(),
        option_a.trim(),
        option_b.trim(),
        option_c.trim(),
        option_d.trim(),
        correct_option,
        difficulty || "Beginner",
        quiz_type || "topic",
        id,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Question not found" });
    }

    res.json({
      message: "Question updated successfully",
      question: result.rows[0],
    });
  } catch (err) {
    console.error("ADMIN UPDATE QUESTION ERROR:", err);
    res.status(500).json({ message: "Failed to update question" });
  }
});

// ================== ADMIN: DELETE QUESTION ==================
app.delete("/admin/questions/:id", requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `DELETE FROM questions WHERE id = $1 RETURNING id`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Question not found" });
    }

    res.json({ message: "Question deleted successfully" });
  } catch (err) {
    console.error("ADMIN DELETE QUESTION ERROR:", err);
    res.status(500).json({ message: "Failed to delete question" });
  }
});

// ================== ADMIN: GET RESOURCES ==================
app.get("/admin/resources", requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        r.*,
        rt.title AS topic_title
      FROM resources r
      LEFT JOIN roadmap_topics rt ON rt.id = r.topic_id
      ORDER BY r.id DESC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("ADMIN GET RESOURCES ERROR:", err);
    res.status(500).json({ message: "Failed to fetch resources" });
  }
});

// ================== ADMIN: CREATE RESOURCE ==================
app.post("/admin/resources", requireAdmin, async (req, res) => {
  try {
    const { topic_id, title, url, type, level } = req.body;

    if (!topic_id || !title || !url || !type || !level) {
      return res.status(400).json({ message: "Missing required resource fields" });
    }

    const result = await pool.query(
      `
      INSERT INTO resources (topic_id, title, url, type, level)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
      `,
      [
        Number(topic_id),
        title.trim(),
        url.trim(),
        type,
        level,
      ]
    );

    res.status(201).json({
      message: "Resource created successfully",
      resource: result.rows[0],
    });
  } catch (err) {
    console.error("ADMIN CREATE RESOURCE ERROR:", err);
    res.status(500).json({ message: "Failed to create resource" });
  }
});

// ================== ADMIN: UPDATE RESOURCE ==================
app.put("/admin/resources/:id", requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { topic_id, title, url, type, level } = req.body;

    if (!topic_id || !title || !url || !type || !level) {
      return res.status(400).json({ message: "Missing required resource fields" });
    }

    const result = await pool.query(
      `
      UPDATE resources
      SET topic_id = $1,
          title = $2,
          url = $3,
          type = $4,
          level = $5
      WHERE id = $6
      RETURNING *
      `,
      [Number(topic_id), title.trim(), url.trim(), type, level, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Resource not found" });
    }

    res.json({
      message: "Resource updated successfully",
      resource: result.rows[0],
    });
  } catch (err) {
    console.error("ADMIN UPDATE RESOURCE ERROR:", err);
    res.status(500).json({ message: "Failed to update resource" });
  }
});

// ================== ADMIN: DELETE RESOURCE ==================
app.delete("/admin/resources/:id", requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `DELETE FROM resources WHERE id = $1 RETURNING id`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Resource not found" });
    }

    res.json({ message: "Resource deleted successfully" });
  } catch (err) {
    console.error("ADMIN DELETE RESOURCE ERROR:", err);
    res.status(500).json({ message: "Failed to delete resource" });
  }
});

// ================== ADMIN: GET LEARNERS ==================
app.get("/admin/learners", requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        id,
        name,
        email,
        field,
        level,
        placement_score
      FROM users
      WHERE role = 'user'
      ORDER BY id DESC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("ADMIN GET LEARNERS ERROR:", err);
    res.status(500).json({ message: "Failed to fetch learners" });
  }
});

// ================== ADMIN: ANALYTICS ==================
app.get("/admin/analytics", requireAdmin, async (req, res) => {
  try {
    const usersByLevel = await pool.query(`
      SELECT COALESCE(level, 'Unknown') AS level, COUNT(*)::int AS count
      FROM users
      WHERE role = 'user'
      GROUP BY level
      ORDER BY count DESC
    `);

    const topFields = await pool.query(`
      SELECT COALESCE(field, 'Unknown') AS field, COUNT(*)::int AS count
      FROM users
      WHERE role = 'user'
      GROUP BY field
      ORDER BY count DESC
      LIMIT 5
    `);

    const avgQuizScore = await pool.query(`
      SELECT COALESCE(AVG(score), 0) AS avg_score
      FROM user_topic_progress
      WHERE score IS NOT NULL
    `);

    res.json({
      usersByLevel: usersByLevel.rows,
      topFields: topFields.rows,
      avgQuizScore: Number(avgQuizScore.rows[0]?.avg_score || 0),
    });
  } catch (err) {
    console.error("ADMIN ANALYTICS ERROR:", err);
    res.status(500).json({ message: "Failed to fetch analytics" });
  }
});

// ================== START SERVER ==================
async function startServer() {
  try {
    await pool.query("SELECT 1");
    console.log("✅ Connected to PostgreSQL successfully");

    app.listen(PORT, () => {
      console.log(`✅ Server running on http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error("❌ Failed to connect to PostgreSQL:", err.message);
  }
}

startServer();