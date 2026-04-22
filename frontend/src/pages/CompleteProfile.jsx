import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import "./CompleteProfile.css";
import logo from "../assets/Logo_icon.png";

function CompleteProfile() {
  const navigate = useNavigate();

  const storedUser =
    JSON.parse(localStorage.getItem("user")) ||
    JSON.parse(sessionStorage.getItem("user"));

  const [phone, setPhone] = useState(storedUser?.phone || "");
  const [universityMajor, setUniversityMajor] = useState(
    storedUser?.university_major || ""
  );
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!storedUser || !storedUser.id) {
      navigate("/login");
    }
  }, [storedUser, navigate]);

  const isValidPhone = (value) => {
    return /^[0-9+\-\s]{8,20}$/.test(value.trim());
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMessage("");

    if (!phone || !universityMajor) {
      setMessage("Please fill in all required fields");
      return;
    }

    if (!isValidPhone(phone)) {
      setMessage("Please enter a valid phone number");
      return;
    }

    try {
      setLoading(true);

      const res = await fetch("http://localhost:5001/user/complete-profile", {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          userId: storedUser.id,
          phone,
          universityMajor,
        }),
      });

      const data = await res.json();

      if (!res.ok) {
        setMessage(data.message || "Failed to complete profile");
        setLoading(false);
        return;
      }

      if (localStorage.getItem("user")) {
        localStorage.setItem("user", JSON.stringify(data.user));
      } else {
        sessionStorage.setItem("user", JSON.stringify(data.user));
      }

      setMessage("Profile completed successfully ");
      setLoading(false);

      setTimeout(() => {
        navigate("/home");
      }, 800);
    } catch (error) {
      console.error(error);
      setLoading(false);
      setMessage("Server error");
    }
  };

  return (
    <div className="complete-profile-page">
      <div className="complete-profile-bg">
        <div className="grid-overlay"></div>
        <div className="radial-glow glow-1"></div>
        <div className="radial-glow glow-2"></div>
        <div className="radial-glow glow-3"></div>
        <span className="light-line line-1"></span>
        <span className="light-line line-2"></span>
        <span className="light-line line-3"></span>
      </div>

      <div className="complete-profile-box">
        <div className="complete-profile-left">
          <form className="complete-profile-form" onSubmit={handleSubmit}>
            <img
              src={logo}
              alt="Cognito Logo"
              className="complete-profile-logo"
            />

           
            <h1 className="complete-profile-title">Complete Profile</h1>

            <p className="complete-profile-subtitle">
              Please complete your information to continue using Cognito.
            </p>

            <div className="complete-profile-input-group">
              <input
                type="text"
                value={storedUser?.name || ""}
                disabled
                placeholder="Full Name"
              />
              <span className="complete-profile-input-icon">👤</span>
            </div>

            <div className="complete-profile-input-group">
              <input
                type="email"
                value={storedUser?.email || ""}
                disabled
                placeholder="Email"
              />
              <span className="complete-profile-input-icon">📧</span>
            </div>

            <div className="complete-profile-input-group">
              <input
                type="tel"
                placeholder="Phone Number"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                required
              />
              <span className="complete-profile-input-icon">📱</span>
            </div>

            <div className="complete-profile-input-group">
              <input
                type="text"
                placeholder="University Major"
                value={universityMajor}
                onChange={(e) => setUniversityMajor(e.target.value)}
                required
              />
              <span className="complete-profile-input-icon">🎓</span>
            </div>

            <button
              type="submit"
              className="complete-profile-btn"
              disabled={loading}
            >
              {loading ? "Saving..." : "Save & Continue"}
            </button>

            {message && <p className="complete-profile-message">{message}</p>}
          </form>
        </div>

        <div className="complete-profile-right">
          <div className="complete-profile-welcome-text">
            <h2>COGNITO</h2>
            <p>
              Complete your profile so we can personalize your experience and
              guide you through the right learning path.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default CompleteProfile;