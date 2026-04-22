import { useEffect, useRef, useState } from "react";
import "./ChatbotWidget.css";
import logo from "../assets/Logo_icon.png";

const API_BASE = "http://localhost:5001";

const DEFAULT_QUICK_ACTIONS = [
  "Recommend a path for me",
  "Explain Frontend vs Backend",
  "Help me choose my field",
  "What should I learn next?",
  "Explain the available paths",
];

const FALLBACK_QUICK_ACTIONS = [
  "Show me available paths",
  "Help me choose between Frontend and Backend",
  "What should I learn after the placement test?",
  "Explain Programming Fundamentals",
];

function ChatbotWidget() {
  const [open, setOpen] = useState(false);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [quickActions, setQuickActions] = useState(DEFAULT_QUICK_ACTIONS);

  const user =
    JSON.parse(localStorage.getItem("user")) ||
    JSON.parse(sessionStorage.getItem("user"));

  const [messages, setMessages] = useState([
    {
      role: "assistant",
      content:
        "Hi! I’m Cognito Assistant. I can help you understand the available paths, compare fields, and guide you toward the best choice for your learning journey.",
    },
  ]);

  const bodyRef = useRef(null);

  // ✅ NEW REFS
  const panelRef = useRef(null);
  const fabRef = useRef(null);

  useEffect(() => {
    if (bodyRef.current) {
      bodyRef.current.scrollTop = bodyRef.current.scrollHeight;
    }
  }, [messages, open, loading]);

  useEffect(() => {
    const openHandler = () => {
      setOpen(true);
    };

    window.addEventListener("openChatbot", openHandler);

    return () => {
      window.removeEventListener("openChatbot", openHandler);
    };
  }, []);

  // ✅ NEW: close on outside click
  useEffect(() => {
    function handleClickOutside(e) {
      if (
        open &&
        panelRef.current &&
        !panelRef.current.contains(e.target) &&
        fabRef.current &&
        !fabRef.current.contains(e.target)
      ) {
        setOpen(false);
      }
    }

    document.addEventListener("mousedown", handleClickOutside);

    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [open]);

  const buildFallbackReply = (userMessage) => {
    const text = userMessage.toLowerCase();

    if (text.includes("frontend") && text.includes("backend")) {
      return `Frontend focuses on the user interface and what users see and interact with. Backend focuses on server logic, APIs, databases, and system functionality behind the scenes.

A simple way to choose:
• Choose Frontend if you enjoy design, UI, and interaction.
• Choose Backend if you enjoy logic, systems, and APIs.

You can also ask me to recommend one based on your interests.`;
    }

    if (
      text.includes("recommend") ||
      text.includes("choose") ||
      text.includes("field")
    ) {
      return `I can still help you choose a path even if the live AI response is unavailable right now.

A quick guide:
• Frontend Development → for visual interfaces and user interaction
• Backend Development → for server logic and APIs
• Programming Fundamentals → best if you want strong coding basics first
• Mobile Development → for building smartphone applications
• Databases → for data storage and query design
• Cyber Security → for protection and secure systems
• UI/UX Design → for design and user experience
• Cloud Computing → for deployment, infrastructure, and scalability

Try one of the suggestion buttons and I’ll guide you step by step.`;
    }

    if (text.includes("path") || text.includes("available")) {
      return `Cognito currently offers these learning paths:
• Frontend Development
• Backend Development
• Databases
• Programming Fundamentals
• Cyber Security
• Mobile Development
• UI/UX Design
• Cloud Computing

You can ask me to compare any two of them, or ask which one fits you best.`;
    }

    if (text.includes("next") || text.includes("learn")) {
      return `A practical next step inside Cognito is:
1. Take the placement test
2. Review your detected level
3. Explore the paths
4. Choose the field that matches your interests
5. Start your roadmap topic by topic

If you already completed the placement test, the best next step is usually to open your dashboard and continue your roadmap.`;
    }

    if (text.includes("programming fundamentals")) {
      return `Programming Fundamentals is the foundation for almost every technical path.

It usually includes:
• variables and data types
• conditions and loops
• functions
• arrays
• problem solving and logic building

It is a great starting point if you want to strengthen your coding basics before specializing.`;
    }

    return `I couldn't reach the live AI service right now, but I can still guide you with built-in help.

You can ask me about:
• available paths
• Frontend vs Backend
• what to learn next
• how to choose your field

Try one of the suggestion buttons below.`;
  };

  const sendMessage = async (text) => {
    const trimmed = text.trim();
    if (!trimmed || loading) return;

    const newUserMessage = {
      role: "user",
      content: trimmed,
    };

    const updatedMessages = [...messages, newUserMessage];
    setMessages(updatedMessages);
    setInput("");
    setLoading(true);

    try {
      const response = await fetch(`${API_BASE}/ai/chatbot`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          userId: user?.id || null,
          message: trimmed,
          history: updatedMessages.slice(-8),
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data?.message || "Failed to get chatbot response");
      }

      setMessages((prev) => [
        ...prev,
        {
          role: "assistant",
          content:
            data?.reply ||
            "I can still help you. Try asking about paths, roadmap, or choosing a field.",
        },
      ]);

      setQuickActions(DEFAULT_QUICK_ACTIONS);
    } catch (error) {
      console.error("CHATBOT ERROR:", error);

      setMessages((prev) => [
        ...prev,
        {
          role: "assistant",
          content: buildFallbackReply(trimmed),
        },
      ]);

      setQuickActions(FALLBACK_QUICK_ACTIONS);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    sendMessage(input);
  };

  return (
    <>
      {/* FAB */}
      <div
        ref={fabRef}
        className="chatbot-fab"
        onClick={() => setOpen((prev) => !prev)}
      >
        <img src={logo} alt="Cognito Chatbot" />
      </div>

      {open && (
        <div ref={panelRef} className="chatbot-panel">
          <div className="chatbot-header">
            <div className="chatbot-title">
              <img src={logo} alt="Cognito Logo" />
              <div>
                <span>Cognito Assistant</span>
                <small>Guided AI Support</small>
              </div>
            </div>

            <button onClick={() => setOpen(false)}>✕</button>
          </div>

          <div className="chatbot-body" ref={bodyRef}>
            <div className="chatbot-quick-actions">
              {quickActions.map((action) => (
                <button
                  key={action}
                  className="quick-chip"
                  onClick={() => sendMessage(action)}
                  disabled={loading}
                >
                  {action}
                </button>
              ))}
            </div>

            <div className="chatbot-messages">
              {messages.map((msg, index) => (
                <div
                  key={index}
                  className={`chat-message ${
                    msg.role === "assistant" ? "assistant" : "user"
                  }`}
                >
                  {msg.content}
                </div>
              ))}

              {loading && (
                <div className="chat-message assistant typing">
                  Cognito Assistant is typing...
                </div>
              )}
            </div>
          </div>

          <form className="chatbot-input-area" onSubmit={handleSubmit}>
            <input
              type="text"
              placeholder="Ask about paths, roadmap, or what to learn next..."
              value={input}
              onChange={(e) => setInput(e.target.value)}
              disabled={loading}
            />
            <button type="submit" disabled={loading || !input.trim()}>
              Send
            </button>
          </form>
        </div>
      )}
    </>
  );
}

export default ChatbotWidget;