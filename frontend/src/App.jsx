import { Routes, Route } from "react-router-dom";

import Landing from "./pages/Landing";
import Signup from "./pages/Signup";
import Login from "./pages/Login";
import Home from "./pages/Home";
import PlacementTest from "./pages/PlacementTest";
import Fields from "./pages/Fields";
import Dashboard from "./pages/Dashboard";
import ChatbotWidget from "./components/ChatbotWidget";

function App() {
  return (
    <>
      <Routes>
        <Route path="/" element={<Landing />} />
        <Route path="/signup" element={<Signup />} />
        <Route path="/login" element={<Login />} />
        <Route path="/home" element={<Home />} />
        <Route path="/placement-test" element={<PlacementTest />} />
        <Route path="/fields" element={<Fields />} />
        <Route path="/dashboard" element={<Dashboard />} />
      </Routes>

      {/* 🤖 CHATBOT – GLOBAL */}
      <ChatbotWidget />
    </>
  );
}

export default App;
