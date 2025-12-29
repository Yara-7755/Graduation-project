import { useEffect, useRef } from "react";
import "./Home.css";

function Home() {
  const carouselRef = useRef(null);

  useEffect(() => {
    const carrossel = carouselRef.current;
    const items = carrossel.querySelectorAll(".carrossel-item");
    const total = items.length;
    const radius = 120; 

    
    items.forEach((item, index) => {
      const angle = (360 / total) * index;
      item.style.transform = `rotateY(${angle}deg) translateZ(${radius}px)`;
    });

    let angle = 0;
    let animationFrameId;

    const rotate = () => {
      angle += 0.5; //speed
      carrossel.style.transform = `rotateY(-${angle}deg)`;
      animationFrameId = requestAnimationFrame(rotate);
    };

    rotate();

    return () => cancelAnimationFrame(animationFrameId);
  }, []);

  const fields = [
    "Frontend Development",
    "Backend Development",
    "Data Science",
    "Cybersecurity",
    "Cloud Computing",
    "UI/UX Design",
  ];

  return (
    <div className="home-page">
      {/* HERO */}
      <div className="home-hero">
        <h1 className="welcome-text">
          Welcome to <span>COGNITO</span>
        </h1>
        <p>
          A smart platform to assess your IT level, choose a field, and progress
          through a structured learning roadmap.
        </p>
      </div>

      {/* CAROUSEL */}
      <div className="container-carrossel">
        <div className="carrossel" ref={carouselRef}>
          {fields.map((field, index) => (
            <div className="carrossel-item" key={index}>
              {field}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default Home;
