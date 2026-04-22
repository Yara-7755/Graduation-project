import { Routes, Route, Navigate } from "react-router-dom";

import Landing from "./pages/Landing";
import Signup from "./pages/Signup";
import Login from "./pages/Login";
import Home from "./pages/Home";
import PlacementTest from "./pages/PlacementTest";
import Fields from "./pages/Fields";
import Dashboard from "./pages/Dashboard";
import CompleteProfile from "./pages/CompleteProfile";
import RoadmapPage from "./pages/RoadmapPage";
import Topic from "./pages/Topic";
import TopicQuiz from "./pages/TopicQuiz";
import PathsOverview from "./pages/PathsOverview";
import ProfilePage from "./pages/ProfilePage";
import GradesPage from "./pages/GradesPage";
import CalendarPage from "./pages/CalendarPage";
import ChatbotWidget from "./components/ChatbotWidget";
import GlobalBackground from "./components/GlobalBackground";
import AdminPanel from "./pages/AdminPanel";
import SelectFieldPage from "./pages/SelectFieldPage";

function ProtectedAdminRoute({ children }) {
  let user = null;

  try {
    user =
      JSON.parse(localStorage.getItem("user")) ||
      JSON.parse(sessionStorage.getItem("user"));
  } catch {
    user = null;
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (user.role !== "admin") {
    return <Navigate to="/home" replace />;
  }

  return children;
}

function App() {
  return (
    <>
      <GlobalBackground />

      <Routes>
        <Route path="/" element={<Landing />} />
        <Route path="/signup" element={<Signup />} />
        <Route path="/login" element={<Login />} />
        <Route path="/home" element={<Home />} />
        <Route path="/placement-test" element={<PlacementTest />} />
        <Route path="/fields" element={<Fields />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/complete-profile" element={<CompleteProfile />} />

        <Route path="/select-field/roadmap" element={<SelectFieldPage mode="roadmap" />} />
        <Route path="/select-field/grades" element={<SelectFieldPage mode="grades" />} />

        <Route path="/roadmap/:fieldName" element={<RoadmapPage />} />
        <Route path="/topic/:topicId" element={<Topic />} />
        <Route path="/topic/:topicId/quiz" element={<TopicQuiz />} />
        <Route path="/paths-overview" element={<PathsOverview />} />
        <Route path="/profile" element={<ProfilePage />} />
        <Route path="/grades" element={<GradesPage />} />
        <Route path="/calendar" element={<CalendarPage />} />

        <Route
          path="/admin"
          element={
            <ProtectedAdminRoute>
              <AdminPanel />
            </ProtectedAdminRoute>
          }
        />
      </Routes>

      <ChatbotWidget />
    </>
  );
}

export default App;