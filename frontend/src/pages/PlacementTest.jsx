import { useEffect, useState, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import "./PlacementTest.css";

const TEST_DURATION = 15 * 60; // 15 minutes

function PlacementTest() {
  const navigate = useNavigate();
  const user = useMemo(() => JSON.parse(localStorage.getItem("user")), []);

  const [questions, setQuestions] = useState([]);
  const [answers, setAnswers] = useState({});
  const [submitted, setSubmitted] = useState(false);
  const [result, setResult] = useState(null);
  const [timeLeft, setTimeLeft] = useState(TEST_DURATION);

  useEffect(() => {
    fetch("http://localhost:5001/placement-test/questions?count=20")
      .then(res => res.json())
      .then(data => setQuestions(data))
      .catch(() => alert("Failed to load questions"));
  }, []);

  // ⏱️ TIMER
  useEffect(() => {
    if (submitted) return;

    if (timeLeft <= 0) {
      handleSubmit(); // auto submit
      return;
    }

    const timer = setInterval(() => {
      setTimeLeft(prev => prev - 1);
    }, 1000);

    return () => clearInterval(timer);
  }, [timeLeft, submitted]);

  const handleSelect = (id, choice) => {
    setAnswers(prev => ({ ...prev, [id]: choice }));
  };

  const handleSubmit = async () => {
    if (submitted) return;

    const formattedAnswers = Object.entries(answers).map(([id, ans]) => ({
      questionId: Number(id),
      answer: ans
    }));

    const res = await fetch("http://localhost:5001/placement-test/submit", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        userId: user.id,
        answers: formattedAnswers
      })
    });

    const data = await res.json();
    setResult(data);
    setSubmitted(true);
  };

  const minutes = Math.floor(timeLeft / 60);
  const seconds = timeLeft % 60;

  return (
    <div className="placement-page">
      <div className="placement-card">

        {/* TIMER */}
        <div className="timer">
          ⏱️ Time Left: {minutes}:{seconds.toString().padStart(2, "0")}
        </div>

        <h1>Placement Test</h1>

        {!submitted &&
          questions.map((q, i) => (
            <div key={q.id} className="question-box">
              <h3>{i + 1}. {q.question}</h3>

              {[
                ["A", q.option_a],
                ["B", q.option_b],
                ["C", q.option_c],
                ["D", q.option_d],
              ].map(([key, text]) => (
                <label key={key} className="option">
                  <input
                    type="radio"
                    name={`q-${q.id}`}
                    onChange={() => handleSelect(q.id, key)}
                  />
                  {text}
                </label>
              ))}
            </div>
          ))}

        {!submitted && (
          <button className="submit-btn" onClick={handleSubmit}>
            Submit Test
          </button>
        )}

        {submitted && result && (
          <div className="result">
            <h2>Your Score: {result.score}%</h2>
            <h3>Your Level: {result.level}</h3>

            <div className="result-actions">
             <button
    className="nav-btn primary"
    onClick={() => navigate("/fields")}
  >
    Choose Path
  </button>

  <button
    className="nav-btn secondary"
    onClick={() => navigate("/dashboard")}
  >
    Go to Dashboard
  </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default PlacementTest;
