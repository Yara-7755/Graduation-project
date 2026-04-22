import { useState } from "react";
import { useNavigate } from "react-router-dom";
import Navbar from "../components/Navbar";
import AnimatedBackground from "../components/AnimatedBackground";
import "./Fields.css";

import {
  FaLaptopCode,
  FaServer,
  FaDatabase,
  FaCode,
  FaShieldAlt,
  FaMobileAlt,
  FaPaintBrush,
  FaCloud,
} from "react-icons/fa";

function Fields() {
  const navigate = useNavigate();
  const [selectedFields, setSelectedFields] = useState([]);
  const [saving, setSaving] = useState(false);

  const user =
    JSON.parse(localStorage.getItem("user")) ||
    JSON.parse(sessionStorage.getItem("user"));

  const fields = [
    {
      name: "Frontend Development",
      icon: <FaLaptopCode />,
      description:
        "Build modern, responsive, and interactive user interfaces that give applications a strong visual identity and smooth user experience.",
    },
    {
      name: "Backend Development",
      icon: <FaServer />,
      description:
        "Work on server-side logic, APIs, databases, authentication, and the core functionality that powers the system behind the scenes.",
    },
    {
      name: "Databases",
      icon: <FaDatabase />,
      description:
        "Learn data modeling, SQL, database management systems, query optimization, and how to store and retrieve data efficiently.",
    },
    {
      name: "Programming Fundamentals",
      icon: <FaCode />,
      description:
        "Start your journey with core programming concepts, problem-solving, algorithms, logic building, and writing clean code.",
    },
    {
      name: "Cyber Security",
      icon: <FaShieldAlt />,
      description:
        "Explore system protection, ethical hacking basics, network security, cryptography, risk analysis, and secure software practices.",
    },
    {
      name: "Mobile Development",
      icon: <FaMobileAlt />,
      description:
        "Learn how to build modern mobile applications for Android and iOS with responsive design, navigation, APIs, and real-world app features.",
    },
    {
      name: "UI/UX Design",
      icon: <FaPaintBrush />,
      description:
        "Learn how to design attractive and user-friendly digital experiences through wireframes, prototypes, design systems, usability, and visual design principles.",
    },
    {
      name: "Cloud Computing",
      icon: <FaCloud />,
      description:
        "Understand cloud services, deployment models, infrastructure, storage, security, and how modern applications run and scale in cloud environments.",
    },
  ];

  const toggleField = (fieldName) => {
    setSelectedFields((prev) =>
      prev.includes(fieldName)
        ? prev.filter((item) => item !== fieldName)
        : [...prev, fieldName]
    );
  };

  const handleSavePaths = async () => {
    try {
      if (!user || !user.id) {
        alert("User not found. Please login again.");
        navigate("/login");
        return;
      }

      if (selectedFields.length === 0) {
        alert("Please choose at least one path.");
        return;
      }

      setSaving(true);

      for (const fieldName of selectedFields) {
        const response = await fetch("http://localhost:5001/user/path", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            userId: user.id,
            pathName: fieldName,
          }),
        });

        const data = await response.json();

        if (!response.ok) {
          throw new Error(data.message || `Failed to save path: ${fieldName}`);
        }
      }

      navigate("/dashboard");
    } catch (err) {
      console.error("HANDLE SAVE PATHS ERROR:", err);
      alert(err.message || "Something went wrong");
    } finally {
      setSaving(false);
    }
  };

  return (
    <>
      <Navbar />

      <div className="fields-page">
        <AnimatedBackground />

        <div className="fields-content">
          <h1 className="fields-title">Choose Your Path</h1>
          <p className="fields-subtitle">
            Select one or more learning paths to continue your journey
          </p>

          <div className="fields-grid">
            {fields.map((field) => {
              const isSelected = selectedFields.includes(field.name);

              return (
                <div
                  key={field.name}
                  className={`flip-card ${isSelected ? "selected" : ""}`}
                >
                  <div className="flip-inner">
                    <div className="flip-front">
                      <div className="icon-box">{field.icon}</div>
                      <h2>{field.name}</h2>
                    </div>

                    <div className="flip-back">
                      <p>{field.description}</p>

                      <button onClick={() => toggleField(field.name)}>
                        {isSelected ? "Remove Path" : "Select Path"}
                      </button>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>

                    <div className="selected-summary">
            <p>
              <strong>Selected Paths:</strong>{" "}
              {selectedFields.length > 0 ? selectedFields.join(", ") : "None"}
            </p>

            <button
              className="save-paths-btn"
              onClick={handleSavePaths}
              disabled={saving || selectedFields.length === 0}
            >
              {saving ? "Saving..." : "Save Selected Paths"}
            </button>
          </div>
                  </div>
                </div>
              </>
            );
}

export default Fields;