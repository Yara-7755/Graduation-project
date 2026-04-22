import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Login.css";
import logo from "../assets/Logo_icon.png";

function Login() {
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);
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

      localStorage.removeItem("user");
      sessionStorage.removeItem("user");

      if (rememberMe) {
        localStorage.setItem("user", JSON.stringify(data.user));
      } else {
        sessionStorage.setItem("user", JSON.stringify(data.user));
      }

      setMessage("Login successful ✅");

      setTimeout(() => {
        if (data.user?.role === "admin") {
          navigate("/admin");
        } else {
          navigate("/home");
        }
      }, 800);
    } catch (err) {
      console.error(err);
      setMessage("Server error");
    }
  };

  return (
    <div className="login-page">
      <div className="login-bg">
        <div className="grid-overlay"></div>
        <div className="radial-glow glow-1"></div>
        <div className="radial-glow glow-2"></div>
        <div className="radial-glow glow-3"></div>
        <span className="light-line line-1"></span>
        <span className="light-line line-2"></span>
        <span className="light-line line-3"></span>
      </div>

      <div className="login-box">
        <div className="login-left">
          <form className="login-form" onSubmit={handleSubmit}>
            <img src={logo} alt="Cognito Logo" className="login-logo" />

            <h1 className="login-title">Login</h1>
            <p className="login-subtitle">
              Login to continue your adaptive learning journey in Cognito.
            </p>

            <div className="login-input-group">
              <input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <span className="login-input-icon">👤</span>
            </div>

            <div className="login-input-group password-group">
              <input
                type={showPassword ? "text" : "password"}
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              <span
                className="login-input-icon password-toggle"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? "🙈" : "🔒"}
              </span>
            </div>

            <label className="remember-row">
              <input
                type="checkbox"
                checked={rememberMe}
                onChange={(e) => setRememberMe(e.target.checked)}
              />
              <span>Remember Me</span>
            </label>

            <button className="login-btn" type="submit">
              Login
            </button>

            {message && <p className="login-message">{message}</p>}

            <p className="login-footer">
              Don&apos;t have an account?
              <span className="login-link" onClick={() => navigate("/signup")}>
                {" "}
                Sign Up
              </span>
            </p>
          </form>
        </div>

        <div className="login-right">
          <div className="welcome-text">
            <h2>COGNITO</h2>
            <p>
              Smart learning starts with the right path. Log in and continue
              building your future in IT.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Login;