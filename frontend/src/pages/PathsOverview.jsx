import { useNavigate } from "react-router-dom";
import "./PathsOverview.css";

export default function PathsOverview() {
  const navigate = useNavigate();

  const openChatbot = () => {
    window.dispatchEvent(new Event("openChatbot"));
  };

  const fields = [
    {
      name: "Frontend Development",
      badge: "UI & Web Interfaces",
      desc: "Frontend Development focuses on building the visible part of websites and web applications. You will work on layouts, responsiveness, interactivity, and user experience using modern web technologies.",
      learn: [
        "HTML, CSS, and JavaScript fundamentals",
        "Responsive design and UI building",
        "React and component-based architecture",
        "API integration and frontend performance",
      ],
      future:
        "This field can lead to roles such as Frontend Developer, React Developer, UI Engineer, or Full-Stack Developer later on.",
    },
    {
      name: "Backend Development",
      badge: "APIs & Server Logic",
      desc: "Backend Development is about building the logic behind applications. It includes APIs, databases, authentication, business rules, and the overall server-side architecture.",
      learn: [
        "Node.js and Express fundamentals",
        "REST APIs and server-side architecture",
        "Authentication and authorization",
        "Database integration and deployment basics",
      ],
      future:
        "This field can lead to careers like Backend Developer, API Developer, Software Engineer, or Full-Stack Developer.",
    },
    {
      name: "Programming Fundamentals",
      badge: "Core Coding Skills",
      desc: "Programming Fundamentals is the best starting point if you want to build a strong technical base. It helps you understand problem solving, logic, algorithms, syntax, and clean coding practices.",
      learn: [
        "Variables, conditions, loops, and functions",
        "Problem solving and algorithmic thinking",
        "Basic data structures and logic",
        "Writing clean and understandable code",
      ],
      future:
        "This field prepares you for almost every software path and helps you move confidently into Frontend, Backend, Mobile, AI, or Security.",
    },
    {
      name: "Databases",
      badge: "Data & SQL Systems",
      desc: "Databases focus on storing, organizing, retrieving, and managing data efficiently.",
      learn: [
        "SQL queries",
        "Data modeling",
        "Joins and indexing",
        "Database design",
      ],
      future:
        "This path can lead to roles such as Database Developer or Data Engineer.",
    },
    {
      name: "Cyber Security",
      badge: "Protection & Defense",
      desc: "Cyber Security is about protecting systems and applications.",
      learn: [
        "Security basics",
        "Threats and vulnerabilities",
        "Authentication & encryption",
      ],
      future:
        "This field can open doors to roles such as Security Analyst or Cyber Security Engineer.",
    },
    {
      name: "Mobile Development",
      badge: "Apps for Devices",
      desc: "Build mobile apps for Android and iOS.",
      learn: [
        "Mobile UI",
        "App navigation",
        "State management",
      ],
      future:
        "You can become a Mobile Developer or App Engineer.",
    },
    {
      name: "Cloud Computing",
      badge: "Deployment & Scalability",
      desc: "Deploy and scale applications using cloud platforms.",
      learn: [
        "Cloud basics",
        "Hosting apps",
        "Scalability",
      ],
      future:
        "You can become a Cloud Engineer or DevOps Engineer.",
    },
    {
      name: "UI/UX Design",
      badge: "Design & Experience",
      desc: "Design user-friendly and attractive interfaces.",
      learn: [
        "UI design",
        "User experience",
        "Wireframing",
      ],
      future:
        "You can become a UI/UX Designer or Product Designer.",
    },
  ];

  return (
    <div className="paths-page">
      <div className="paths-container">
        <section className="paths-hero">
          <div className="paths-badge">Explore Your Future in IT</div>
          <h1>Explore Learning Paths</h1>
          <p className="paths-subtitle">
            Discover the available fields and choose your journey.
          </p>
        </section>

        <section className="paths-grid">
          {fields.map((field, index) => (
            <article key={index} className="path-card">
              <div className="path-card-top">
                <div className="path-mini-badge">{field.badge}</div>
                <h2>{field.name}</h2>
              </div>

              <p className="path-description">{field.desc}</p>

              <div className="path-section">
                <h4>What you will learn</h4>
                <ul>
                  {field.learn.map((item, i) => (
                    <li key={i}>{item}</li>
                  ))}
                </ul>
              </div>

              <div className="path-section">
                <h4>Career future</h4>
                <p className="path-meta">{field.future}</p>
              </div>

              <div className="path-actions">
                <button
                  className="path-primary-btn"
                  onClick={() => navigate("/fields")}
                >
                  Go to Field Selection
                </button>

                <button
                  className="path-outline-btn"
                  onClick={openChatbot}
                >
                  Ask the Chatbot
                </button>
              </div>
            </article>
          ))}
        </section>

        <section className="ai-helper">
          <div className="ai-helper-badge">AI Guidance</div>
          <h3>Not sure which field fits you best?</h3>
          <p>
            Ask the chatbot to guide you based on your interests.
          </p>

          <div className="ai-helper-actions">
            <button onClick={() => navigate("/fields")}>
              Continue to Field Selection
            </button>

            <button
              className="secondary-ai-btn"
              onClick={openChatbot}
            >
              Open Chatbot and Ask
            </button>
          </div>
        </section>
      </div>
    </div>
  );
}