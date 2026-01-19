import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Navbar.css";
import logo from "../assets/Logo_icon.png"; // تأكد من المسار

function Navbar() {
  const navigate = useNavigate();
  const [showMenu, setShowMenu] = useState(false);
  const [showRoadmapModal, setShowRoadmapModal] = useState(false);

  const user = JSON.parse(localStorage.getItem("user"));

  const handleLogout = () => {
    localStorage.removeItem("user");
    navigate("/login");
  };

  return (
    <>
      <header className="navbar">
        {/* LOGO */}
        <div className="nav-brand" onClick={() => navigate("/home")}>
          <img src={logo} alt="Cognito Logo" className="nav-logo-icon" />
          <span className="nav-logo-text">COGNITO</span>
        </div>

        {/* USER */}
        <div className="nav-user">
          <div
            className="avatar"
            onClick={() => setShowMenu((prev) => !prev)}
          >
            {user?.name ? user.name.charAt(0).toUpperCase() : "U"}
          </div>

          {showMenu && (
            <div className="user-menu">
              <button
                className="menu-item"
                onClick={() => {
                  navigate("/dashboard");
                  setShowMenu(false);
                }}
              >
                Dashboard
              </button>

              {/* 🔥 ROADMAP (POPUP فقط) */}
              <button
                className="menu-item"
                onClick={() => {
                  setShowRoadmapModal(true);
                  setShowMenu(false);
                }}
              >
                Roadmap
              </button>

              <button
                className="menu-item logout"
                onClick={handleLogout}
              >
                Logout
              </button>
            </div>
          )}
        </div>
      </header>

      {/* 🔔 ROADMAP MODAL */}
      {showRoadmapModal && (
        <div className="modal-overlay">
          <div className="modal">
            <h2>🚧 Coming Soon</h2>
            <p>
              The Roadmap feature will be fully implemented in
              <strong> Graduation Project 2</strong>.
            </p>
            <button onClick={() => setShowRoadmapModal(false)}>
              Close
            </button>
          </div>
        </div>
      )}
    </>
  );
}

export default Navbar;
