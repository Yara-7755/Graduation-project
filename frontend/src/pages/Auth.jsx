import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Auth.css";

function Auth() {
  const navigate = useNavigate();

  const [isSignup, setIsSignup] = useState(false);

  const [loginEmail, setLoginEmail] = useState("");
  const [loginPassword, setLoginPassword] = useState("");
  const [rememberMe, setRememberMe] = useState(false);

  const [signupName, setSignupName] = useState("");
  const [signupEmail, setSignupEmail] = useState("");
  const [signupPassword, setSignupPassword] = useState("");

  const [message, setMessage] = useState("");

  const handleLogin = async (e) => {
    e.preventDefault();
    setMessage("");

    try {
      const res = await fetch("http://localhost:5001/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: loginEmail,
          password: loginPassword,
        }),
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
        navigate("/home");
      }, 700);
    } catch (err) {
      console.error(err);
      setMessage("Server error");
    }
  };

  const handleSignup = async (e) => {
    e.preventDefault();
    setMessage("");

    try {
      const res = await fetch("http://localhost:5001/signup", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: signupName,
          email: signupEmail,
          password: signupPassword,
        }),
      });

      const data = await res.json();

      if (!res.ok) {
        setMessage(data.message || "Signup failed");
        return;
      }

      setMessage("Account created successfully ✅ Please login.");

      setSignupName("");
      setSignupEmail("");
      setSignupPassword("");

      setTimeout(() => {
        setIsSignup(false);
        setMessage("");
      }, 1000);
    } catch (err) {
      console.error(err);
      setMessage("Server error");
    }
  };

  return (
    <div className="auth-page">
      <div className={`auth-box ${isSignup ? "signup-mode" : ""}`}>
        <div className="auth-left">
          {!isSignup ? (
            <form className="auth-form" onSubmit={handleLogin}>
              <h1>Login</h1>

              <div className="input-group">
                <input
                  type="email"
                  placeholder="Email"
                  value={loginEmail}
                  onChange={(e) => setLoginEmail(e.target.value)}
                  required
                />
                <span className="input-icon">👤</span>
              </div>

              <div className="input-group">
                <input
                  type="password"
                  placeholder="Password"
                  value={loginPassword}
                  onChange={(e) => setLoginPassword(e.target.value)}
                  required
                />
                <span className="input-icon">🔒</span>
              </div>

              <label className="remember-row">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                />
                <span>Remember me</span>
              </label>

              <button type="submit" className="auth-btn">
                Login
              </button>

              {message && <p className="auth-message">{message}</p>}

              <p className="switch-text">
                Don&apos;t have an account?
                <button
                  type="button"
                  className="link-btn"
                  onClick={() => {
                    setIsSignup(true);
                    setMessage("");
                  }}
                >
                  Sign Up
                </button>
              </p>
            </form>
          ) : (
            <form className="auth-form" onSubmit={handleSignup}>
              <h1>Sign Up</h1>

              <div className="input-group">
                <input
                  type="text"
                  placeholder="Full Name"
                  value={signupName}
                  onChange={(e) => setSignupName(e.target.value)}
                  required
                />
                <span className="input-icon">👤</span>
              </div>

              <div className="input-group">
                <input
                  type="email"
                  placeholder="Email"
                  value={signupEmail}
                  onChange={(e) => setSignupEmail(e.target.value)}
                  required
                />
                <span className="input-icon">📧</span>
              </div>

              <div className="input-group">
                <input
                  type="password"
                  placeholder="Password"
                  value={signupPassword}
                  onChange={(e) => setSignupPassword(e.target.value)}
                  required
                />
                <span className="input-icon">🔒</span>
              </div>

              <button type="submit" className="auth-btn">
                Create Account
              </button>

              {message && <p className="auth-message">{message}</p>}

              <p className="switch-text">
                Already have an account?
                <button
                  type="button"
                  className="link-btn"
                  onClick={() => {
                    setIsSignup(false);
                    setMessage("");
                  }}
                >
                  Login
                </button>
              </p>
            </form>
          )}
        </div>

        <div className="auth-right">
          <div className="welcome-text">
            {!isSignup ? (
              <>
                <h2>WELCOME BACK!</h2>
                <p>Login to continue your journey in Cognito.</p>
              </>
            ) : (
              <>
                <h2>JOIN COGNITO!</h2>
                <p>Create your account and start learning smarter.</p>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default Auth;