import { useEffect, useMemo, useState, useCallback } from "react";
import { useNavigate, useParams } from "react-router-dom";
import axios from "axios";
import Navbar from "../components/Navbar";
import "./TopicQuiz.css";

const API_BASE = "http://localhost:5001";

function getStoredUser() {
  try {
    return (
      JSON.parse(localStorage.getItem("user")) ||
      JSON.parse(sessionStorage.getItem("user"))
    );
  } catch {
    return null;
  }
}

function getQuestionText(q) {
  return q.question || q.question_text || "Question";
}

function getOptionText(q, opt) {
  const key = `option_${opt.toLowerCase()}`;
  return q[key] || "";
}

function getQuestionTypeLabel(questionType, isAiStage) {
  if (!isAiStage) return "Standard Question";
  if (questionType === "output_prediction") return "Output Prediction";
  if (questionType === "find_the_error") return "Find the Error";
  if (questionType === "code_logic") return "Code Logic";
  if (questionType === "fill_the_blank") return "Fill the Blank";
  return "AI Code Question";
}

function getAiFeedback(data) {
  return (
    data?.feedback ||
    data?.aiFeedback ||
    data?.analysis ||
    data?.message ||
    data?.result?.feedback ||
    data?.result?.analysis ||
    ""
  );
}

function getCodingScore(data) {
  return Number(
    data?.score ||
      data?.ai_score ||
      data?.result?.score ||
      data?.grade ||
      0
  );
}

