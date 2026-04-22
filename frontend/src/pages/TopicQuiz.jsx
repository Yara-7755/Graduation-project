import { useEffect, useMemo, useState, useCallback } from "react";
import { useNavigate, useParams } from "react-router-dom";
import axios from "axios";
import Navbar from "../components/Navbar";
import "./TopicQuiz.css";

const API_BASE = "http://localhost:5001";

function getQuestionTypeLabel(questionType, isAiStage) {
  if (!isAiStage) return "Standard Question";
  if (questionType === "output_prediction") return "Output Prediction";
  if (questionType === "find_the_error") return "Find the Error";
  if (questionType === "code_logic") return "Code Logic";
  if (questionType === "fill_the_blank") return "Fill the Blank";
  return "AI Question";
}

function TopicQuiz() {
  const { topicId } = useParams();
  const navigate = useNavigate();

  const user =
    JSON.parse(localStorage.getItem("user")) ||
    JSON.parse(sessionStorage.getItem("user"));

  const storageKey = useMemo(() => {
    return `topic-quiz-progress-${user?.id || "guest"}-${topicId}`;
  }, [topicId, user?.id]);

  const [loading, setLoading] = useState(true);
  const [aiLoading, setAiLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  const [quizStage, setQuizStage] = useState("mcq"); // mcq | ai
  const [result, setResult] = useState(null);

  const [mcqQuestions, setMcqQuestions] = useState([]);
  const [mcqAnswers, setMcqAnswers] = useState({});
  const [mcqIndex, setMcqIndex] = useState(0);
  const [mcqCompleted, setMcqCompleted] = useState(false);
  const [mcqSubmitted, setMcqSubmitted] = useState(false);
  const [mcqResult, setMcqResult] = useState(null);

  const [aiQuestions, setAiQuestions] = useState([]);
  const [aiAnswers, setAiAnswers] = useState({});
  const [aiIndex, setAiIndex] = useState(0);
  const [aiCompleted, setAiCompleted] = useState(false);
  const [aiSubmitted, setAiSubmitted] = useState(false);
  const [aiResult, setAiResult] = useState(null);

  const resetAllState = useCallback(() => {
    setError("");
    setResult(null);

    setQuizStage("mcq");

    setMcqQuestions([]);
    setMcqAnswers({});
    setMcqIndex(0);
    setMcqCompleted(false);
    setMcqSubmitted(false);
    setMcqResult(null);

    setAiQuestions([]);
    setAiAnswers({});
    setAiIndex(0);
    setAiCompleted(false);
    setAiSubmitted(false);
    setAiResult(null);

    localStorage.removeItem(storageKey);
  }, [storageKey]);

  const fetchMcqQuestions = useCallback(async () => {
    if (!user?.id) {
      setError("User not found. Please login again.");
      return;
    }

    const res = await axios.get(
      `${API_BASE}/topic/${topicId}/questions/${user.id}`
    );

    setMcqQuestions(res?.data || []);
  }, [topicId, user?.id]);

  const fetchAiQuestions = useCallback(async () => {
    if (!user?.id) {
      setError("User not found. Please login again.");
      return;
    }

    setAiLoading(true);

    try {
      const res = await axios.post(`${API_BASE}/ai/generate-quiz`, {
        userId: user.id,
        topicId: Number(topicId),
        count: 5,
      });

      setAiQuestions(res?.data?.questions || []);
    } finally {
      setAiLoading(false);
    }
  }, [topicId, user?.id]);

  useEffect(() => {
    let isMounted = true;

    const loadQuiz = async () => {
      try {
        setLoading(true);
        setError("");

        if (!user?.id) {
          setError("User not found. Please login again.");
          return;
        }

        await fetchMcqQuestions();

        const saved = localStorage.getItem(storageKey);

        if (saved && isMounted) {
          const parsed = JSON.parse(saved);

          setQuizStage(parsed.quizStage || "mcq");

          setMcqAnswers(parsed.mcqAnswers || {});
          setMcqIndex(parsed.mcqIndex || 0);
          setMcqCompleted(Boolean(parsed.mcqCompleted));
          setMcqSubmitted(Boolean(parsed.mcqSubmitted));
          setMcqResult(parsed.mcqResult || null);

          setAiQuestions(parsed.aiQuestions || []);
          setAiAnswers(parsed.aiAnswers || {});
          setAiIndex(parsed.aiIndex || 0);
          setAiCompleted(Boolean(parsed.aiCompleted));
          setAiSubmitted(Boolean(parsed.aiSubmitted));
          setAiResult(parsed.aiResult || null);
          setResult(parsed.result || null);
        }
      } catch (err) {
        console.error("LOAD QUIZ ERROR:", err);
        if (isMounted) {
          setError(
            err?.response?.data?.message ||
              "Failed to load quiz. Please try again."
          );
        }
      } finally {
        if (isMounted) {
          setLoading(false);
          setAiLoading(false);
        }
      }
    };

    loadQuiz();

    return () => {
      isMounted = false;
    };
  }, [fetchMcqQuestions, storageKey, user?.id]);

  useEffect(() => {
    if (!user?.id) return;

    localStorage.setItem(
      storageKey,
      JSON.stringify({
        quizStage,
        mcqAnswers,
        mcqIndex,
        mcqCompleted,
        mcqSubmitted,
        mcqResult,
        aiQuestions,
        aiAnswers,
        aiIndex,
        aiCompleted,
        aiSubmitted,
        aiResult,
        result,
      })
    );
  }, [
    storageKey,
    user?.id,
    quizStage,
    mcqAnswers,
    mcqIndex,
    mcqCompleted,
    mcqSubmitted,
    mcqResult,
    aiQuestions,
    aiAnswers,
    aiIndex,
    aiCompleted,
    aiSubmitted,
    aiResult,
    result,
  ]);

  const isAiStage = quizStage === "ai";

  const activeQuestions = isAiStage ? aiQuestions : mcqQuestions;
  const activeAnswers = isAiStage ? aiAnswers : mcqAnswers;
  const currentQuestionIndex = isAiStage ? aiIndex : mcqIndex;
  const currentQuestion = activeQuestions[currentQuestionIndex];
  const totalQuestions = activeQuestions.length;
  const answeredCount = Object.keys(activeAnswers).length;

  const progress =
    totalQuestions > 0
      ? ((currentQuestionIndex + 1) / totalQuestions) * 100
      : 0;

  const totalAnsweredAll = useMemo(() => {
    return Object.keys(mcqAnswers).length + Object.keys(aiAnswers).length;
  }, [mcqAnswers, aiAnswers]);

  const totalAllQuestions = useMemo(() => {
    return mcqQuestions.length + aiQuestions.length;
  }, [mcqQuestions.length, aiQuestions.length]);

  const handleSelect = (questionId, option) => {
    setError("");

    if (isAiStage) {
      setAiAnswers((prev) => ({
        ...prev,
        [questionId]: option,
      }));
    } else {
      setMcqAnswers((prev) => ({
        ...prev,
        [questionId]: option,
      }));
    }
  };

  const handleNext = () => {
    if (currentQuestionIndex < totalQuestions - 1) {
      if (isAiStage) {
        setAiIndex((prev) => prev + 1);
      } else {
        setMcqIndex((prev) => prev + 1);
      }
    }
  };

  const handlePrevious = () => {
    if (currentQuestionIndex > 0) {
      if (isAiStage) {
        setAiIndex((prev) => prev - 1);
      } else {
        setMcqIndex((prev) => prev - 1);
      }
    }
  };

  const handleFinishMcq = async () => {
    try {
      if (!user?.id) {
        setError("User not found. Please login again.");
        return;
      }

      if (mcqQuestions.length === 0) {
        setError("No normal quiz questions available.");
        return;
      }

      if (Object.keys(mcqAnswers).length < mcqQuestions.length) {
        setError("Please answer all multiple choice questions first.");
        return;
      }

      setError("");
      setMcqCompleted(true);
      setQuizStage("ai");

      if (aiQuestions.length === 0) {
        await fetchAiQuestions();
      }
    } catch (err) {
      console.error("FINISH MCQ ERROR:", err);
      setError(
        err?.response?.data?.message ||
          "Failed to prepare AI quiz. Please try again."
      );
    }
  };

  const handleBackToMcq = () => {
    setError("");
    setQuizStage("mcq");
  };

  const submitMcqQuiz = async () => {
    if (mcqSubmitted) return mcqResult;

    const formattedAnswers = mcqQuestions.map((q) => ({
      questionId: q.id,
      answer: mcqAnswers[q.id],
    }));

    const res = await axios.post(`${API_BASE}/topic/submit-quiz`, {
      userId: user.id,
      topicId: Number(topicId),
      answers: formattedAnswers,
    });

    setMcqSubmitted(true);
    setMcqResult(res.data);
    return res.data;
  };

  const submitAiQuiz = async () => {
    if (aiSubmitted) return aiResult;

    const formattedAnswers = aiQuestions.map((q) => ({
      questionId: q.id,
      answer: aiAnswers[q.id],
    }));

    const res = await axios.post(`${API_BASE}/ai/submit-quiz`, {
      userId: user.id,
      topicId: Number(topicId),
      answers: formattedAnswers,
      aiMode: true,
    });

    setAiSubmitted(true);
    setAiResult(res.data);
    return res.data;
  };

  const handleSubmitFinal = async () => {
    try {
      if (!user?.id) {
        setError("User not found. Please login again.");
        return;
      }

      if (aiQuestions.length === 0) {
        setError("No AI questions available.");
        return;
      }

      if (Object.keys(aiAnswers).length < aiQuestions.length) {
        setError("Please answer all AI questions before submitting.");
        return;
      }

      setSubmitting(true);
      setError("");
      setAiCompleted(true);

      const mcqResponse = await submitMcqQuiz();
      const aiResponse = await submitAiQuiz();

      const combinedScore = Math.round(
        ((Number(mcqResponse?.score || 0) + Number(aiResponse?.score || 0)) / 2)
      );

      const finalPassed =
        Boolean(mcqResponse?.passed) && Boolean(aiResponse?.passed);

      const finalAnalysis = [mcqResponse?.analysis, aiResponse?.analysis]
        .filter(Boolean)
        .join("\n\n");

      const finalResult = {
        passed: finalPassed,
        score: combinedScore,
        message: finalPassed
          ? "Both quiz sections were completed successfully."
          : "One or both sections were not passed. Please try again.",
        analysis: finalAnalysis,
        mcqScore: mcqResponse?.score ?? 0,
        aiScore: aiResponse?.score ?? 0,
      };

      setResult(finalResult);
      localStorage.removeItem(storageKey);
    } catch (err) {
      console.error("FINAL SUBMIT ERROR:", err);
      setError(
        err?.response?.data?.message ||
          "Failed to submit quiz. Please try again."
      );
    } finally {
      setSubmitting(false);
    }
  };

  const handleBack = () => {
    navigate(-1);
  };

  const handleGoTopic = () => {
    navigate(`/topic/${topicId}`);
  };

  const handleGoDashboard = () => {
    navigate("/dashboard");
  };

  const handleRetry = async () => {
    try {
      resetAllState();
      setLoading(true);
      await fetchMcqQuestions();
    } catch (err) {
      console.error("RETRY QUIZ ERROR:", err);
      setError(
        err?.response?.data?.message ||
          "Failed to reload quiz. Please try again."
      );
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <>
        <Navbar />
        <div className="topic-quiz-page">
          <div className="topic-quiz-card">
            <h2>Loading Quiz...</h2>
            <p>Please wait while we prepare your questions.</p>
          </div>
        </div>
      </>
    );
  }

  if (result) {
    return (
      <>
        <Navbar />
        <div className="topic-quiz-page">
          <div className="topic-quiz-card result-card">
            <div className="result-badge">Topic Quiz + AI Quiz</div>

            <h1>{result.passed ? "Quiz Passed 🎉" : "Quiz Not Passed"}</h1>

            <div className="result-box">
              <p>
                <strong>Final Score:</strong> {result.score}%
              </p>
              <p>
                <strong>MCQ Score:</strong> {result.mcqScore ?? 0}%
              </p>
              <p>
                <strong>AI Score:</strong> {result.aiScore ?? 0}%
              </p>
              <p>
                <strong>Status:</strong>{" "}
                {result.passed ? "Completed" : "Try Again"}
              </p>
              {result.message && <p>{result.message}</p>}
            </div>

            {result.analysis && (
              <div className="analysis-box">
                <h3>AI Feedback</h3>
                <pre>{result.analysis}</pre>
              </div>
            )}

            <div className="quiz-actions">
              <button className="nav-btn outline" onClick={handleRetry}>
                Retry Quiz
              </button>

              <button className="nav-btn outline" onClick={handleGoTopic}>
                Back to Topic
              </button>

              <button className="nav-btn primary" onClick={handleGoDashboard}>
                Back to Dashboard
              </button>
            </div>
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <Navbar />

      <div className="topic-quiz-page">
        <div className="topic-quiz-card">
          <div className="quiz-topbar">
            <button className="back-btn" onClick={handleBack}>
              ← Back
            </button>

            <div className="quiz-progress">
              Answered {totalAnsweredAll} / {totalAllQuestions || mcqQuestions.length}
            </div>
          </div>

          <div
            className="quiz-mode-switch"
            style={{ pointerEvents: "none", opacity: 0.95 }}
          >
            <button className={`mode-btn ${!isAiStage ? "active" : ""}`}>
              1. Normal Quiz
            </button>

            <button className={`mode-btn ${isAiStage ? "active" : ""}`}>
              2. AI Smart Quiz 🤖
            </button>
          </div>

          <h1 className="quiz-title">
            {isAiStage ? "AI Topic Quiz" : "Topic Quiz"}
          </h1>

          <p className="quiz-subtitle">
            {isAiStage
              ? "Complete the AI-generated section to finish this topic."
              : "Finish the normal quiz first, then continue to the AI section."}
          </p>

          {mcqCompleted && !isAiStage && (
            <div className="analysis-box">
              <h3>Normal Quiz Completed</h3>
              <p>You already finished the first section. Continue to AI when ready.</p>
            </div>
          )}

          {isAiStage && (
            <div className="analysis-box">
              <h3>Final Step</h3>
              <p>
                The AI section is required. Your MCQ progress is saved and will not be lost.
              </p>
            </div>
          )}

          {error && <div className="quiz-error">{error}</div>}

          {aiLoading && (
            <div className="ai-loading-box">
              <div className="ai-spinner"></div>
              <h3>AI is generating your quiz...</h3>
              <p>Please wait a few seconds while smart questions are prepared.</p>
            </div>
          )}

          {!aiLoading && activeQuestions.length === 0 ? (
            <div className="quiz-empty">
              <p>
                {isAiStage
                  ? "No AI quiz questions were generated for this topic."
                  : "No quiz questions found for this topic."}
              </p>
            </div>
          ) : null}

          {!aiLoading && activeQuestions.length > 0 && currentQuestion && (
            <>
              <div className="progress-info">
                <span>
                  {isAiStage ? "AI Question" : "Question"} {currentQuestionIndex + 1} of{" "}
                  {totalQuestions}
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
                <div className="question-header-row">
                  <span className="question-type-badge">
                    {getQuestionTypeLabel(currentQuestion.question_type, isAiStage)}
                  </span>
                </div>

                <div className="question-title">
                  <span className="question-number">
                    {currentQuestionIndex + 1}.
                  </span>
                  <span>
                    {currentQuestion.question_text || currentQuestion.question}
                  </span>
                </div>

                {currentQuestion.code_snippet && (
                  <div className="code-block">
                    <pre>
                      <code>{currentQuestion.code_snippet}</code>
                    </pre>
                  </div>
                )}

                <div className="options-list">
                  {[
                    ["A", currentQuestion.option_a],
                    ["B", currentQuestion.option_b],
                    ["C", currentQuestion.option_c],
                    ["D", currentQuestion.option_d],
                  ]
                    .filter(
                      ([, text]) =>
                        text !== undefined && text !== null && text !== ""
                    )
                    .map(([key, text]) => (
                      <label
                        key={key}
                        className={`option-card ${
                          activeAnswers[currentQuestion.id] === key ? "selected" : ""
                        }`}
                      >
                        <input
                          type="radio"
                          name={`q-${currentQuestion.id}`}
                          checked={activeAnswers[currentQuestion.id] === key}
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
                  disabled={currentQuestionIndex === 0 || submitting}
                >
                  Previous
                </button>

                {currentQuestionIndex < totalQuestions - 1 ? (
                  <button
                    className="nav-btn primary"
                    onClick={handleNext}
                    disabled={submitting}
                  >
                    Next
                  </button>
                ) : isAiStage ? (
                  <>
                    <button
                      className="nav-btn outline"
                      onClick={handleBackToMcq}
                      disabled={submitting}
                    >
                      Back to MCQ
                    </button>

                    <button
                      className="nav-btn secondary"
                      onClick={handleSubmitFinal}
                      disabled={submitting}
                    >
                      {submitting ? "Submitting Final Quiz..." : "Submit Final Quiz"}
                    </button>
                  </>
                ) : (
                  <button
                    className="nav-btn secondary"
                    onClick={handleFinishMcq}
                    disabled={submitting}
                  >
                    Continue to AI Quiz
                  </button>
                )}
              </div>
            </>
          )}
        </div>
      </div>
    </>
  );
}

export default TopicQuiz;