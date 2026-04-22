import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import Navbar from "../components/Navbar";
import "./Home.css";

const articles = [
  {
    title: "The World of Information Technology",
    text:
      "Information Technology is the backbone of modern digital systems. It enables communication, automation, data analysis, and innovation across industries.",
    action: "Discover Fields",
    path: "/fields",
  },
  {
    title: "Why Choosing the Right IT Field Matters",
    text:
      "Choosing the right IT specialization helps you focus your learning, build strong expertise, and increase your chances in the job market.",
    action: "View Learning Paths",
    path: "/fields",
  },
  {
    title: "Learning IT the Smart Way",
    text:
      "Structured learning paths, continuous assessment, and progress tracking are key factors in mastering IT skills efficiently.",
    action: "Go to Dashboard",
    path: "/dashboard",
  },
];

function Home() {
  const navigate = useNavigate();
  const [userData, setUserData] = useState(null);
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });

  const particles = useMemo(
    () =>
      Array.from({ length: 24 }, (_, i) => ({
        id: i,
        left: `${Math.random() * 100}%`,
        top: `${Math.random() * 100}%`,
        delay: `${Math.random() * 8}s`,
        duration: `${5 + Math.random() * 7}s`,
        size: `${4 + Math.random() * 5}px`,
      })),
    []
  );

  const user =
    JSON.parse(localStorage.getItem("user")) ||
    JSON.parse(sessionStorage.getItem("user"));

  useEffect(() => {
    if (!user || !user.id) {
      navigate("/login");
      return;
    }

    fetch(`http://localhost:5001/user/${user.id}`)
      .then((res) => res.json())
      .then((data) => setUserData(data))
      .catch(console.error);
  }, [user, navigate]);

  useEffect(() => {
    const handleMouseMove = (e) => {
      const x = (e.clientX / window.innerWidth - 0.5) * 2;
      const y = (e.clientY / window.innerHeight - 0.5) * 2;
      setMousePosition({ x, y });
    };

    window.addEventListener("mousemove", handleMouseMove);
    return () => window.removeEventListener("mousemove", handleMouseMove);
  }, []);

  const hasCompletedTest =
    userData?.level !== null && userData?.level !== undefined;

  const handleCardMove = (e) => {
    const card = e.currentTarget;
    const rect = card.getBoundingClientRect();

    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const centerX = rect.width / 2;
    const centerY = rect.height / 2;

    const rotateX = ((y - centerY) / centerY) * -7;
    const rotateY = ((x - centerX) / centerX) * 7;

    card.style.transform = `perspective(1200px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-10px) scale(1.02)`;
  };

  const resetCard = (e) => {
    e.currentTarget.style.transform =
      "perspective(1200px) rotateX(0deg) rotateY(0deg) translateY(0px) scale(1)";
  };

  const handlePlacementClick = () => {
    if (hasCompletedTest) return;
    navigate("/placement-test");
  };

  return (
    <>
      <Navbar />

      <div className="home-page">
        <div className="home-bg">
          <div
            className="grid-overlay"
            style={{
              transform: `translate(${mousePosition.x * -12}px, ${mousePosition.y * -12}px)`,
            }}
          />

          <div
            className="radial-glow glow-1"
            style={{
              transform: `translate(${mousePosition.x * 28}px, ${mousePosition.y * 24}px)`,
            }}
          />
          <div
            className="radial-glow glow-2"
            style={{
              transform: `translate(${mousePosition.x * -34}px, ${mousePosition.y * -18}px)`,
            }}
          />
          <div
            className="radial-glow glow-3"
            style={{
              transform: `translate(${mousePosition.x * 22}px, ${mousePosition.y * -28}px)`,
            }}
          />

          <span className="home-line line-1"></span>
          <span className="home-line line-2"></span>
          <span className="home-line line-3"></span>

          <div className="energy-ring energy-ring-1"></div>
          <div className="energy-ring energy-ring-2"></div>

          {particles.map((particle) => (
            <span
              key={particle.id}
              className="particle"
              style={{
                left: particle.left,
                top: particle.top,
                width: particle.size,
                height: particle.size,
                animationDelay: particle.delay,
                animationDuration: particle.duration,
              }}
            />
          ))}
        </div>

        <section className="home-hero fade-in">
          <div className="hero-badge">AI-Powered Adaptive Learning Platform</div>

          <div className="hero-orbit orbit-1"></div>
          <div className="hero-orbit orbit-2"></div>
          <div className="hero-orbit orbit-3"></div>

          <h1>
            Build Your Future with <span>Cognito</span>
            {userData?.name && (
              <>
                <br />
                <span className="hero-user-line">
                  Welcome back, <span className="user-name">{userData.name}</span>
                </span>
              </>
            )}{" "}
            🚀
          </h1>

          <p>
            A smart adaptive learning environment that identifies your level,
            guides you through the right IT specialization, tracks your progress,
            and helps you learn through a structured and modern experience.
          </p>

          <div className="hero-actions">
            <button
              className={`primary-btn ${hasCompletedTest ? "disabled-btn" : ""}`}
              disabled={hasCompletedTest}
              onClick={handlePlacementClick}
            >
              <span className="btn-glow"></span>
              <span className="btn-text">
                {hasCompletedTest
                  ? "Placement Test Completed"
                  : "Start Placement Test"}
              </span>
            </button>

            <button
              className="secondary-btn"
              onClick={() => navigate("/paths-overview")}
            >
              Explore Fields
            </button>

            <button
              className="outline-btn"
              onClick={() => navigate("/dashboard")}
            >
              My Dashboard
            </button>
          </div>

          <div className="hero-stats">
            <div className="hero-stat-card">
              <span className="hero-stat-number">
                {hasCompletedTest ? userData?.level || "Ready" : "Locked"}
              </span>
              <span className="hero-stat-label">Current Level</span>
            </div>

                  <div className="hero-stat-card">
        <span className="hero-stat-number">
          {userData?.field || "Not Selected"}
        </span>
        <span className="hero-stat-label">
          {userData?.level ? `Level: ${userData.level}` : "Field Status"}
        </span>
      </div>

           <div className="hero-stat-card">
  <span className="hero-stat-number">
    {hasCompletedTest ? "Path Ready" : "Locked"}
  </span>
  <span className="hero-stat-label">
    {hasCompletedTest
      ? userData?.field || "Start Learning"
      : "Personalized Path"}
  </span>
</div>
          </div>
        </section>

        <section className="next-step-card fade-in">
          <div className="next-step-badge">Your Next Step</div>
          <h3>
            {hasCompletedTest
              ? "Your personalized learning journey is ready."
              : "Take the placement test to unlock your personalized path."}
          </h3>
          <p>
            {hasCompletedTest
              ? "Explore your selected field, continue your roadmap topic by topic, and monitor your academic progress through the dashboard."
              : "Once you complete the placement test, Cognito will evaluate your current knowledge and guide you to the most suitable learning roadmap."}
          </p>

          <div className="next-step-actions">
            {!hasCompletedTest ? (
              <button className="primary-btn small-btn" onClick={handlePlacementClick}>
                <span className="btn-glow"></span>
                <span className="btn-text">Take Placement Test</span>
              </button>
            ) : (
              <button
                className="primary-btn small-btn"
                onClick={() => navigate("/dashboard")}
              >
                <span className="btn-glow"></span>
                <span className="btn-text">Continue Journey</span>
              </button>
            )}

            <button
              className="outline-btn small-outline-btn"
              onClick={() => navigate("/paths-overview")}            >
              Explore Fields
            </button>
          </div>
        </section>

        <section className="articles-wrapper">
          {articles.map((article, index) => (
            <div
              key={index}
              className="article-section article-animate"
              style={{ animationDelay: `${index * 0.18}s` }}
              onMouseMove={handleCardMove}
              onMouseLeave={resetCard}
            >
              <div className="article-shine"></div>
              <div className="article-blur"></div>
              <div className="article-index">0{index + 1}</div>
              <h2>{article.title}</h2>
              <p>{article.text}</p>

              <button
                className="card-btn"
                onClick={() => navigate(article.path)}
              >
                {article.action}
              </button>
            </div>
          ))}
        </section>
      </div>
    </>
  );
}

export default Home;