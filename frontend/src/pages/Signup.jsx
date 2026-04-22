import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Signup.css";
import logo from "../assets/Logo_icon.png";

function Signup() {
  const navigate = useNavigate();

  const [fullName, setFullName] = useState("");
  const [universityMajor, setUniversityMajor] = useState("");
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  // ✅ NEW
  const [accountType, setAccountType] = useState("user");
  const [adminCode, setAdminCode] = useState("");

  const [showPassword, setShowPassword] = useState(false);
  const [message, setMessage] = useState("");

  const isValidFullName = (name) => {
    const parts = name.trim().split(/\s+/);
    return parts.length >= 2;
  };

  const isValidPhone = (value) => {
    return /^[0-9+\-\s]{8,20}$/.test(value.trim());
  };

  const handleGoogleResponse = async (response) => {
    try {
      const res = await fetch("http://localhost:5001/auth/google", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          credential: response.credential,
        }),
      });

      const data = await res.json();

      if (!res.ok) {
        setMessage(data.message || "Google signup failed");
        return;
      }

      localStorage.setItem("user", JSON.stringify(data.user));
      setMessage("Google signup successful ✅");

      setTimeout(() => {
        if (!data.user.phone || !data.user.university_major) {
          navigate("/complete-profile");
        } else {
          navigate("/home");
        }
      }, 700);
    } catch (error) {
      console.error(error);
      setMessage("Google signup failed");
    }
  };

  useEffect(() => {
    const renderGoogleButton = () => {
      if (!window.google) return;

      window.google.accounts.id.initialize({
        client_id:
          "853801006930-mkqdbvrb8clrpmpc95gvgpefjn0uup4e.apps.googleusercontent.com",
        callback: handleGoogleResponse,
      });

      const container = document.getElementById("googleSignUpDiv");
      if (container) {
        container.innerHTML = "";
        window.google.accounts.id.renderButton(container, {
          theme: "outline",
          size: "large",
          shape: "pill",
          width: 320,
          text: "signup_with",
        });
      }
    };

    const interval = setInterval(() => {
      if (window.google) {
        renderGoogleButton();
        clearInterval(interval);
      }
    }, 300);

    return () => clearInterval(interval);
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMessage("");

    if (!isValidFullName(fullName)) {
      setMessage("Full name must contain at least two parts");
      return;
    }

    if (!isValidPhone(phone)) {
      setMessage("Please enter a valid phone number");
      return;
    }

    try {
      const response = await fetch("http://localhost:5001/signup", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          name: fullName,
          email,
          password,
          phone,
          universityMajor,
          accountType,
          adminCode,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        setMessage(data.message || "Signup failed");
        return;
      }

      setMessage("Signup successful ✅");
      localStorage.setItem("user", JSON.stringify(data.user));

      setFullName("");
      setUniversityMajor("");
      setPhone("");
      setEmail("");
      setPassword("");
      setAdminCode("");

      setTimeout(() => {
        navigate("/home");
      }, 800);
    } catch (error) {
      console.error(error);
      setMessage("Server error");
    }
  };

  return (
    <div className="signup-page-new">
      <div className="signup-bg">
        <div className="grid-overlay"></div>
        <div className="radial-glow glow-1"></div>
        <div className="radial-glow glow-2"></div>
        <div className="radial-glow glow-3"></div>
        <span className="light-line line-1"></span>
        <span className="light-line line-2"></span>
        <span className="light-line line-3"></span>
      </div>

      <div className="signup-box-new">
        <div className="signup-left-new">
          <form className="signup-form-new" onSubmit={handleSubmit}>
            <img src={logo} alt="Cognito Logo" className="signup-logo-new" />

            <h1 className="signup-title-new">Create Account</h1>
            <p className="signup-subtitle-new">
              Create your account and begin your adaptive learning journey.
            </p>

            {/* Full Name */}
            <div className="signup-input-group-new">
              <input
                type="text"
                placeholder="Full Name"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                required
              />
              <span className="signup-input-icon-new">👤</span>
            </div>

            {/* Major */}
            <div className="signup-input-group-new">
              <input
                type="text"
                placeholder="University Major"
                value={universityMajor}
                onChange={(e) => setUniversityMajor(e.target.value)}
                required
              />
              <span className="signup-input-icon-new">🎓</span>
            </div>

            {/* Phone */}
            <div className="signup-input-group-new">
              <input
                type="tel"
                placeholder="Phone Number"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                required
              />
              <span className="signup-input-icon-new">📱</span>
            </div>

            {/* Email */}
            <div className="signup-input-group-new">
              <input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <span className="signup-input-icon-new">📧</span>
            </div>

            {/* Password */}
            <div className="signup-input-group-new password-group-new">
              <input
                type={showPassword ? "text" : "password"}
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              <span
                className="signup-input-icon-new signup-password-toggle-new"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? "🙈" : "🔒"}
              </span>
            </div>

            {/* ✅ Account Type */}
            <div className="signup-input-group-new">
              <select
                value={accountType}
                onChange={(e) => setAccountType(e.target.value)}
              >
                <option value="user">Student</option>
                <option value="admin">Admin</option>
              </select>
            </div>

            {/* ✅ Admin Code */}
            {accountType === "admin" && (
              <div className="signup-input-group-new">
                <input
                  type="text"
                  placeholder="Admin Secret Code"
                  value={adminCode}
                  onChange={(e) => setAdminCode(e.target.value)}
                  required
                />
              </div>
            )}

            <button type="submit" className="signup-btn-new">
              Create Account
            </button>

            <div className="signup-divider-new">
              <span>or</span>
            </div>

            <div id="googleSignUpDiv" className="google-signup-render"></div>

            {message && <p className="signup-message-new">{message}</p>}

            <p className="signup-footer-new">
              Already have an account?
              <span
                className="signup-link-new"
                onClick={() => navigate("/login")}
              >
                {" "}
                Login
              </span>
            </p>
          </form>
        </div>

        <div className="signup-right-new">
          <div className="signup-welcome-text-new">
            <h2>COGNITO</h2>
            <p>
              Start strong, discover your level, and build your future through
              a smarter IT learning experience.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Signup;