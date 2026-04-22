import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import Navbar from "../components/Navbar";
import "./Topic.css";

function Topic() {
  const { topicId } = useParams();
  const navigate = useNavigate();

  const user =
    JSON.parse(localStorage.getItem("user")) ||
    JSON.parse(sessionStorage.getItem("user"));

  const [topic, setTopic] = useState(null);
  const [resources, setResources] = useState([]);
  const [hasQuiz, setHasQuiz] = useState(false);
  const [quizCount, setQuizCount] = useState(0);
  const [about, setAbout] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchTopicDetails = async () => {
      try {
        if (!user || !user.id) {
          navigate("/login");
          return;
        }

        const accessRes = await fetch(
          `http://localhost:5001/topic/${topicId}/access/${user.id}`
        );
        const accessData = await accessRes.json();

        if (!accessRes.ok) {
          throw new Error(accessData.message || "Access check failed");
        }

        if (accessData.status === "locked") {
          alert("This topic is locked. Complete previous topics first.");
          navigate("/dashboard");
          return;
        }

        const res = await fetch(
          `http://localhost:5001/topic/${topicId}/details/${user.id}`
        );
        const data = await res.json();

        if (!res.ok) {
          throw new Error(data.message || "Failed to load topic details");
        }

        setTopic(data.topic);
        setResources(data.resources || []);
        setHasQuiz(Boolean(data.hasQuiz));
        setQuizCount(data.quizCount || 0);
        setAbout(data.about || "");
      } catch (err) {
        console.error("LOAD TOPIC DETAILS ERROR:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchTopicDetails();
  }, [topicId, user?.id, navigate]);

  const handleStartQuiz = () => {
    navigate(`/topic/${topicId}/quiz`);
  };

  if (loading) {
    return (
      <>
        <Navbar />
        <div className="topic-page">
          <div className="topic-card">Loading topic...</div>
        </div>
      </>
    );
  }

  if (!topic) {
    return (
      <>
        <Navbar />
        <div className="topic-page">
          <div className="topic-card">
            <h2>Topic not found</h2>
            <button className="back-btn" onClick={() => navigate("/dashboard")}>
              Back to Dashboard
            </button>
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <Navbar />
      <div className="topic-page">
        <div className="topic-card">
          <span className="topic-badge">Topic {topic.topic_order}</span>
          <h1>{topic.title}</h1>
          <p className="topic-description">{topic.description}</p>

          <div className="topic-section">
            <h2>About This Topic</h2>
            <p>{about}</p>
          </div>

          <div className="topic-section">
            <h2>Resources</h2>

            {resources.length > 0 ? (
              <div className="resources-list">
                {resources.map((resource) => (
                  <a
                    key={resource.id}
                    href={resource.url}
                    target="_blank"
                    rel="noreferrer"
                    className="resource-card"
                  >
                    <div>
                      <h4>{resource.title}</h4>
                      <p>{resource.type || "VIDEO"}</p>
                    </div>
                    <span>Open</span>
                  </a>
                ))}
              </div>
            ) : (
              <p className="empty-text">
                No resources available for this topic yet.
              </p>
            )}
          </div>

          <div className="topic-section">
            <h2>Quiz</h2>

            {hasQuiz ? (
              <>
                <p>This topic has {quizCount} question(s).</p>
                <button className="quiz-btn" onClick={handleStartQuiz}>
                  Start Quiz
                </button>
              </>
            ) : (
              <button className="quiz-btn disabled" disabled>
                Quiz Not Available
              </button>
            )}
          </div>

          <button className="back-btn" onClick={() => navigate("/dashboard")}>
            Back to Dashboard
          </button>
        </div>
      </div>
    </>
  );
}

export default Topic;