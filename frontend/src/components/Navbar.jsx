import { useState } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import "./Navbar.css";
import logo from "../assets/Logo_icon.png";

function Navbar() {
  const navigate = useNavigate();
  const location = useLocation();

  const [showMenu, setShowMenu] = useState(false);

  const user =
    JSON.parse(localStorage.getItem("user")) ||
    JSON.parse(sessionStorage.getItem("user"));

  const handleLogout = () => {
    localStorage.removeItem("user");
    sessionStorage.removeItem("user");
    localStorage.removeItem("cognito_language");
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
          Home
        </button>

        <button
          className={`nav-link ${isActive("/fields") ? "active" : ""}`}
          onClick={() => navigate("/fields")}
        >
          Paths
        </button>

        <button
          className={`nav-link ${
            location.pathname.startsWith("/roadmap") ? "active" : ""
          }`}
          onClick={handleOpenRoadmap}
        >
          Roadmap
        </button>

        <button
          className={`nav-link ${isActive("/dashboard") ? "active" : ""}`}
          onClick={() => navigate("/dashboard")}
        >
          Dashboard
        </button>
      </nav>

      <div className="nav-right">
        <button className="nav-ai-btn" onClick={openChatbot}>
          🤖 AI Assistant
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
                Profile
              </button>

              <button
                className="menu-item"
                onClick={() => {
                  navigate("/select-field/grades");
                  setShowMenu(false);
                }}
              >
                Grades
              </button>

              <button
                className="menu-item"
                onClick={() => {
                  navigate("/calendar");
                  setShowMenu(false);
                }}
              >
                Calendar
              </button>

              <button className="menu-item" onClick={handleOpenRoadmap}>
                Roadmap
              </button>

              <div className="menu-divider"></div>

              <button className="menu-item logout" onClick={handleLogout}>
                Logout
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}

export default Navbar;