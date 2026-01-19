
// 19/1/26  
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Navbar from "../components/Navbar";
import "./Dashboard.css";

function Dashboard() {
  const navigate = useNavigate();

  const [data, setData] = useState(null);
  const [paths, setPaths] = useState([]);
  const [selectedPaths, setSelectedPaths] = useState([]);

  const user = JSON.parse(localStorage.getItem("user") || "null");

  // =========================
  // FETCH USER DATA & PATHS
  // =========================
  useEffect(() => {
    if (!user) {
      navigate("/login");
      return;
    }

    // Fetch user profile
    fetch(`http://localhost:5001/user/${user.id}`)
      .then((res) => res.json())
      .then((result) => setData(result))
      .catch(console.error);

    // Fetch user paths
    fetch(`http://localhost:5001/user/${user.id}/paths`)
      .then((res) => res.json())
      .then((result) => setPaths(result))
      .catch(console.error);
  }, [user, navigate]);

  if (!data) return <p className="loading">Loading...</p>;

  // =========================
  // HELPERS
  // =========================
  const avatarLetter =
    data.name?.charAt(0).toUpperCase() ||
    data.email?.charAt(0).toUpperCase();

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

      if (res.ok) {
        setPaths((prev) =>
          prev.filter((p) => !selectedPaths.includes(p.path_name))
        );
        setSelectedPaths([]);
      }
    } catch (err) {
      console.error("Failed to delete paths", err);
    }
  };

  // =========================
  // RENDER
  // =========================
  return (
    <>
      <Navbar />

      <main className="dashboard-page">
        {/* HEADER */}
        <section className="dashboard-header">
          <div className="profile">
            <div className="profile-avatar">{avatarLetter}</div>

            <div className="profile-info">
              <h1>
                Keep going {data.email.split("@")[0]}! 🔥
              </h1>
              <p className="subtitle">
                Here is a summary of your learning journey
              </p>
            </div>
          </div>
        </section>

        {/* STATS */}
        <section className="stats">
          {/* LEVEL */}
          <div className="card">
            <h3>Current Level</h3>
            <p className="big">{data.level || "-"}</p>
          </div>

          {/* PATHS */}
          <div className="card">
            <h3>Selected Path(s)</h3>

            {paths.length > 0 ? (
              <>
                <ul className="path-list">
                  {paths.map((p) => (
                    <li
                      key={p.path_name}
                      className="big"
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: "10px",
                      }}
                    >
                      <input
                        type="checkbox"
                        checked={selectedPaths.includes(p.path_name)}
                        onChange={() => handleSelectPath(p.path_name)}
                      />
                      {p.path_name}
                    </li>
                  ))}
                </ul>

                <button
                  onClick={handleDeletePaths}
                  disabled={selectedPaths.length === 0}
                  style={{
                    marginTop: "12px",
                    padding: "8px 14px",
                    backgroundColor: "#b00020",
                    color: "white",
                    border: "none",
                    borderRadius: "6px",
                    cursor: "pointer",
                    opacity: selectedPaths.length === 0 ? 0.6 : 1,
                  }}
                >
                  Delete Selected Path(s)
                </button>
              </>
            ) : (
              <>
                <p className="big">No paths selected</p>
                <button
                  className="choose-field-btn"
                  onClick={() => navigate("/fields")}
                >
                  Choose your path
                </button>
              </>
            )}
          </div>

          {/* SCORE */}
          <div className="card">
            <h3>Score in Placement Test</h3>
            <p className="big">
              {data.placement_score !== null
                ? `${data.placement_score}%`
                : "-"}
            </p>
          </div>
        </section>

        {/* ACTIONS */}
        <section className="actions">
          <button
            className="nav-btn outline"
            onClick={() => navigate("/fields")}
          >
            Return to Path Selection
          </button>

          <button
            className="nav-btn"
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
