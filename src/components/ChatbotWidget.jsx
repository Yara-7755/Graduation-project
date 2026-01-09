import { useState } from "react";
import "./ChatbotWidget.css";

// ✅ استيراد الشعار
import logo from "../assets/logo_icon.png";

function ChatbotWidget() {
  const [open, setOpen] = useState(false);

  return (
    <>
      {/* 🤖 Floating Button (LOGO بدل الإيموجي) */}
      <div className="chatbot-fab" onClick={() => setOpen(!open)}>
        <img src={logo} alt="Cognito Chatbot" />
      </div>

      {/* 💬 Chat Panel */}
      {open && (
        <div className="chatbot-panel">
          <div className="chatbot-header">
            <div className="chatbot-title">
              <img src={logo} alt="Cognito Logo" />
              <span>AI Chatbot</span>
            </div>
            <button onClick={() => setOpen(false)}>✕</button>
          </div>

          <div className="chatbot-body">
            <p>
              🚧 This AI-powered chatbot will be available in
              <strong> Graduation Project 2</strong>.
            </p>
          </div>
        </div>
      )}
    </>
  );
}

export default ChatbotWidget;
