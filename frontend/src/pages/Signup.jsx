import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Signup.css";

// ✅ IMPORT LOGO ICON
import logo from "../assets/Logo_icon.png"; // تأكد من المسار

function Signup() {
  const navigate = useNavigate();

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMessage("");

    try {
      const response = await fetch("http://localhost:5001/signup", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ name, email, password }),
      });

      const data = await response.json();

      if (!response.ok) {
        setMessage(data.message || "Signup failed");
        return;
      }

      setMessage("Signup successful ✅");

      setTimeout(() => {
        navigate("/login");
      }, 1000);

      setName("");
      setEmail("");
      setPassword("");
    } catch (error) {
      console.error(error);
      setMessage("Server error");
    }
  };

  return (
    <div className="landing signup-page">
      {/* BACKGROUND ANIMATED SHAPES */}
      <div className="bg-shapes">
        <span className="shape shape-1"></span>
        <span className="shape shape-2"></span>
        <span className="shape shape-3"></span>
      </div>

      {/* SIGNUP CARD */}
      <div className="signup-card">
        {/* ✅ LOGO ICON */}
        <img src={logo} alt="Cognito Logo" className="auth-logo" />

        <h1>Create Account</h1>

        <form onSubmit={handleSubmit}>
          <input
            type="text"
            placeholder="Full Name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />

          <input
            type="email"
            placeholder="Email Address"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />

          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />

          <button type="submit" className="btn-login">
            Sign Up
          </button>
        </form>

        {message && <p className="message">{message}</p>}

        <p className="switch-auth">
          Already have an account?
          <span onClick={() => navigate("/login")}> Login</span>
        </p>
      </div>
    </div>
  );
}

export default Signup;