function TopicQuiz() {
  const { topicId } = useParams();
  const navigate = useNavigate();
  const user = getStoredUser();

  const storageKey = useMemo(
    () => `topic-quiz-progress-${user?.id || "guest"}-${topicId}`,
    [topicId, user?.id]
  );

  const [loading, setLoading] = useState(true);
  const [aiLoading, setAiLoading] = useState(false);
  const [codingLoading, setCodingLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  const [quizStage, setQuizStage] = useState("mcq");
  const [result, setResult] = useState(null);

  const [mcqQuestions, setMcqQuestions] = useState([]);
  const [mcqAnswers, setMcqAnswers] = useState({});
  const [mcqIndex, setMcqIndex] = useState(0);

  const [aiQuestions, setAiQuestions] = useState([]);
  const [aiAnswers, setAiAnswers] = useState({});
  const [aiIndex, setAiIndex] = useState(0);

  const [codingQuestion, setCodingQuestion] = useState(null);
  const [codingAnswer, setCodingAnswer] = useState("");
  const [codingResult, setCodingResult] = useState(null);

  const [mcqScore, setMcqScore] = useState(0);
  const [aiScore, setAiScore] = useState(0);
  const [aiSubmitFeedback, setAiSubmitFeedback] = useState("");

  const isCodingStage = quizStage === "coding";

  const currentQuestions = quizStage === "mcq" ? mcqQuestions : aiQuestions;
  const currentIndex = quizStage === "mcq" ? mcqIndex : aiIndex;
  const currentQuestion = currentQuestions[currentIndex];
  const currentAnswers = quizStage === "mcq" ? mcqAnswers : aiAnswers;
  const totalQuestions = currentQuestions.length;

  const answeredCount =
    quizStage === "mcq"
      ? Object.keys(mcqAnswers).length
      : quizStage === "ai"
      ? Object.keys(aiAnswers).length
      : codingAnswer.trim()
      ? 1
      : 0;

  const progressPercent = isCodingStage
    ? codingResult
      ? 100
      : codingAnswer.trim()
      ? 70
      : 30
    : totalQuestions
    ? Math.round(((currentIndex + 1) / totalQuestions) * 100)
    : 0;

  const fetchMcqQuestions = useCallback(async () => {
    if (!user?.id) {
      navigate("/login");
      return;
    }

    const res = await axios.get(
      `${API_BASE}/topic/${topicId}/questions/${user.id}`
    );

    setMcqQuestions(Array.isArray(res.data) ? res.data : []);
  }, [topicId, user?.id, navigate]);

  const fetchAiQuestions = useCallback(async () => {
    if (!user?.id) return;

    setAiLoading(true);
    setError("");

    try {
      const res = await axios.post(`${API_BASE}/ai/generate-quiz`, {
        userId: user.id,
        topicId: Number(topicId),
        count: 5,
      });

      const questions = res.data?.questions || res.data || [];
      setAiQuestions(Array.isArray(questions) ? questions : []);
      setAiIndex(0);
    } catch (err) {
      console.error(err);
      setError("Failed to load AI quiz questions.");
    } finally {
      setAiLoading(false);
    }
  }, [topicId, user?.id]);

  useEffect(() => {
    async function load() {
      try {
        setLoading(true);
        setError("");
        await fetchMcqQuestions();
      } catch (err) {
        console.error(err);
        setError("Failed to load quiz questions.");
      } finally {
        setLoading(false);
      }
    }

    load();
  }, [fetchMcqQuestions]);

  useEffect(() => {
    const saved = localStorage.getItem(storageKey);
    if (!saved) return;

    try {
      const parsed = JSON.parse(saved);
      setQuizStage(parsed.quizStage || "mcq");
      setMcqAnswers(parsed.mcqAnswers || {});
      setMcqIndex(parsed.mcqIndex || 0);
      setAiAnswers(parsed.aiAnswers || {});
      setAiIndex(parsed.aiIndex || 0);
      setCodingAnswer(parsed.codingAnswer || "");
      setMcqScore(parsed.mcqScore || 0);
      setAiScore(parsed.aiScore || 0);
      setAiSubmitFeedback(parsed.aiSubmitFeedback || "");
    } catch {
      localStorage.removeItem(storageKey);
    }
  }, [storageKey]);

  useEffect(() => {
    if (result) return;

    localStorage.setItem(
      storageKey,
      JSON.stringify({
        quizStage,
        mcqAnswers,
        mcqIndex,
        aiAnswers,
        aiIndex,
        codingAnswer,
        mcqScore,
        aiScore,
        aiSubmitFeedback,
      })
    );
  }, [
    storageKey,
    quizStage,
    mcqAnswers,
    mcqIndex,
    aiAnswers,
    aiIndex,
    codingAnswer,
    mcqScore,
    aiScore,
    aiSubmitFeedback,
    result,
  ]);

  function selectAnswer(questionId, option) {
    if (quizStage === "mcq") {
      setMcqAnswers((prev) => ({ ...prev, [questionId]: option }));
    } else {
      setAiAnswers((prev) => ({ ...prev, [questionId]: option }));
    }
  }

  function goNext() {
    if (currentIndex < totalQuestions - 1) {
      if (quizStage === "mcq") setMcqIndex((prev) => prev + 1);
      else setAiIndex((prev) => prev + 1);
    }
  }

  function goPrev() {
    if (currentIndex > 0) {
      if (quizStage === "mcq") setMcqIndex((prev) => prev - 1);
      else setAiIndex((prev) => prev - 1);
    }
  }

  async function startAiStage() {
    const allMcqAnswered = mcqQuestions.every((q) => mcqAnswers[q.id]);

    if (!allMcqAnswered) {
      setError("Please answer all standard questions first.");
      return;
    }

    setError("");
    setQuizStage("ai");

    if (aiQuestions.length === 0) {
      await fetchAiQuestions();
    }
  }

  async function startCodingStage() {
    const allAiAnswered = aiQuestions.every((q) => aiAnswers[q.id]);

    if (!allAiAnswered) {
      setError("Please answer all AI questions first.");
      return;
    }

    try {
      setCodingLoading(true);
      setError("");

      const mcqRes = await axios.post(`${API_BASE}/topic/submit-quiz`, {
        userId: user.id,
        topicId: Number(topicId),
        answers: mcqQuestions.map((q) => ({
          questionId: q.id,
          answer: mcqAnswers[q.id],
        })),
      });

      const aiRes = await axios.post(`${API_BASE}/ai/submit-quiz`, {
        userId: user.id,
        topicId: Number(topicId),
        answers: aiQuestions.map((q) => ({
          questionId: q.id,
          answer: aiAnswers[q.id],
        })),
        aiMode: true,
      });

      const mcqCalculatedScore = Number(mcqRes.data?.score || 0);
      const aiCalculatedScore = Number(aiRes.data?.score || 0);
      const feedback = getAiFeedback(aiRes.data);

      setMcqScore(mcqCalculatedScore);
      setAiScore(aiCalculatedScore);
      setAiSubmitFeedback(feedback);

      const codingRes = await axios.post(
        `${API_BASE}/ai/generate-coding-question`,
        {
          userId: user.id,
          topicId: Number(topicId),
          mcqScore: mcqCalculatedScore,
          aiScore: aiCalculatedScore,
        }
      );

      setCodingQuestion(codingRes.data);
      setCodingAnswer(codingRes.data?.starter_code || "");
      setCodingResult(null);
      setQuizStage("coding");
    } catch (err) {
      console.error(err);
      setError("Failed to generate coding question.");
    } finally {
      setCodingLoading(false);
    }
  }

  async function submitCodingAnswer() {
    if (!codingAnswer.trim()) {
      setError("Please write your code first.");
      return;
    }

    if (!codingQuestion) {
      setError("Coding question is not loaded.");
      return;
    }

    try {
      setCodingLoading(true);
      setError("");

      const res = await axios.post(`${API_BASE}/ai/code-review`, {
        fieldName: codingQuestion.field_name || "Programming Fundamentals",
        language: codingQuestion.language || "JavaScript",
        code: codingAnswer,
        questionTitle: codingQuestion.title,
        questionDescription: codingQuestion.description,
        expectedOutput: codingQuestion.expected_output,
      });

      setCodingResult(res.data);
    } catch (err) {
      console.error(err);
      setError("Failed to review code.");
    } finally {
      setCodingLoading(false);
    }
  }

  async function handleSubmitFinal() {
    if (!codingResult) {
      setError("Please submit your coding answer first.");
      return;
    }

    try {
      setSubmitting(true);
      setError("");

      const finalMcqScore = Number(mcqScore || 0);
      const finalAiScore = Number(aiScore || 0);
      const codingScore = getCodingScore(codingResult) || 70;

      const finalScore = Math.round(
        (finalMcqScore + finalAiScore + codingScore) / 3
      );

      const passed = finalScore >= 60;

      const feedback =
        aiSubmitFeedback ||
        codingResult?.explanation ||
        codingResult?.feedback ||
        "";

      localStorage.removeItem(storageKey);

      setResult({
        passed,
        score: finalScore,
        mcqScore: finalMcqScore,
        aiScore: finalAiScore,
        codingScore,
        feedback,
        codingResult,
        message: passed ? "Completed Successfully" : "Try Again",
      });
    } catch (err) {
      console.error(err);
      setError("Failed to submit quiz.");
    } finally {
      setSubmitting(false);
    }
  }

  if (loading) {
    return (
      <>
        <Navbar />
        <main className="topic-quiz-page">
          <div className="topic-quiz-card loading-card">
            <div className="quiz-loader"></div>
            <h2>Loading quiz...</h2>
          </div>
        </main>
      </>
    );
  }

  if (result) {
    return (
      <>
        <Navbar />
        <main className="topic-quiz-page">
          <div className="topic-quiz-card result-card">
            <div className={result.passed ? "result-icon pass" : "result-icon fail"}>
              {result.passed ? "✓" : "!"}
            </div>

            <h1>{result.passed ? "Quiz Passed" : "Quiz Not Passed"}</h1>
            <p className="result-message">{result.message}</p>

            <div className="score-grid">
              <div>
                <span>Final Score</span>
                <strong>{result.score}%</strong>
              </div>
              <div>
                <span>MCQ Score</span>
                <strong>{result.mcqScore}%</strong>
              </div>
              <div>
                <span>AI Score</span>
                <strong>{result.aiScore}%</strong>
              </div>
              <div>
                <span>Coding Score</span>
                <strong>{result.codingScore}%</strong>
              </div>
            </div>

            <div className="ai-feedback-box">
              <div className="ai-feedback-title">
                <span>🤖</span>
                <h3>AI Feedback</h3>
              </div>

              {result.feedback ? (
                <pre>{result.feedback}</pre>
              ) : (
                <p>No AI feedback was returned from the server.</p>
              )}
            </div>

            {result.codingResult && (
              <div className="ai-feedback-box">
                <h3>Coding Review</h3>

                {result.codingResult.errors?.length > 0 && (
                  <>
                    <h4>Errors</h4>
                    <ul>
                      {result.codingResult.errors.map((err, index) => (
                        <li key={index}>{err}</li>
                      ))}
                    </ul>
                  </>
                )}

                <h4>Corrected Code</h4>
                <pre className="code-snippet">
                  <code>
                    {result.codingResult.correctedCode ||
                      result.codingResult.ai_fixed_code ||
                      "No corrected code returned."}
                  </code>
                </pre>

                <h4>Explanation</h4>
                <p>
                  {result.codingResult.explanation ||
                    result.codingResult.feedback ||
                    "No explanation returned."}
                </p>
              </div>
            )}

            <div className="quiz-actions">
              <button className="secondary-btn" onClick={() => window.location.reload()}>
                Retry
              </button>

              <button className="primary-btn" onClick={() => navigate("/dashboard")}>
  Continue Roadmap
</button>

              <button className="secondary-btn" onClick={() => navigate("/dashboard")}>
                Dashboard
              </button>
            </div>
          </div>
        </main>
      </>
    );
  }

  return (
    <>
      <Navbar />

      <main className="topic-quiz-page">
        <section className="topic-quiz-card">
          <div className="quiz-header">
            <div>
              <span className="quiz-badge">
                {quizStage === "mcq"
                  ? "Standard Quiz"
                  : quizStage === "ai"
                  ? "AI Code Quiz"
                  : "Coding Challenge"}
              </span>

              <h1>Topic Quiz</h1>

              {quizStage === "coding" ? (
                <p>Write, submit, and review your code with Cognito AI.</p>
              ) : (
                <p>
                  Question {totalQuestions ? currentIndex + 1 : 0} of {totalQuestions}
                </p>
              )}
            </div>

            <div className="quiz-stage-tabs">
              <button className={quizStage === "mcq" ? "active" : ""}>
                MCQ
              </button>
              <button className={quizStage === "ai" ? "active" : ""}>
                AI
              </button>
              <button className={quizStage === "coding" ? "active" : ""}>
                Coding
              </button>
            </div>
          </div>

          <div className="progress-wrap">
            <div className="progress-bar">
              <span style={{ width: `${progressPercent}%` }}></span>
            </div>
            <small>{answeredCount} answered</small>
          </div>

          {error && <div className="quiz-error">{error}</div>}

          {quizStage === "coding" ? (
            <div className="question-card coding-section">
              {codingLoading && !codingQuestion ? (
                <div className="ai-loading-box">
                  <div className="quiz-loader"></div>
                  <h2>Generating coding question...</h2>
                  <p>Cognito AI is adapting the question to your quiz performance.</p>
                </div>
              ) : codingQuestion ? (
                <>
                  <div className="question-top">
                    <span className="question-number">Coding Challenge</span>
                    <span className="question-type">AI Code Evaluation</span>
                  </div>

                  <h2>{codingQuestion.title || "Coding Question"}</h2>

                  <p>{codingQuestion.description}</p>

                  {codingQuestion.expected_output && (
                    <div className="ai-feedback-box">
                      <h3>Expected Output</h3>
                      <p>{codingQuestion.expected_output}</p>
                    </div>
                  )}

                  {codingQuestion.starter_code && (
                    <>
                      <h3>Starter Code</h3>
                      <pre className="code-snippet">
                        <code>{codingQuestion.starter_code}</code>
                      </pre>
                    </>
                  )}

                  <textarea
                    className="coding-textarea"
                    value={codingAnswer}
                    onChange={(e) => {
                      setCodingAnswer(e.target.value);
                      setCodingResult(null);
                    }}
                    placeholder="Write your code here..."
                  />

                  <button
                    className="primary-btn"
                    disabled={codingLoading}
                    onClick={submitCodingAnswer}
                  >
                    {codingLoading ? "Reviewing..." : "Submit Code"}
                  </button>

                  {codingResult && (
                    <div className="ai-feedback-box">
                      <h3>AI Code Review</h3>

                      <p>
                        <strong>Score:</strong> {getCodingScore(codingResult) || 70}%
                      </p>

                      {codingResult.errors?.length > 0 && (
                        <>
                          <h4>Errors</h4>
                          <ul>
                            {codingResult.errors.map((err, index) => (
                              <li key={index}>{err}</li>
                            ))}
                          </ul>
                        </>
                      )}

                      <h4>Corrected Code</h4>
                      <pre className="code-snippet">
                        <code>
                          {codingResult.correctedCode ||
                            codingResult.ai_fixed_code ||
                            "No corrected code returned."}
                        </code>
                      </pre>

                      <h4>Explanation</h4>
                      <p>
                        {codingResult.explanation ||
                          codingResult.feedback ||
                          "No explanation returned."}
                      </p>
                    </div>
                  )}
                </>
              ) : (
                <div className="empty-quiz">
                  <h2>No coding question available</h2>
                  <p>Could not generate a coding question right now.</p>
                </div>
              )}
            </div>
          ) : aiLoading ? (
            <div className="ai-loading-box">
              <div className="quiz-loader"></div>
              <h2>Generating AI questions...</h2>
              <p>Please wait while Cognito creates personalized code questions.</p>
            </div>
          ) : currentQuestion ? (
            <div className="question-card">
              <div className="question-top">
                <span className="question-number">Q{currentIndex + 1}</span>
                <span className="question-type">
                  {getQuestionTypeLabel(currentQuestion.question_type, quizStage === "ai")}
                </span>
              </div>

              <h2>{getQuestionText(currentQuestion)}</h2>

              {currentQuestion.code_snippet && (
                <pre className="code-snippet">
                  <code>{currentQuestion.code_snippet}</code>
                </pre>
              )}

              <div className="options-grid">
                {["A", "B", "C", "D"].map((opt) => {
                  const selected = currentAnswers[currentQuestion.id] === opt;
                  const optionText = getOptionText(currentQuestion, opt);

                  return (
                    <button
                      key={opt}
                      className={`option-btn ${selected ? "selected" : ""}`}
                      onClick={() => selectAnswer(currentQuestion.id, opt)}
                    >
                      <span className="option-letter">{opt}</span>
                      <span>{optionText || opt}</span>
                    </button>
                  );
                })}
              </div>
            </div>
          ) : (
            <div className="empty-quiz">
              <h2>No questions available</h2>
              <p>This topic does not have questions yet.</p>
            </div>
          )}

          <div className="quiz-footer">
            {quizStage !== "coding" && (
              <button
                className="secondary-btn"
                onClick={goPrev}
                disabled={currentIndex === 0 || aiLoading}
              >
                Previous
              </button>
            )}

            {quizStage !== "coding" && (
              <div className="dots">
                {currentQuestions.map((q, index) => (
                  <button
                    key={q.id || index}
                    className={[
                      index === currentIndex ? "current" : "",
                      currentAnswers[q.id] ? "answered" : "",
                    ].join(" ")}
                    onClick={() =>
                      quizStage === "mcq" ? setMcqIndex(index) : setAiIndex(index)
                    }
                  >
                    {index + 1}
                  </button>
                ))}
              </div>
            )}

            {quizStage === "coding" ? (
              <>
                <button
                  className="secondary-btn"
                  onClick={() => setQuizStage("ai")}
                  disabled={submitting || codingLoading}
                >
                  Back to AI Quiz
                </button>

                <button
                  className="primary-btn"
                  onClick={handleSubmitFinal}
                  disabled={submitting || codingLoading || !codingResult}
                >
                  {submitting ? "Submitting..." : "Submit Final"}
                </button>
              </>
            ) : currentIndex < totalQuestions - 1 ? (
              <button className="primary-btn" onClick={goNext} disabled={aiLoading}>
                Next
              </button>
            ) : quizStage === "mcq" ? (
              <button className="primary-btn" onClick={startAiStage} disabled={aiLoading}>
                Go to AI Quiz
              </button>
            ) : (
              <button
                className="primary-btn"
                onClick={startCodingStage}
                disabled={submitting || aiLoading || codingLoading}
              >
                {codingLoading ? "Generating..." : "Go to Coding Question"}
              </button>
            )}
          </div>
        </section>
      </main>
    </>
  );
}

export default TopicQuiz;