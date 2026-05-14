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
import CodeReviewPage from "./pages/CodeReviewPage";

function getStoredUser() {
  try {
    return (
      JSON.parse(localStorage.getItem("user")) ||
      JSON.parse(sessionStorage.getItem("user"))
    );
  } catch {
    return null;
  }
}

function ProtectedAdminRoute({ children }) {
  const user = getStoredUser();

  if (!user) return <Navigate to="/login" replace />;

  if (user.role !== "admin") {
    return <Navigate to="/home" replace />;
  }

  return children;
}

function LearnerOnlyRoute({ children }) {
  const user = getStoredUser();

  if (user?.role === "admin") {
    return <Navigate to="/admin" replace />;
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

        <Route
          path="/home"
          element={
            <LearnerOnlyRoute>
              <Home />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/placement-test"
          element={
            <LearnerOnlyRoute>
              <PlacementTest />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/fields"
          element={
            <LearnerOnlyRoute>
              <Fields />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/dashboard"
          element={
            <LearnerOnlyRoute>
              <Dashboard />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/complete-profile"
          element={
            <LearnerOnlyRoute>
              <CompleteProfile />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/select-field/roadmap"
          element={
            <LearnerOnlyRoute>
              <SelectFieldPage mode="roadmap" />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/select-field/grades"
          element={
            <LearnerOnlyRoute>
              <SelectFieldPage mode="grades" />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/roadmap/:fieldName"
          element={
            <LearnerOnlyRoute>
              <RoadmapPage />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/topic/:topicId"
          element={
            <LearnerOnlyRoute>
              <Topic />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/topic/:topicId/quiz"
          element={
            <LearnerOnlyRoute>
              <TopicQuiz />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/paths-overview"
          element={
            <LearnerOnlyRoute>
              <PathsOverview />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/profile"
          element={
            <LearnerOnlyRoute>
              <ProfilePage />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/grades"
          element={
            <LearnerOnlyRoute>
              <GradesPage />
            </LearnerOnlyRoute>
          }
        />

        <Route
          path="/calendar"
          element={
            <LearnerOnlyRoute>
              <CalendarPage />
            </LearnerOnlyRoute>
          }
        />
        <Route
  path="/code-review"
  element={
    <LearnerOnlyRoute>
      <CodeReviewPage />
    </LearnerOnlyRoute>
  }
/>

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