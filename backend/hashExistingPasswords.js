import dotenv from "dotenv";
import bcrypt from "bcrypt";
import pkg from "pg";

dotenv.config();

const { Pool } = pkg;

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: Number(process.env.DB_PORT),
});

async function hashExistingPasswords() {
  try {
    const users = await pool.query(`
      SELECT id, password
      FROM users
      WHERE auth_provider = 'local'
    `);

    for (const user of users.rows) {
      const password = user.password || "";

      if (password.startsWith("$2b$") || password.startsWith("$2a$")) {
        console.log(`User ${user.id} already hashed`);
        continue;
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      await pool.query(
        `
        UPDATE users
        SET password = $1
        WHERE id = $2
        `,
        [hashedPassword, user.id]
      );

      console.log(`User ${user.id} password hashed`);
    }

    console.log("Done hashing existing passwords");
  } catch (err) {
    console.error("Hashing error:", err);
  } finally {
    await pool.end();
  }
}

hashExistingPasswords();