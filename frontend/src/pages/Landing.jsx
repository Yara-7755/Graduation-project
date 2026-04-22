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
        <div className="grid-overlay"></div>

        <div className="radial-glow glow-1"></div>
        <div className="radial-glow glow-2"></div>
        <div className="radial-glow glow-3"></div>

        <span className="light-line line-1"></span>
        <span className="light-line line-2"></span>
        <span className="light-line line-3"></span>
      </div>

      {/* NAVBAR */}
      <header className="navbar">
        <div className="nav-left">
          <button className="btn-outline" onClick={() => navigate("/signup")}>
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

      {/* HERO */}
      <main className="hero">
        <div className="hero-badge">AI-Powered Adaptive Learning</div>

        <h1 className="hero-title">COGNITO</h1>

        <p className="hero-text">
          A smart platform to assess your knowledge, choose a learning path,
          and progress through a structured roadmap with a modern adaptive
          experience.
        </p>
      </main>

      {/* ABOUT MODAL */}
      {showAbout && (
        <div className="modal-overlay">
          <div className="modal">
            <h2>About Cognito</h2>
            <p>
              Cognito is a smart IT learning platform designed to help students
              assess their skill level, choose the appropriate learning path,
              and track their progress through structured roadmaps, quizzes,
              and performance analysis.
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