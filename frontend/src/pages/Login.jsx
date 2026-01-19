import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Login.css";
import logo from "../assets/Logo_icon.png"; // تأكد من المسار

function Login() {
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [message, setMessage] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMessage("");

    try {
      const res = await fetch("http://localhost:5001/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });

      const data = await res.json();

      if (!res.ok) {
        setMessage(data.message || "Login failed");
        return;
      }

      localStorage.setItem("user", JSON.stringify(data.user));
      setMessage("Login successful ✅");

      setTimeout(() => {
        navigate("/home");
      }, 800);
    } catch (err) {
      console.error(err);
      setMessage("Server error");
    }
  };

  return (
    <div className="auth-page">
      {/* BACKGROUND SHAPES */}
      <div className="bg-shapes">
        <span className="shape shape-1"></span>
        <span className="shape shape-2"></span>
        <span className="shape shape-3"></span>
      </div>

      {/* LOGIN CARD */}
      <div className="auth-card">
        {/* ✅ LOGO ICON */}
        <img src={logo} alt="Cognito Logo" className="auth-logo" />

        <h2 className="auth-title">Sign In</h2>

        <form className="auth-form" onSubmit={handleSubmit}>
          <input
            className="auth-input"
            type="email"
            placeholder="Email Address"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />

          {/* PASSWORD WITH TOGGLE */}
          <div className="password-wrapper">
            <input
              className="auth-input"
              type={showPassword ? "text" : "password"}
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />

            <span
              className="toggle-password"
              onClick={() => setShowPassword(!showPassword)}
            >
              {showPassword ? "👁️‍🗨️" : "👁️"}
            </span>
          </div>

          <button className="auth-btn" type="submit">
            Login
          </button>
        </form>

        {message && <p className="auth-message">{message}</p>}

        <p className="auth-footer">
          Don’t have an account?
          <span className="auth-link" onClick={() => navigate("/signup")}>
            {" "}Sign Up
          </span>
        </p>
      </div>
    </div>
  );
}

export default Login;
