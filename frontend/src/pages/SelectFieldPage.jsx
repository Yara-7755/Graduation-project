import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import Navbar from "../components/Navbar";

function SelectFieldPage({ mode = "roadmap" }) {
  const navigate = useNavigate();
  const [paths, setPaths] = useState([]);
  const [loading, setLoading] = useState(true);

  const user = useMemo(
    () =>
      JSON.parse(localStorage.getItem("user")) ||
      JSON.parse(sessionStorage.getItem("user")),
    []
  );

  useEffect(() => {
    const loadPaths = async () => {
      if (!user?.id) {
        navigate("/login");
        return;
      }

      try {
        const res = await fetch(`http://localhost:5001/user/${user.id}/paths`);
        const data = await res.json();

        if (!res.ok) {
          throw new Error(data.message || "Failed to load paths");
        }

        const mainField = user?.field ? [{ path_name: user.field }] : [];

        const merged = [...mainField, ...(Array.isArray(data) ? data : [])];

        const uniquePaths = merged.filter(
          (item, index, self) =>
            item?.path_name &&
            self.findIndex((x) => x.path_name === item.path_name) === index
        );

        if (uniquePaths.length === 0) {
          navigate("/fields");
          return;
        }

        if (uniquePaths.length === 1) {
          const selectedField = uniquePaths[0].path_name;
          sessionStorage.setItem("selectedField", selectedField);

          if (mode === "grades") {
            navigate("/grades", { replace: true });
          } else {
            navigate(`/roadmap/${encodeURIComponent(selectedField)}`, {
              replace: true,
            });
          }
          return;
        }

        setPaths(uniquePaths);
      } catch (error) {
        console.error("SELECT FIELD PAGE ERROR:", error);
      } finally {
        setLoading(false);
      }
    };

    loadPaths();
  }, [mode, navigate, user]);

  const handleChooseField = (fieldName) => {
    sessionStorage.setItem("selectedField", fieldName);

    if (mode === "grades") {
      navigate("/grades");
      return;
    }

    navigate(`/roadmap/${encodeURIComponent(fieldName)}`);
  };

  return (
    <>
      <Navbar />

      <main className="grades-page">
        <section className="grades-hero-card">
          <div className="grades-badge">Choose Field</div>
          <h1>{mode === "grades" ? "Select Field for Grades" : "Select Field for Roadmap"}</h1>
          <p>
            Choose the field you want to open.
          </p>
        </section>

        {loading ? (
          <section className="grades-card">
            <p className="grades-description">Loading your fields...</p>
          </section>
        ) : (
          <section className="grades-summary-grid">
            {paths.map((item) => (
              <button
                key={item.path_name}
                className="grades-stat-card"
                style={{
                  cursor: "pointer",
                  textAlign: "left",
                }}
                onClick={() => handleChooseField(item.path_name)}
              >
                <h3>Field</h3>
                <p style={{ fontSize: "20px" }}>{item.path_name}</p>
              </button>
            ))}
          </section>
        )}
      </main>
    </>
  );
}

export default SelectFieldPage;