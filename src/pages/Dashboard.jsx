import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
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

  if (!data) return <p>Loading...</p>;

  return (
    <>
      {/* NAVBAR */}
      <header className="dash-navbar">
        <div className="dash-logo">COGNITO</div>

        <nav className="dash-links">
          <span className="active">Dashboard</span>
          <span onClick={() => navigate("/home")}>Home</span>
          <span
            onClick={() => {
              localStorage.clear();
              navigate("/login");
            }}
          >
            Logout
          </span>
        </nav>

        <div className="dash-user">
          <div className="avatar">
            {data.name?.charAt(0).toUpperCase()}
          </div>
        </div>
      </header>

      {/* MAIN */}
      <main className="dashboard">
        <h1>
          Welcome {data.name || data.email.split("@")[0]} 👋
        </h1>
        <p className="subtitle">
          Here is a summary of your learning journey
        </p>

        <div className="stats">
          <div className="card">
            <h3>Current Level</h3>
            <p className="big">{data.level || "-"}</p>
          </div>

          <div className="card">
            <h3>Current Field</h3>
            <p className="big">{data.field || "-"}</p>
          </div>

          <div className="card">
            <h3>Score</h3>
            <p className="big">
              {data.placement_score !== null
                ? `${data.placement_score}%`
                : "-"}
            </p>
          </div>
        </div>

        <div className="actions">
          <button
            className="outline"
            onClick={() => navigate("/placement-test")}
          >
            Retake Placement Test
          </button>
        </div>
      </main>
    </>
  );
}

export default Dashboard;
