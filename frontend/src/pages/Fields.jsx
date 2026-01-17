import { useNavigate } from "react-router-dom";
import Navbar from "../components/Navbar";
import "./Fields.css";

function Fields() {
  const navigate = useNavigate();
  const user = JSON.parse(localStorage.getItem("user"));

  const fields = [
    {
      name: "Frontend Development",
      description:
        "Build modern user interfaces using HTML, CSS, JavaScript, and frameworks like React.",
    },
    {
      name: "Backend Development",
      description:
        "Work on server-side logic, APIs, databases, authentication, and system architecture.",
    },
    {
      name: "Software Engineering",
      description:
        "Focus on problem solving, algorithms, software design, and development methodologies.",
    },
    {
      name: "Databases",
      description:
        "Learn data modeling, SQL, database management systems, and performance optimization.",
    },
    {
      name: "Cybersecurity",
      description:
        "Protect systems, networks, and data from attacks and vulnerabilities.",
    },
  ];

  const handleSelect = async (fieldName) => {
    try {
      await fetch("http://localhost:5001/user/field", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          userId: user.id,
          field: fieldName,
        }),
      });

      localStorage.setItem("field", fieldName);
      navigate("/dashboard");
    } catch (err) {
      console.error("Failed to save field", err);
      alert("Something went wrong");
    }
  };

  return (
    <>
      <Navbar />

      <div className="fields-page">
        <h1 className="fields-title">Choose Your PATH 🚀</h1>
        <p className="fields-subtitle">
          Select the path you want to continue your learning journey in
        </p>

        <div className="fields-grid">
          {fields.map((field) => (
            <div key={field.name} className="flip-card">
              <div className="flip-inner">

                {/* FRONT */}
                <div className="flip-front">
                  <h2>{field.name}</h2>
                </div>

                {/* BACK */}
                <div className="flip-back">
                  <p>{field.description}</p>
                  <button onClick={() => handleSelect(field.name)}>
                    Choose path
                  </button>
                </div>

              </div>
            </div>
          ))}
        </div>
      </div>
    </>
  );
}

export default Fields;
