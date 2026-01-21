import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Landing.css";

function Landing() {
  const navigate = useNavigate();
  const [showAbout, setShowAbout] = useState(false);

  return (
    <div className="landing">

      {/* BACKGROUND ANIMATION */}
      <div className="landing-bg">
        <span className="blob blob-1"></span>
        <span className="blob blob-2"></span>
        <span className="blob blob-3"></span>
      </div>

      {/* NAVBAR */}
      <header className="navbar">
        <div className="nav-left">
          <button
            className="btn-outline"
            onClick={() => navigate("/signup")}
          >
            Get Started
          </button>

          <button
            className="btn-login"
            onClick={() => navigate("/login")}
          >
            Login
          </button>
        </div>

        <div className="nav-right">
          <span
            className="nav-link"
            onClick={() => setShowAbout(true)}
          >
            About Us
          </span>
        </div>
      </header>

      {/* HERO */}
      <main className="hero">
        <h1 className="hero-title">COGNITO</h1>
        <p className="hero-text">
          A smart platform to assess your Knowledge, choose Learning Path (or Paths),
          and progress through a structured learning Roadmap.
        </p>
      </main>

      {/* ABOUT MODAL */}
      {showAbout && (
        <div className="modal-overlay">
          <div className="modal">
            <h2>About Cognito</h2>
            <p>
              Cognito is a smart IT learning platform designed to help
              students assess their skill level, choose the appropriate
              learning path, and track their progress through structured
              roadmaps, quizzes, and performance analysis.
            </p>

            <button
              className="close-btn"
              onClick={() => setShowAbout(true)}
            >
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

export default Landing;
