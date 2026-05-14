import { useState } from "react";

const API_URL = "http://localhost:5001";

const fields = [
  "Frontend Development",
  "Backend Development",
  "Programming Fundamentals",
  "Mobile Development",
];

const languagesByField = {
  "Frontend Development": ["JavaScript", "HTML", "CSS", "React"],
  "Backend Development": ["JavaScript", "Node.js", "Express"],
  "Programming Fundamentals": ["JavaScript", "Java", "C++", "Python"],
  "Mobile Development": ["Dart", "Flutter", "Kotlin", "React Native"],
};

export default function CodeReviewPage() {
  const [fieldName, setFieldName] = useState("Frontend Development");
  const [language, setLanguage] = useState("JavaScript");
  const [code, setCode] = useState("");
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  const languages = languagesByField[fieldName] || [];

  function handleFieldChange(value) {
    setFieldName(value);
    setLanguage(languagesByField[value][0]);
  }

  async function reviewCode() {
    if (!code.trim()) {
      alert("Please write code first");
      return;
    }

    setLoading(true);
    setResult(null);

    try {
      const res = await fetch(`${API_URL}/ai/code-review`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          fieldName,
          language,
          code,
        }),
      });

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.message || "Failed to review code");
      }

      setResult(data);
    } catch (err) {
      alert(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div style={{ padding: "40px", maxWidth: "1100px", margin: "0 auto" }}>
      <h1>AI Code Review</h1>
      <p>Write your code and let Cognito AI review, correct, and explain it.</p>

      <div style={{ display: "flex", gap: "15px", margin: "25px 0" }}>
        <select value={fieldName} onChange={(e) => handleFieldChange(e.target.value)}>
          {fields.map((field) => (
            <option key={field} value={field}>
              {field}
            </option>
          ))}
        </select>

        <select value={language} onChange={(e) => setLanguage(e.target.value)}>
          {languages.map((lang) => (
            <option key={lang} value={lang}>
              {lang}
            </option>
          ))}
        </select>
      </div>

      <textarea
        value={code}
        onChange={(e) => setCode(e.target.value)}
        placeholder="Write your code here..."
        style={{
          width: "100%",
          minHeight: "260px",
          padding: "15px",
          fontFamily: "monospace",
          fontSize: "15px",
          borderRadius: "12px",
          border: "1px solid #ccc",
        }}
      />

      <button
        onClick={reviewCode}
        disabled={loading}
        style={{
          marginTop: "20px",
          padding: "12px 25px",
          borderRadius: "10px",
          border: "none",
          background: "#0b3c78",
          color: "white",
          cursor: "pointer",
        }}
      >
        {loading ? "Reviewing..." : "Review Code"}
      </button>

      {result && (
        <div style={{ marginTop: "35px" }}>
          <h2>Review Result</h2>

          <h3>Errors</h3>
          {result.errors?.length ? (
            <ul>
              {result.errors.map((err, index) => (
                <li key={index}>{err}</li>
              ))}
            </ul>
          ) : (
            <p>No major errors found.</p>
          )}

          <h3>Corrected Code</h3>
          <pre
            style={{
              background: "#111827",
              color: "#e5e7eb",
              padding: "18px",
              borderRadius: "12px",
              overflowX: "auto",
            }}
          >
            {result.correctedCode}
          </pre>

          <h3>Explanation</h3>
          <p>{result.explanation}</p>

          <h3>Tips</h3>
          <ul>
            {result.tips?.map((tip, index) => (
              <li key={index}>{tip}</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}