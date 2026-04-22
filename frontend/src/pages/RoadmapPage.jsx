import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import Navbar from "../components/Navbar";
import AnimatedBackground from "../components/AnimatedBackground";
import "./RoadmapPage.css";

function RoadmapPage() {
  const [roadmapData, setRoadmapData] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const { fieldName } = useParams();

  const storedUser =
    JSON.parse(localStorage.getItem("user")) ||
    JSON.parse(sessionStorage.getItem("user"));

  useEffect(() => {
    const fetchRoadmap = async () => {
      try {
        if (!storedUser || !storedUser.id) {
          navigate("/login");
          return;
        }

        const selectedField =
          sessionStorage.getItem("selectedField") ||
          (fieldName ? decodeURIComponent(fieldName) : "");

        if (!selectedField) {
          navigate("/select-field/roadmap");
          return;
        }

        const userRes = await fetch(
          `http://localhost:5001/user/${storedUser.id}`
        );
        const freshUser = await userRes.json();

        if (!userRes.ok) {
          throw new Error(freshUser.message || "Failed to load user");
        }

        if (localStorage.getItem("user")) {
          localStorage.setItem("user", JSON.stringify(freshUser));
        } else {
          sessionStorage.setItem("user", JSON.stringify(freshUser));
        }

        if (!freshUser.level) {
          navigate("/fields");
          return;
        }

        const roadmapRes = await fetch(
          `http://localhost:5001/roadmap/${encodeURIComponent(
            selectedField
          )}/${encodeURIComponent(freshUser.level)}/${freshUser.id}`
        );

        const roadmapResult = await roadmapRes.json();

        if (!roadmapRes.ok) {
          throw new Error(roadmapResult.message || "Failed to load roadmap");
        }

        setRoadmapData(roadmapResult);
      } catch (err) {
        console.error("ROADMAP LOAD ERROR:", err);
        setRoadmapData(null);
      } finally {
        setLoading(false);
      }
    };

    fetchRoadmap();
  }, [navigate, storedUser, fieldName]);

  if (loading) {
    return (
      <>
        <Navbar />
        <div className="roadmap-page">
          <AnimatedBackground />
          <div className="roadmap-content">
            <p>Loading roadmap...</p>
          </div>
        </div>
      </>
    );
  }

  if (!roadmapData) {
    return (
      <>
        <Navbar />
        <div className="roadmap-page">
          <AnimatedBackground />
          <div className="roadmap-content">
            <p>No roadmap found.</p>
          </div>
        </div>
      </>
    );
  }

  const completedTopics = roadmapData.topics.filter(
    (topic) => topic.status === "completed"
  ).length;

  const progressPercentage = roadmapData.topics.length
    ? Math.round((completedTopics / roadmapData.topics.length) * 100)
    : 0;

  const getTopicScoreText = (topic) => {
    if (topic.status === "locked") return "Locked";
    if (topic.status === "completed") {
      return topic.score !== null && topic.score !== undefined
        ? `${topic.score}%`
        : "Completed";
    }
    return "Not attempted";
  };

  return (
    <>
      <Navbar />

      <div className="roadmap-page">
        <AnimatedBackground />

        <div className="roadmap-content">
          <h1 className="roadmap-title">{roadmapData.roadmap.title}</h1>
          <p className="roadmap-subtitle">{roadmapData.roadmap.description}</p>

          <div className="roadmap-progress-card">
            <div className="progress-header">
              <span>
                Progress: {completedTopics}/{roadmapData.topics.length}
              </span>
              <span>{progressPercentage}%</span>
            </div>

            <div className="progress-bar">
              <div
                className="progress-fill"
                style={{ width: `${progressPercentage}%` }}
              ></div>
            </div>
          </div>

          <div className="topics-grid">
            {roadmapData.topics.map((topic) => (
              <div key={topic.id} className={`topic-card ${topic.status}`}>
                <div className="topic-top">
                  <span className="topic-order">Topic {topic.topic_order}</span>

                  <span className={`topic-status ${topic.status}`}>
                    {topic.status === "locked" && "🔴 Locked"}
                    {topic.status === "unlocked" && "🟢 Available"}
                    {topic.status === "completed" && "✅ Completed"}
                  </span>
                </div>

                <div className="topic-score-box">
                  <span className="topic-score-label">Score</span>
                  <span className={`topic-score-value ${topic.status}`}>
                    {getTopicScoreText(topic)}
                  </span>
                </div>

                <h2>{topic.title}</h2>
                <p>{topic.description}</p>

                {topic.resources?.length > 0 && (
                  <div className="topic-resources">
                    <h4>Resources</h4>
                    {topic.resources.map((resource) => (
                      <a
                        key={resource.id}
                        href={resource.url}
                        target="_blank"
                        rel="noreferrer"
                        className="resource-link"
                      >
                        {resource.type.toUpperCase()} - {resource.title}
                      </a>
                    ))}
                  </div>
                )}

                <div className="topic-actions">
                  {topic.status === "locked" && (
                    <button className="locked-btn" disabled>
                      Locked
                    </button>
                  )}

                  {topic.status === "unlocked" && (
                    <button
                      className="open-btn"
                      onClick={() => navigate(`/topic/${topic.id}`)}
                    >
                      Start Topic
                    </button>
                  )}

                  {topic.status === "completed" && (
                    <button
                      className="open-btn"
                      style={{
                        background:
                          "linear-gradient(135deg, #22c55e, #16a34a)",
                      }}
                      onClick={() => navigate(`/topic/${topic.id}`)}
                    >
                      ✅ Review
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}

export default RoadmapPage;