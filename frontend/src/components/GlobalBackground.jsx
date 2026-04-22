import { useEffect, useMemo, useState } from "react";
import "./GlobalBackground.css";

function GlobalBackground() {
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });

  const particles = useMemo(
    () =>
      Array.from({ length: 22 }, (_, i) => ({
        id: i,
        left: `${Math.random() * 100}%`,
        top: `${Math.random() * 100}%`,
        delay: `${Math.random() * 8}s`,
        duration: `${5 + Math.random() * 7}s`,
        size: `${4 + Math.random() * 4}px`,
      })),
    []
  );

  useEffect(() => {
    const handleMouseMove = (e) => {
      const x = (e.clientX / window.innerWidth - 0.5) * 2;
      const y = (e.clientY / window.innerHeight - 0.5) * 2;
      setMousePosition({ x, y });
    };

    window.addEventListener("mousemove", handleMouseMove);
    return () => window.removeEventListener("mousemove", handleMouseMove);
  }, []);

  return (
    <div className="global-bg">
      <div
        className="global-grid-overlay"
        style={{
          transform: `translate(${mousePosition.x * -10}px, ${mousePosition.y * -10}px)`,
        }}
      />

      <div
        className="global-radial-glow global-glow-1"
        style={{
          transform: `translate(${mousePosition.x * 24}px, ${mousePosition.y * 20}px)`,
        }}
      />
      <div
        className="global-radial-glow global-glow-2"
        style={{
          transform: `translate(${mousePosition.x * -30}px, ${mousePosition.y * -18}px)`,
        }}
      />
      <div
        className="global-radial-glow global-glow-3"
        style={{
          transform: `translate(${mousePosition.x * 18}px, ${mousePosition.y * -24}px)`,
        }}
      />

      <span className="global-line global-line-1"></span>
      <span className="global-line global-line-2"></span>
      <span className="global-line global-line-3"></span>

      <div className="global-energy-ring global-energy-ring-1"></div>
      <div className="global-energy-ring global-energy-ring-2"></div>

      {particles.map((particle) => (
        <span
          key={particle.id}
          className="global-particle"
          style={{
            left: particle.left,
            top: particle.top,
            width: particle.size,
            height: particle.size,
            animationDelay: particle.delay,
            animationDuration: particle.duration,
          }}
        />
      ))}
    </div>
  );
}

export default GlobalBackground;