import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import Navbar from "../components/Navbar";
import "./GradesPage.css";

function GradesPage() {
  const [gradesData, setGradesData] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  const user = useMemo(
    () =>
      JSON.parse(localStorage.getItem("user")) ||
      JSON.parse(sessionStorage.getItem("user")),
    []
  );

  const selectedField = sessionStorage.getItem("selectedField") || "";

  useEffect(() => {
    const loadGrades = async () => {
      if (!user?.id) {
        setLoading(false);
        navigate("/login");
        return;
      }

      if (!selectedField) {
        navigate("/select-field/grades");
        return;
      }

      try {
        const res = await fetch(
          `http://localhost:5001/user/${user.id}/grades-summary`
        );
        const data = await res.json();

        if (!res.ok) {
          throw new Error(data.message || "Failed to load grades data");
        }

        setGradesData(data);
      } catch (error) {
        console.error("GRADES PAGE ERROR:", error);
      } finally {
        setLoading(false);
      }
    };

    loadGrades();
  }, [navigate, selectedField, user]);

  if (loading) {
    return (
      <>
        <Navbar />
        <main className="grades-page">
          <div className="grades-hero-card">
            <h1>Grades</h1>
            <p>Loading grades...</p>
          </div>
        </main>
      </>
    );
  }

  const userData = gradesData?.user || {};
  const summary = gradesData?.summary || {};
  const topicScores = gradesData?.topic_scores || [];

  const placementScore = summary?.placement_score ?? 0;
  const currentLevel = summary?.current_level || "Not determined yet";
  const currentField = selectedField || userData?.field || user?.field || "";

  const filteredTopicScores = topicScores.filter((topic) => {
    const topicField = String(topic?.field_name || "").trim();
    return topicField === currentField;
  });

  const attemptedFilteredTopics = filteredTopicScores.filter(
    (topic) => Number(topic?.score || 0) > 0
  );

  const completedFilteredTopics = filteredTopicScores.filter(
    (topic) => topic?.status === "completed"
  );

  const averageTopicScore = attemptedFilteredTopics.length
    ? Math.round(
        attemptedFilteredTopics.reduce(
          (sum, topic) => sum + Number(topic?.score || 0),
          0
        ) / attemptedFilteredTopics.length
      )
    : 0;

  const completedTopics = completedFilteredTopics.length;
  const attemptedTopics = attemptedFilteredTopics.length;

  const getPerformanceLabel = () => {
    if (averageTopicScore >= 80 || placementScore >= 80) {
      return "Excellent Progress";
    }
    if (averageTopicScore >= 60 || placementScore >= 60) {
      return "Good Progress";
    }
    if (averageTopicScore > 0 || placementScore > 0) {
      return "Needs More Practice";
    }
    return "Not Available";
  };

  const formatStatus = (status) => {
    if (!status) return "Unknown";
    return status.charAt(0).toUpperCase() + status.slice(1);
  };

  const formatDate = (dateValue) => {
    if (!dateValue) return "—";
    const date = new Date(dateValue);
    if (Number.isNaN(date.getTime())) return "—";
    return date.toLocaleDateString();
  };

  const renderScore = (topic) => {
    if (topic?.status !== "completed" && Number(topic?.score || 0) === 0) {
      return "—";
    }
    return `${topic?.score ?? 0}%`;
  };

  return (
    <>
      <Navbar />

      <main className="grades-page">
        <section className="grades-hero-card">
          <div className="grades-badge">Performance Overview</div>
          <h1>Your Grades & Progress</h1>
          <p>
            Review your placement result, current level, and your performance
            across your selected roadmap topics inside Cognito.
          </p>
        </section>

        <section className="grades-summary-grid">
          <div className="grades-stat-card">
            <h3>Placement Test Score</h3>
            <p>{placementScore}%</p>
          </div>

          <div className="grades-stat-card">
            <h3>Current Level</h3>
            <p>{currentLevel}</p>
          </div>

          <div className="grades-stat-card">
            <h3>Performance</h3>
            <p>{getPerformanceLabel()}</p>
          </div>
        </section>

        <section className="grades-summary-grid grades-summary-grid-secondary">
          <div className="grades-stat-card">
            <h3>Average Topic Score</h3>
            <p>{averageTopicScore}%</p>
          </div>

          <div className="grades-stat-card">
            <h3>Completed Topics</h3>
            <p>{completedTopics}</p>
          </div>

          <div className="grades-stat-card">
            <h3>Attempted Topics</h3>
            <p>{attemptedTopics}</p>
          </div>
        </section>

        <section className="grades-main-grid">
          <div className="grades-card">
            <h2>Placement Test Analysis</h2>

            <div className="score-bar-wrapper">
              <div className="score-bar">
                <div
                  className="score-fill"
                  style={{ width: `${placementScore}%` }}
                ></div>
              </div>
              <span className="score-percent">{placementScore}%</span>
            </div>

            <p className="grades-description">
              This score helps determine your current level and guides your
              roadmap progression across the platform.
            </p>
          </div>

          <div className="grades-card">
            <h2>Current Academic Snapshot</h2>

            <div className="grades-info-box">
              <p>
                <strong>Name:</strong> {userData?.name || "N/A"}
              </p>
              <p>
                <strong>Email:</strong> {userData?.email || "N/A"}
              </p>
              <p>
                <strong>Selected Field:</strong> {currentField || "Not selected yet"}
              </p>
              <p>
                <strong>Detected Level:</strong> {currentLevel}
              </p>
            </div>
          </div>
        </section>

        <section className="grades-card grades-topics-card">
          <div className="grades-topics-header">
            <div>
              <h2>Topic Grades</h2>
              <p className="grades-topics-subtitle">
                Here is your performance across your selected roadmap only.
              </p>
            </div>
          </div>

          {filteredTopicScores.length === 0 ? (
            <div className="grades-empty-state">
              No topic grades available yet for your selected roadmap. Start
              solving topic quizzes to see your progress here.
            </div>
          ) : (
            <div className="grades-table-wrapper">
              <table className="grades-table">
                <thead>
                  <tr>
                    <th>Topic</th>
                    <th>Field</th>
                    <th>Status</th>
                    <th>Score</th>
                    <th>Completed At</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredTopicScores.map((topic) => (
                    <tr key={`${topic.topic_id}-${topic.topic_order}`}>
                      <td>{topic.topic_title || "Untitled Topic"}</td>
                      <td>{topic.field_name || "—"}</td>
                      <td>
                        <span
                          className={`status-badge ${
                            topic.status || "unknown"
                          }`}
                        >
                          {formatStatus(topic.status)}
                        </span>
                      </td>
                      <td>{renderScore(topic)}</td>
                      <td>{formatDate(topic.completed_at)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>
      </main>
    </>
  );
}

export default GradesPage;