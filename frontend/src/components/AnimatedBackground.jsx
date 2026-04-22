import "./AnimatedBackground.css";

function AnimatedBackground() {
  return (
    <div className="animated-bg">
      <div className="grid-overlay"></div>

      <div className="radial-glow glow-1"></div>
      <div className="radial-glow glow-2"></div>
      <div className="radial-glow glow-3"></div>

      <span className="home-line line-1"></span>
      <span className="home-line line-2"></span>
      <span className="home-line line-3"></span>
    </div>
  );
}

export default AnimatedBackground;