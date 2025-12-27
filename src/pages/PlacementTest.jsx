import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import "./PlacementTest.css";

function PlacementTest() {
  const navigate = useNavigate();

  const [questions, setQuestions] = useState([]);
  const [answers, setAnswers] = useState({});
  const [loading, setLoading] = useState(true);
  const [submitted, setSubmitted] = useState(false);
  const [result, setResult] = useState(null);

  const user = useMemo(
    () => JSON.parse(localStorage.getItem("user")),
    []
  );

  const field = localStorage.getItem("field");

  useEffect(() => {
    fetch("http://localhost:5001/placement-test/questions?count=20")
      .then((res) => res.json())
      .then((data) => setQuestions(data))
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const handleSelect = (id, choice) => {
    setAnswers((prev) => ({ ...prev, [id]: choice }));
  };

  const handleSubmit = async () => {
    const formattedAnswers = Object.entries(answers).map(
      ([questionId, answer]) => ({
        questionId: Number(questionId),
        answer,
      })
    );

    const res = await fetch(
      "http://localhost:5001/placement-test/submit",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          userId: user.id,
          field,
          answers: formattedAnswers,
        }),
      }
    );

    const data = await res.json();
    setResult(data);
    setSubmitted(true);
  };

  if (loading) return <p>Loading questions...</p>;

  return (
    <div className="placement-page">
      <div className="placement-card">
        <h1>Placement Test</h1>
        <p className="subtitle">
          Selected field: <b>{field}</b>
        </p>

        {!submitted && (
          <>
            {questions.map((q, index) => (
              <div key={q.id} className="question-box">
                <h3>
                  {index + 1}. {q.question}
                </h3>

                {["A", "B", "C", "D"]
                  .filter((opt) => q[`option_${opt.toLowerCase()}`])
                  .map((opt) => (
                    <label key={opt} className="option">
                      <input
                        type="radio"
                        name={`q-${q.id}`}
                        onChange={() => handleSelect(q.id, opt)}
                      />
                      {q[`option_${opt.toLowerCase()}`]}
                    </label>
                  ))}
              </div>
            ))}

            <button className="submit-btn" onClick={handleSubmit}>
              Submit Test
            </button>
          </>
        )}

        {submitted && (
          <div className="result">
            <h2>Your Score: {result.score}%</h2>
            <h3>Your Level: {result.level}</h3>

            <button
              className="continue-btn"
              onClick={() => navigate("/dashboard")}
            >
              Go to Dashboard
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

export default PlacementTest;
