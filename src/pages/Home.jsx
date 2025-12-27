import { useState } from "react";
import { useNavigate } from "react-router-dom";
import Navbar from "../components/Navbar";
import "./Home.css";

function Home() {
  const navigate = useNavigate();
  const [selectedField, setSelectedField] = useState("");
  const user = JSON.parse(localStorage.getItem("user"));

  const fields = [
    "Frontend Development",
    "Backend Development",
    "Cybersecurity",
    "Databases",
    "Software Engineering",
  ];

  const handleSelectField = async (field) => {
    setSelectedField(field);

    try {
      await fetch("http://localhost:5001/user/field", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          userId: user.id,
          field,
        }),
      });

      localStorage.setItem("field", field);
    } catch (err) {
      console.error("Failed to save field", err);
    }
  };

  return (
    <div className="home-page">
      <Navbar />

      {/* HERO */}
      <section className="home-hero fade-in">
        <h1>
          Welcome to <span>Cognito</span> 👋
        </h1>
        <p>
          Choose your learning field and start your IT journey with confidence.
        </p>
      </section>

      {/* ARTICLE */}
      <section className="article-section slide-up">
        <h2>Where is IT heading today?</h2>
        <p>
          IT today is driven by AI, cloud computing, cybersecurity, and scalable
          systems. Choosing the right field early helps you grow with clarity
          and purpose.
        </p>
      </section>

      {/* FIELDS */}
      <section className="fields slide-up">
        <h2>Select Your Field</h2>

        <div className="field-grid">
          {fields.map((field) => (
            <div
              key={field}
              className={`field-card ${
                selectedField === field ? "selected" : ""
              }`}
              onClick={() => handleSelectField(field)}
            >
              {field}
            </div>
          ))}
        </div>
      </section>

      {/* CTA */}
      <section className="cta">
        <button
          className="primary-btn"
          disabled={!selectedField}
          onClick={() => navigate("/placement-test")}
        >
          Start Placement Test
        </button>
      </section>
    </div>
  );
}

export default Home;
