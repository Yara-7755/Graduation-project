import { useEffect, useState } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import "./Navbar.css";
import logo from "../assets/Logo_icon.png";

function Navbar() {
  const navigate = useNavigate();
  const location = useLocation();

  const [showMenu, setShowMenu] = useState(false);
  const [language, setLanguage] = useState(
    localStorage.getItem("cognito_language") || "en"
  );

  const user =
    JSON.parse(localStorage.getItem("user")) ||
    JSON.parse(sessionStorage.getItem("user"));

  const t = {
    en: {
      home: "Home",
      paths: "Paths",
      roadmap: "Roadmap",
      dashboard: "Dashboard",
      aiAssistant: "AI Assistant",
      profile: "Profile",
      grades: "Grades",
      calendar: "Calendar",
      language: "Language",
      arabic: "Arabic",
      english: "English",
      logout: "Logout",
    },
    ar: {
      home: "الرئيسية",
      paths: "المسارات",
      roadmap: "الخارطة",
      dashboard: "لوحة التحكم",
      aiAssistant: "المساعد الذكي",
      profile: "الملف الشخصي",
      grades: "العلامات",
      calendar: "التقويم",
      language: "اللغة",
      arabic: "العربية",
      english: "English",
      logout: "تسجيل الخروج",
    },
  };

  const text = t[language];

  useEffect(() => {
    localStorage.setItem("cognito_language", language);
    window.dispatchEvent(
      new CustomEvent("languageChanged", {
        detail: { language },
      })
    );
  }, [language]);

  const handleLogout = () => {
    localStorage.removeItem("user");
    sessionStorage.removeItem("user");
    navigate("/login");
  };

 const handleOpenRoadmap = () => {
  if (!user?.field && !user?.level) {
    navigate("/fields");
    setShowMenu(false);
    return;
  }

  navigate("/select-field/roadmap");
  setShowMenu(false);
};

  const openChatbot = () => {
    window.dispatchEvent(new Event("openChatbot"));
  };

  const isActive = (path) => location.pathname === path;

  return (
    <header className="navbar">
      <div className="nav-brand" onClick={() => navigate("/home")}>
        <img src={logo} alt="Cognito Logo" className="nav-logo-icon" />
        <span className="nav-logo-text">COGNITO</span>
      </div>

      <nav className="nav-links">
        <button
          className={`nav-link ${isActive("/home") ? "active" : ""}`}
          onClick={() => navigate("/home")}
        >
          {text.home}
        </button>

        <button
  className={`nav-link ${isActive("/fields") ? "active" : ""}`}
  onClick={() => navigate("/fields")}
>
  {text.paths}
</button>

        <button
          className={`nav-link ${
            location.pathname.startsWith("/roadmap") ? "active" : ""
          }`}
          onClick={handleOpenRoadmap}
        >
          {text.roadmap}
        </button>

        <button
          className={`nav-link ${isActive("/dashboard") ? "active" : ""}`}
          onClick={() => navigate("/dashboard")}
        >
          {text.dashboard}
        </button>
      </nav>

      <div className="nav-right">
        <button className="nav-ai-btn" onClick={openChatbot}>
          🤖 {text.aiAssistant}
        </button>

        <div className="nav-user">
          <div className="avatar" onClick={() => setShowMenu((prev) => !prev)}>
            {user?.name ? user.name.charAt(0).toUpperCase() : "U"}
          </div>

          {showMenu && (
            <div className="user-menu">
              <button
                className="menu-item"
                onClick={() => {
                  navigate("/profile");
                  setShowMenu(false);
                }}
              >
                {text.profile}
              </button>

              <button
                className="menu-item"
                onClick={() => {
                  navigate("/select-field/grades");
                  setShowMenu(false);
                }}
              >
                {text.grades}
              </button>

              <button
                className="menu-item"
                onClick={() => {
                  navigate("/calendar");
                  setShowMenu(false);
                }}
              >
                {text.calendar}
              </button>

              <button className="menu-item" onClick={handleOpenRoadmap}>
                {text.roadmap}
              </button>

              <div className="menu-divider"></div>

              <div className="menu-language-label">{text.language}</div>

              <div className="language-switch">
                <button
                  className={`language-btn ${language === "ar" ? "active" : ""}`}
                  onClick={() => setLanguage("ar")}
                >
                  {text.arabic}
                </button>

                <button
                  className={`language-btn ${language === "en" ? "active" : ""}`}
                  onClick={() => setLanguage("en")}
                >
                  {text.english}
                </button>
              </div>

              <div className="menu-divider"></div>

              <button className="menu-item logout" onClick={handleLogout}>
                {text.logout}
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}

export default Navbar;