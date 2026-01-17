import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Navbar from "../components/Navbar";
import "./Dashboard.css";

function Dashboard() {
  const navigate = useNavigate();
  const [data, setData] = useState(null);

  const user = JSON.parse(localStorage.getItem("user") || "null");

  useEffect(() => {
    if (!user) {
      navigate("/login");
      return;
    }

    fetch(`http://localhost:5001/user/${user.id}`)
      .then((res) => res.json())
      .then((result) => setData(result))
      .catch(console.error);
  }, [user, navigate]);

  if (!data) return <p className="loading">Loading...</p>;

  const avatarLetter =
    data.name?.charAt(0).toUpperCase() ||
    data.email?.charAt(0).toUpperCase();

  const hasCompletedTest =
    data.level !== null && data.level !== undefined;

  const hasField = data.field !== null && data.field !== undefined;

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
                Welcome {data.name || data.email.split("@")[0]} 👋
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

          {/* FIELD */}
          <div className="card">
            <h3>Current PATH</h3>

            {hasField ? (
              <p className="big">{data.field}</p>
            ) : (
              <>
                <p className="big">Not Selected</p>
                <button
                  className="choose-field-btn"
                  onClick={() => navigate("/fields")}
                >
                  Choose your field
                </button>
              </>
            )}
          </div>

          {/* SCORE */}
          <div className="card">
            <h3>Score in PlacementTest</h3>
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
            className={`nav-btn outline ${
              hasCompletedTest ? "disabled-btn" : ""
            }`}
            disabled={hasCompletedTest}
            onClick={() => navigate("/placement-test")}
          >
            {hasCompletedTest
              ? "Placement Test Completed"
              : "Start Placement Test"}
          </button>
        </section>
      </main>
    </>
  );
}

export default Dashboard;
