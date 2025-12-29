import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Landing.css";

function Landing() {
  const navigate = useNavigate();
  const [showAbout, setShowAbout] = useState(false);

  return (
    <div className="landing">
      <header className="navbar">
        <div className="nav-left">
          <button className="btn-outline" onClick={() => navigate("/home")}>
            Get Started
          </button>

          <button className="btn-login" onClick={() => navigate("/login")}>
            Login
          </button>
        </div>

        <div className="nav-right">
          <span className="nav-link" onClick={() => setShowAbout(true)}>
            About Us
          </span>
        </div>
      </header>

      <main className="hero">
        <div className="hero-title-wrapper">
          <h1 className="hero-title">
          <span data-text="COGNITO">COGNITO</span>
          </h1>

        </div>

        <p>
          A smart platform to assess your IT level, choose a field,
          and progress through a structured learning roadmap.
        </p>
      </main>

      {showAbout && (
        <div className="modal-overlay">
          <div className="modal">
            <h2>About Cognito</h2>
            <p>
              Cognito helps students assess skills, choose learning paths,
              and track progress through structured IT roadmaps.
            </p>

            <button className="close-btn" onClick={() => setShowAbout(false)}>
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

export default Landing;
