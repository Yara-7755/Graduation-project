import { useEffect, useMemo, useState, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import Navbar from "../components/Navbar";
import "./Dashboard.css";

function RingGauge({ title, value, suffix = "%", max = 100 }) {
  const safeValue = Math.max(0, Math.min(value || 0, max));
  const percentage = (safeValue / max) * 100;
  const radius = 58;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (percentage / 100) * circumference;

  return (
    <div className="gauge-card">
      <h3>{title}</h3>

      <div className="ring-gauge">
        <svg width="160" height="160" viewBox="0 0 160 160">
          <circle
            className="ring-bg"
            cx="80"
            cy="80"
            r={radius}
            fill="none"
            strokeWidth="12"
          />
          <circle
            className="ring-progress"
            cx="80"
            cy="80"
            r={radius}
            fill="none"
            strokeWidth="12"
            strokeDasharray={circumference}
            strokeDashoffset={offset}
            strokeLinecap="round"
          />
        </svg>

        <div className="ring-value">
          <span className="ring-number">{safeValue}</span>
          <span className="ring-suffix">{suffix}</span>
        </div>
      </div>
    </div>
  );
}

function Dashboard() {
  const navigate = useNavigate();

  const [data, setData] = useState(null);
  const [paths, setPaths] = useState([]);
  const [selectedPaths, setSelectedPaths] = useState([]);
  const [showPersonalInfo, setShowPersonalInfo] = useState(false);

  const [selectedDashboardPath, setSelectedDashboardPath] = useState("");
  const [roadmapProgress, setRoadmapProgress] = useState(0);
  const [topicsStats, setTopicsStats] = useState({
    total: 0,
    completed: 0,
    unlocked: 0,
  });

  const user = useMemo(
    () =>
      JSON.parse(localStorage.getItem("user")) ||
      JSON.parse(sessionStorage.getItem("user")),
    []
  );

  const updateStoredUser = (freshUser) => {
    if (localStorage.getItem("user")) {
      localStorage.setItem("user", JSON.stringify(freshUser));
    } else {
      sessionStorage.setItem("user", JSON.stringify(freshUser));
    }
  };

  const resetRoadmapStats = () => {
    setRoadmapProgress(0);
    setTopicsStats({
      total: 0,
      completed: 0,
      unlocked: 0,
    });
  };

  const loadRoadmapStats = useCallback(
    async (pathName, level, userId) => {
      if (!pathName || !level || !userId) {
        resetRoadmapStats();
        return;
      }

      try {
        const roadmapRes = await fetch(
          `http://localhost:5001/roadmap/${encodeURIComponent(
            pathName
          )}/${encodeURIComponent(level)}/${userId}`
        );

        const roadmapResult = await roadmapRes.json();

        if (!roadmapRes.ok || !Array.isArray(roadmapResult?.topics)) {
          resetRoadmapStats();
          return;
        }

        const total = roadmapResult.topics.length;
        const completed = roadmapResult.topics.filter(
          (topic) => topic.status === "completed"
        ).length;
        const unlocked = roadmapResult.topics.filter(
          (topic) => topic.status !== "locked"
        ).length;

        const progress = total
          ? Math.round((completed / total) * 100)
          : 0;

        setTopicsStats({
          total,
          completed,
          unlocked,
        });
        setRoadmapProgress(progress);
      } catch (err) {
        console.error("ROADMAP STATS ERROR:", err);
        resetRoadmapStats();
      }
    },
    []
  );

  const loadDashboardData = useCallback(async () => {
    if (!user) {
      navigate("/login");
      return;
    }

    try {
      const userRes = await fetch(`http://localhost:5001/user/${user.id}`);
      const userResult = await userRes.json();

      if (!userRes.ok) {
        throw new Error(userResult.message || "Failed to load user");
      }

      setData(userResult);
      updateStoredUser(userResult);

      const pathsRes = await fetch(`http://localhost:5001/user/${user.id}/paths`);
      const pathsResult = await pathsRes.json();

      if (!pathsRes.ok) {
        throw new Error(pathsResult.message || "Failed to load paths");
      }

      const uniquePaths = [];
      const seen = new Set();

      if (userResult?.field && !seen.has(userResult.field)) {
        uniquePaths.push({ path_name: userResult.field });
        seen.add(userResult.field);
      }

      (Array.isArray(pathsResult) ? pathsResult : []).forEach((item) => {
        if (item?.path_name && !seen.has(item.path_name)) {
          uniquePaths.push(item);
          seen.add(item.path_name);
        }
      });

      setPaths(uniquePaths);

      const currentSelected =
        sessionStorage.getItem("dashboardSelectedPath") || "";

      const availablePathNames = uniquePaths.map((p) => p.path_name);

      let nextSelectedPath = "";

      if (currentSelected && availablePathNames.includes(currentSelected)) {
        nextSelectedPath = currentSelected;
      } else {
        nextSelectedPath = availablePathNames[0] || "";
      }

      setSelectedDashboardPath(nextSelectedPath);

      if (nextSelectedPath && userResult?.level) {
        await loadRoadmapStats(nextSelectedPath, userResult.level, user.id);
      } else {
        resetRoadmapStats();
      }
    } catch (err) {
      console.error("DASHBOARD LOAD ERROR:", err);
      resetRoadmapStats();
    }
  }, [loadRoadmapStats, navigate, user]);

  useEffect(() => {
    loadDashboardData();
  }, [loadDashboardData]);

  useEffect(() => {
    if (selectedDashboardPath) {
      sessionStorage.setItem("dashboardSelectedPath", selectedDashboardPath);
    }
  }, [selectedDashboardPath]);

  useEffect(() => {
    if (selectedDashboardPath && data?.level && user?.id) {
      loadRoadmapStats(selectedDashboardPath, data.level, user.id);
    }
  }, [selectedDashboardPath, data?.level, user?.id, loadRoadmapStats]);

  if (!data) return <p className="loading">Loading...</p>;

  const avatarLetter =
    data.name?.charAt(0).toUpperCase() ||
    data.email?.charAt(0).toUpperCase() ||
    "U";

  const handleSelectPath = (pathName) => {
    setSelectedPaths((prev) =>
      prev.includes(pathName)
        ? prev.filter((p) => p !== pathName)
        : [...prev, pathName]
    );
  };

  const handleDeletePaths = async () => {
    if (!window.confirm("Remove selected paths?")) return;

    try {
      const res = await fetch("http://localhost:5001/user/paths", {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          userId: user.id,
          paths: selectedPaths,
        }),
      });

      const result = await res.json();

      if (!res.ok) {
        throw new Error(result.message || "Failed to delete paths");
      }

      setSelectedPaths([]);
      await loadDashboardData();
    } catch (err) {
      console.error("Failed to delete paths", err);
      alert(err.message || "Failed to delete paths");
    }
  };

  const handleOpenRoadmap = (pathName) => {
    if (!pathName || !data.level) {
      alert("You need a level and a selected path first.");
      return;
    }

    sessionStorage.setItem("selectedField", pathName);
    navigate("/select-field/roadmap");
  };

  const placementScore = data.placement_score ?? 0;
  const profileCompletion =
    data.name && data.email && data.phone && data.university_major ? 100 : 75;

  const selectedPathsCount = paths.length;
  const selectedPathLabel = selectedDashboardPath || "No path selected";

  return (
    <>
      <Navbar />

      <main className="dashboard-page">
        <div className="dashboard-bg">
          <div className="grid-overlay"></div>
          <div className="radial-glow glow-1"></div>
          <div className="radial-glow glow-2"></div>
          <div className="radial-glow glow-3"></div>
          <span className="light-line line-1"></span>
          <span className="light-line line-2"></span>
          <span className="light-line line-3"></span>
        </div>

        <section className="dashboard-header">
          <div className="profile">
            <div className="profile-avatar">{avatarLetter}</div>

            <div className="profile-info">
              <div className="dashboard-badge">Learning Overview</div>
              <h1>Welcome back, {data.name || data.email.split("@")[0]} 👋</h1>
              <p className="subtitle">
                Track your progress and continue building your path in Cognito.
              </p>
            </div>
          </div>
        </section>

        <section className="top-grid">
          <div className="card collapsible-card">
            <button
              className="collapse-toggle"
              onClick={() => setShowPersonalInfo((prev) => !prev)}
            >
              <span>Personal Information</span>
              <span className={`collapse-icon ${showPersonalInfo ? "open" : ""}`}>
                ▾
              </span>
            </button>

            {showPersonalInfo && (
              <div className="info-grid">
                <div className="info-item">
                  <span className="info-label">Full Name</span>
                  <span className="info-value">{data.name || "-"}</span>
                </div>

                <div className="info-item">
                  <span className="info-label">Email</span>
                  <span className="info-value">{data.email || "-"}</span>
                </div>

                <div className="info-item">
                  <span className="info-label">Phone</span>
                  <span className="info-value">{data.phone || "-"}</span>
                </div>

                <div className="info-item">
                  <span className="info-label">Major</span>
                  <span className="info-value">
                    {data.university_major || data.universityMajor || "-"}
                  </span>
                </div>
              </div>
            )}
          </div>

          <div className="card path-card">
            <div className="section-title-row">
              <h2>Selected Path(s)</h2>
            </div>

            {paths.length > 0 ? (
              <>
                <label className="path-dropdown-label">Current Dashboard Path</label>
                <select
                  className="path-dropdown"
                  value={selectedDashboardPath}
                  onChange={(e) => setSelectedDashboardPath(e.target.value)}
                >
                  {paths.map((p) => (
                    <option key={p.path_name} value={p.path_name}>
                      {p.path_name}
                    </option>
                  ))}
                </select>

                <p className="path-subtitle">
                  {paths.length} path{paths.length > 1 ? "s" : ""} selected from
                  your learning plan
                </p>

                <div className="paths-list">
                  {paths.map((p) => (
                    <div key={p.path_name} className="path-item">
                      <label className="path-left">
                        <input
                          type="checkbox"
                          checked={selectedPaths.includes(p.path_name)}
                          onChange={() => handleSelectPath(p.path_name)}
                        />
                        <span>{p.path_name}</span>
                      </label>

                      <button
                        className="mini-open-btn"
                        onClick={() => handleOpenRoadmap(p.path_name)}
                      >
                        Open Roadmap
                      </button>
                    </div>
                  ))}
                </div>

                <button
                  className="delete-paths-btn"
                  onClick={handleDeletePaths}
                  disabled={selectedPaths.length === 0}
                >
                  Delete Selected Path(s)
                </button>
              </>
            ) : (
              <div className="empty-path-box">
                <p className="big">No paths selected yet</p>
                <button
                  className="choose-field-btn"
                  onClick={() => navigate("/fields")}
                >
                  Choose your path
                </button>
              </div>
            )}
          </div>
        </section>

        <section className="quick-stats quick-stats-extended">
          <div className="card stat-card">
            <h3>Current Level</h3>
            <p className="big">{data.level || "-"}</p>
          </div>

          <div className="card stat-card">
            <h3>Selected Path</h3>
            <p className="big small-text">{selectedPathLabel}</p>
          </div>

          <div className="card stat-card">
            <h3>Selected Paths</h3>
            <p className="big">{selectedPathsCount}</p>
          </div>

          <div className="card stat-card">
            <h3>Completed Topics</h3>
            <p className="big">{topicsStats.completed}</p>
          </div>

          <div className="card stat-card">
            <h3>Total Topics</h3>
            <p className="big">{topicsStats.total}</p>
          </div>

          <div className="card stat-card">
            <h3>Unlocked Topics</h3>
            <p className="big">{topicsStats.unlocked}</p>
          </div>
        </section>

        <section className="gauges-section">
          <RingGauge title="Placement Score" value={placementScore} />
          <RingGauge title="Profile Completion" value={profileCompletion} />
          <RingGauge title="Roadmap Progress" value={roadmapProgress} />
        </section>

        <section className="actions">
          <button
            className="nav-btn outline"
            onClick={() => navigate("/fields")}
          >
            Return to Path Selection
          </button>

          <button
            className="nav-btn primary-btn"
            onClick={() =>
              selectedDashboardPath && handleOpenRoadmap(selectedDashboardPath)
            }
            disabled={!selectedDashboardPath}
          >
            Open Selected Roadmap
          </button>

          <button
            className="nav-btn outline"
            onClick={() => navigate("/home")}
          >
            Back to Home
          </button>
        </section>
      </main>
    </>
  );
}

export default Dashboard;