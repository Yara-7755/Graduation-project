import { useNavigate } from "react-router-dom";
import "./Navbar.css";

function Navbar() {
  const navigate = useNavigate();
  const user = JSON.parse(localStorage.getItem("user"));

  const logout = () => {
    localStorage.clear();
    navigate("/login");
  };

  return (
    <nav className="navbar">
      <h2 className="logo">COGNITO</h2>

      <div className="nav-links">
        <span onClick={() => navigate("/home")}>Home</span>
        <span onClick={() => navigate("/dashboard")}>Dashboard</span>
      </div>

      <div className="nav-user">
        <div className="avatar">
          {user?.email?.charAt(0).toUpperCase()}
        </div>

        <button className="logout-btn" onClick={logout}>
          Logout
        </button>
      </div>
    </nav>
  );
}

export default Navbar;
