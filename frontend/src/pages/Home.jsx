import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Navbar from "../components/Navbar";
import "./Home.css";

const articles = [
  {
    title: "The World of Information Technology",
    text:
      "Information Technology is the backbone of modern digital systems. " +
      "It enables communication, automation, data analysis, and innovation across industries."
  },
  {
    title: "Why Choosing the Right IT Field Matters",
    text:
      "Choosing the right IT specialization helps you focus your learning, " +
      "build strong expertise, and increase your chances in the job market."
  },
  {
    title: "Learning IT the Smart Way",
    text:
      "Structured learning paths, continuous assessment, and progress tracking " +
      "are key factors in mastering IT skills efficiently."
  }
];

function Home() {
  const navigate = useNavigate();
  const [userData, setUserData] = useState(null);

  const user = JSON.parse(localStorage.getItem("user") || "null");

  useEffect(() => {
    if (!user) return;

    fetch(`http://localhost:5001/user/${user.id}`)
      .then((res) => res.json())
      .then((data) => setUserData(data))
      .catch(console.error);
  }, [user]);

  const hasCompletedTest =
    userData?.level !== null && userData?.level !== undefined;

  return (
    <>
      <Navbar />

      <div className="home-page">

        {/* BACKGROUND ANIMATION */}
        <div className="home-bg">
          <span className="home-blob blob-1"></span>
          <span className="home-blob blob-2"></span>
          <span className="home-blob blob-3"></span>
        </div>

        {/* HERO */}
        <section className="home-hero fade-in">
          <h1>
            Welcome to <span>Cognito</span>
            {userData?.name && (
              <>
                , <span className="user-name">{userData.name}</span>
              </>
            )} 👋
          </h1>

          <p>
            Take a placement test to discover your IT level and start your journey.
          </p>
        </section>

        {/* ARTICLES */}
        <section className="articles-wrapper">
          {articles.map((article, index) => (
            <div
              key={index}
              className="article-section slide-up"
              style={{ animationDelay: `${index * 0.3}s` }}
            >
              <h2>{article.title}</h2>
              <p>{article.text}</p>
            </div>
          ))}
        </section>

        {/* CTA */}
        <section className="cta">
          <button
            className={`primary-btn ${
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
      </div>
    </>
  );
}

export default Home;
