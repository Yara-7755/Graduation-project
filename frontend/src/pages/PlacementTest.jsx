import { useEffect, useState, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import "./PlacementTest.css";

const TEST_DURATION = 15 * 60; // 15 minutes

function PlacementTest() {
  const navigate = useNavigate();

  const user = useMemo(
    () =>
      JSON.parse(localStorage.getItem("user")) ||
      JSON.parse(sessionStorage.getItem("user")),
    []
  );

  const [questions, setQuestions] = useState([]);
  const [answers, setAnswers] = useState({});
  const [submitted, setSubmitted] = useState(false);
  const [result, setResult] = useState(null);
  const [timeLeft, setTimeLeft] = useState(TEST_DURATION);
  const [loading, setLoading] = useState(true);
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);

  useEffect(() => {
    const checkUserAndLoadQuestions = async () => {
      if (!user || !user.id) {
        navigate("/login");
        return;
      }

      try {
        const userRes = await fetch(`http://localhost:5001/user/${user.id}`);
        const userData = await userRes.json();

        if (!userRes.ok) {
          alert(userData.message || "Failed to load user data");
          navigate("/login");
          return;
        }

        if (userData.level) {
          alert("You have already completed the placement test.");
          navigate("/dashboard");
          return;
        }

        const questionsRes = await fetch(
"http://localhost:5001/placement-test/questions"        );
        const questionsData = await questionsRes.json();

        if (!questionsRes.ok) {
          alert(questionsData.message || "Failed to load questions");
          return;
        }

        setQuestions(questionsData);
      } catch (error) {
        console.error(error);
        alert("Failed to load placement test");
      } finally {
        setLoading(false);
      }
    };

    checkUserAndLoadQuestions();
  }, [user, navigate]);

  useEffect(() => {
    if (submitted || loading || questions.length === 0) return;

    if (timeLeft <= 0) {
      handleSubmit();
      return;
    }

    const timer = setInterval(() => {
      setTimeLeft((prev) => prev - 1);
    }, 1000);

    return () => clearInterval(timer);
  }, [timeLeft, submitted, loading, questions.length]);

  const handleSelect = (id, choice) => {
    setAnswers((prev) => ({ ...prev, [id]: choice }));
  };

  const handleNext = () => {
    if (currentQuestionIndex < questions.length - 1) {
      setCurrentQuestionIndex((prev) => prev + 1);
    }
  };

  const handlePrevious = () => {
    if (currentQuestionIndex > 0) {
      setCurrentQuestionIndex((prev) => prev - 1);
    }
  };

  const handleSubmit = async () => {
    if (submitted) return;

    if (!user || !user.id) {
      alert("User not found. Please login again.");
      navigate("/login");
      return;
    }

    const formattedAnswers = Object.entries(answers).map(([id, ans]) => ({
      questionId: Number(id),
      answer: ans,
    }));

    if (formattedAnswers.length === 0) {
      alert("Please answer at least one question.");
      return;
    }

    try {
      const res = await fetch("http://localhost:5001/placement-test/submit", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          userId: user.id,
          answers: formattedAnswers,
        }),
      });

      const data = await res.json();

      if (!res.ok) {
        alert(data.message || "Failed to submit test");

        if (data.message === "Placement test already completed") {
          navigate("/dashboard");
        }
        return;
      }

      setResult(data);
      setSubmitted(true);

      const updatedUser = {
        ...user,
        level: data.level,
        placement_score: data.score,
      };

      if (localStorage.getItem("user")) {
        localStorage.setItem("user", JSON.stringify(updatedUser));
      } else {
        sessionStorage.setItem("user", JSON.stringify(updatedUser));
      }
    } catch (error) {
      console.error(error);
      alert("Server error while submitting test");
    }
  };

  const minutes = Math.floor(timeLeft / 60);
  const seconds = timeLeft % 60;

  if (loading) {
    return <p className="loading">Loading placement test...</p>;
  }

  const currentQuestion = questions[currentQuestionIndex];
  const progress =
    questions.length > 0
      ? ((currentQuestionIndex + 1) / questions.length) * 100
      : 0;

  return (
    <div className="placement-page">
      <div className="placement-bg">
        <div className="grid-overlay"></div>
        <div className="radial-glow glow-1"></div>
        <div className="radial-glow glow-2"></div>
        <div className="radial-glow glow-3"></div>
        <span className="light-line line-1"></span>
        <span className="light-line line-2"></span>
        <span className="light-line line-3"></span>
      </div>

      <div className="placement-card">
        <div className="placement-badge">Assessment Mode</div>

        <div className="timer">
          ⏱️ Time Left: {minutes}:{seconds.toString().padStart(2, "0")}
        </div>

        <h1>Placement Test</h1>
        <p className="placement-subtitle">
          Answer the questions to discover your current IT level and continue
          your learning journey in Cognito.
        </p>

        {!submitted && questions.length > 0 && (
          <>
            <div className="progress-info">
              <span>
                Question {currentQuestionIndex + 1} of {questions.length}
              </span>
              <span>{Math.round(progress)}%</span>
            </div>

            <div className="progress-bar">
              <div
                className="progress-fill"
                style={{ width: `${progress}%` }}
              ></div>
            </div>

            <div className="question-box single-question-card">
              <h3>
                {currentQuestionIndex + 1}.{" "}
                {currentQuestion.question_text ?? currentQuestion.question}
              </h3>

              <div className="options-list">
                {[
                  ["A", currentQuestion.option_a],
                  ["B", currentQuestion.option_b],
                  ["C", currentQuestion.option_c],
                  ["D", currentQuestion.option_d],
                ].map(([key, text]) => (
                  <label
                    key={key}
                    className={`option-card ${
                      answers[currentQuestion.id] === key ? "selected" : ""
                    }`}
                  >
                    <input
                      type="radio"
                      name={`q-${currentQuestion.id}`}
                      checked={answers[currentQuestion.id] === key}
                      onChange={() => handleSelect(currentQuestion.id, key)}
                    />
                    <span className="option-key">{key}</span>
                    <span className="option-text">{text}</span>
                  </label>
                ))}
              </div>
            </div>

            <div className="question-navigation">
              <button
                className="nav-btn outline"
                onClick={handlePrevious}
                disabled={currentQuestionIndex === 0}
              >
                Previous
              </button>

              {currentQuestionIndex < questions.length - 1 ? (
                <button className="nav-btn primary" onClick={handleNext}>
                  Next
                </button>
              ) : (
                <button className="nav-btn secondary" onClick={handleSubmit}>
                  Submit Test
                </button>
              )}
            </div>
          </>
        )}

        {submitted && result && (
          <div className="result-card animate-result">
            <h2>
              Your Score: <span>{result.score}%</span>
            </h2>
            <h3>
              Your Level: <span>{result.level}</span>
            </h3>

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