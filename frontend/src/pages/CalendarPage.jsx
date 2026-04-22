import { useEffect, useMemo, useState } from "react";
import Navbar from "../components/Navbar";
import "./CalendarPage.css";

const fallbackWeekDays = [
  {
    day: "Sunday",
    short: "Sun",
    date: "Day 1",
    type: "review",
    focus: "Roadmap Review",
    duration: "1.5 hrs",
    time: "5:00 PM - 6:30 PM",
    title: "Review current roadmap topic",
    description:
      "Read the topic summary and go through the main learning resources.",
    tasks: [
      "Read topic overview",
      "Watch the recommended lesson",
      "Take short notes",
    ],
  },
  {
    day: "Monday",
    short: "Mon",
    date: "Day 2",
    type: "practice",
    focus: "Coding Practice",
    duration: "2 hrs",
    time: "6:00 PM - 8:00 PM",
    title: "Hands-on practice session",
    description:
      "Apply what you studied through short exercises and guided examples.",
    tasks: [
      "Solve 3 practice exercises",
      "Review mistakes",
      "Repeat weak concepts",
    ],
  },
  {
    day: "Tuesday",
    short: "Tue",
    date: "Day 3",
    type: "quiz",
    focus: "Quiz + Weak Areas",
    duration: "1 hr",
    time: "7:00 PM - 8:00 PM",
    title: "Practice and solve quiz questions",
    description:
      "Focus on practice, topic quizzes, and understanding weak areas.",
    tasks: [
      "Solve topic quiz",
      "Mark weak answers",
      "Revise weak topics",
    ],
  },
  {
    day: "Wednesday",
    short: "Wed",
    date: "Day 4",
    type: "ai",
    focus: "AI Recommendation Day",
    duration: "45 mins",
    time: "5:30 PM - 6:15 PM",
    title: "Smart revision session",
    description:
      "Follow personalized study suggestions based on your roadmap progress.",
    tasks: [
      "Open AI study tips",
      "Review priority topic",
      "Prepare for next milestone",
    ],
  },
  {
    day: "Thursday",
    short: "Thu",
    date: "Day 5",
    type: "progress",
    focus: "Progress Tracking",
    duration: "1 hr",
    time: "6:00 PM - 7:00 PM",
    title: "Track progress and prepare next step",
    description:
      "Check your roadmap progress and decide what to continue next.",
    tasks: [
      "Check completed topics",
      "Update progress",
      "Set next study target",
    ],
  },
  {
    day: "Friday",
    short: "Fri",
    date: "Day 6",
    type: "light",
    focus: "Light Revision",
    duration: "30 mins",
    time: "4:30 PM - 5:00 PM",
    title: "Quick revision session",
    description:
      "A lighter study block to refresh what you learned during the week.",
    tasks: [
      "Review notes",
      "Check flash points",
      "Prepare for next week",
    ],
  },
  {
    day: "Saturday",
    short: "Sat",
    date: "Day 7",
    type: "rest",
    focus: "Recovery / Flex Day",
    duration: "Flexible",
    time: "Anytime",
    title: "Rest or catch-up",
    description:
      "Use this day to rest, or catch up if any learning task was missed.",
    tasks: [
      "Rest",
      "Catch up unfinished tasks",
      "Plan next week",
    ],
  },
];

const fallbackUpcomingTasks = [
  {
    label: "Next Quiz",
    value: "Tuesday",
    note: "Topic Quiz - Backend Fundamentals",
  },
  {
    label: "Priority Topic",
    value: "APIs",
    note: "Recommended based on current path progress",
  },
  {
    label: "Suggested Session",
    value: "Wednesday",
    note: "AI-generated focused revision block",
  },
];

const fallbackAiSuggestions = [
  "You are progressing well in your roadmap. A focused revision session this week would improve your momentum.",
  "Try keeping your quiz practice in the middle of the week for better consistency.",
  "A short smart review before your progress tracking day can reduce overload.",
];

function getTypeFromTitle(title = "") {
  const text = String(title).toLowerCase();

  if (text.includes("quiz")) return "quiz";
  if (text.includes("review")) return "review";
  if (text.includes("practice")) return "practice";
  if (text.includes("progress")) return "progress";
  if (text.includes("rest")) return "rest";
  if (text.includes("ai")) return "ai";

  return "ai";
}

function buildPlanWithUiFields(plan = []) {
  const shortDays = {
    Sunday: "Sun",
    Monday: "Mon",
    Tuesday: "Tue",
    Wednesday: "Wed",
    Thursday: "Thu",
    Friday: "Fri",
    Saturday: "Sat",
  };

  return plan.map((item, index) => ({
    day: item.day || fallbackWeekDays[index]?.day || `Day ${index + 1}`,
    short:
      shortDays[item.day] ||
      fallbackWeekDays[index]?.short ||
      `D${index + 1}`,
    date: `Day ${index + 1}`,
    type: getTypeFromTitle(item.title || item.focus),
    focus: item.focus || item.title || "Study Session",
    duration: item.duration || "1 hr",
    time: item.time || "Suggested by AI",
    title: item.title || "Study Session",
    description:
      item.description ||
      "Personalized study session generated for your current roadmap.",
    tasks:
      Array.isArray(item.tasks) && item.tasks.length
        ? item.tasks
        : ["Review topic", "Practice key ideas", "Track your progress"],
  }));
}

function CalendarPage() {
  const [selectedDayIndex, setSelectedDayIndex] = useState(0);
  const [aiPlan, setAiPlan] = useState([]);
  const [loadingPlan, setLoadingPlan] = useState(false);
  const [planMessage, setPlanMessage] = useState("");

  const activePlan = aiPlan.length ? aiPlan : fallbackWeekDays;

  const selectedDay = useMemo(
    () => activePlan[selectedDayIndex] || activePlan[0],
    [selectedDayIndex, activePlan]
  );

  const completedCount = Math.max(
    1,
    activePlan.filter((item) => item.type === "progress" || item.type === "quiz")
      .length
  );
  const totalCount = activePlan.length || 7;
  const completionRate = Math.round((completedCount / totalCount) * 100);

  const upcomingTasks = aiPlan.length
    ? [
        {
          label: "Next Focus",
          value: activePlan[0]?.focus || "Study",
          note: activePlan[0]?.title || "Start with the first AI-generated day",
        },
        {
          label: "Priority Day",
          value: activePlan[1]?.day || "Tomorrow",
          note:
            activePlan[1]?.description ||
            "Continue with the next recommended session",
        },
        {
          label: "Smart Session",
          value: activePlan[2]?.day || "This Week",
          note:
            activePlan[2]?.focus || "AI created a personalized study block",
        },
      ]
    : fallbackUpcomingTasks;

  const aiSuggestions = aiPlan.length
    ? [
        `Your weekly plan was generated based on your current level and roadmap.`,
        `Stay consistent with ${activePlan[0]?.focus || "your first study block"} to build momentum.`,
        `Use this plan as a guide, then adjust your pace based on quiz performance.`,
      ]
    : fallbackAiSuggestions;

  useEffect(() => {
    if (selectedDayIndex >= activePlan.length) {
      setSelectedDayIndex(0);
    }
  }, [activePlan, selectedDayIndex]);

  const generatePlan = async () => {
    const user =
      JSON.parse(localStorage.getItem("user")) ||
      JSON.parse(sessionStorage.getItem("user"));

    if (!user?.id) {
      setPlanMessage("User data not found. Please login again.");
      return;
    }

    setLoadingPlan(true);
    setPlanMessage("");

    try {
      const res = await fetch("http://localhost:5001/ai/study-plan", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ userId: user.id }),
      });

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data?.message || "Failed to generate study plan");
      }

      if (Array.isArray(data.plan) && data.plan.length > 0) {
        const normalizedPlan = buildPlanWithUiFields(data.plan);
        setAiPlan(normalizedPlan);
        setSelectedDayIndex(0);
        setPlanMessage("Your AI weekly plan is ready.");
      } else {
        setPlanMessage(
          data?.message || "No AI plan generated yet. Showing default planner."
        );
      }
    } catch (error) {
      console.error("GENERATE PLAN ERROR:", error);
      setPlanMessage("Could not generate AI plan right now.");
    } finally {
      setLoadingPlan(false);
    }
  };

  return (
    <>
      <Navbar />

      <main className="calendar-page">
        <section className="calendar-hero-card">
          <div className="calendar-badge">Smart Study Planner</div>

          <div className="calendar-hero-top">
            <div>
              <h1>Your Learning Calendar</h1>
              <p>
                Organize your week, track study sessions, and get smart
                recommendations that help you move through your Cognito roadmap
                more efficiently.
              </p>
            </div>

            <div className="calendar-hero-actions">
              <button
                className="calendar-primary-btn"
                onClick={generatePlan}
                disabled={loadingPlan}
              >
                {loadingPlan ? "Generating..." : "Generate Weekly Plan"}
              </button>

              <button
                className="calendar-secondary-btn"
                onClick={generatePlan}
                disabled={loadingPlan}
              >
                {loadingPlan ? "Please wait..." : "Ask AI for Suggestions"}
              </button>
            </div>
          </div>

          {planMessage && <p className="calendar-plan-message">{planMessage}</p>}
        </section>

        <section className="calendar-stats-grid">
          <div className="calendar-stat-card">
            <span className="stat-label">This Week Progress</span>
            <strong>{completionRate}%</strong>
            <p>{completedCount} of {totalCount} study blocks highlighted</p>
          </div>

          <div className="calendar-stat-card">
            <span className="stat-label">Selected Focus</span>
            <strong>{selectedDay?.focus}</strong>
            <p>{selectedDay?.duration} planned for this session</p>
          </div>

          <div className="calendar-stat-card">
            <span className="stat-label">Best Next Step</span>
            <strong>{activePlan[0]?.focus || "Quiz Practice"}</strong>
            <p>Recommended based on your current study flow</p>
          </div>
        </section>

        <section className="calendar-main-grid">
          <div className="calendar-left-column">
            <div className="calendar-card">
              <div className="section-head">
                <div>
                  <h2>Weekly Interactive Calendar</h2>
                  <p>Select a day to view its learning plan and tasks.</p>
                </div>
              </div>

              <div className="week-strip">
                {activePlan.map((item, index) => (
                  <button
                    key={`${item.day}-${index}`}
                    className={`week-day-card ${
                      selectedDayIndex === index ? "active" : ""
                    } ${item.type}`}
                    onClick={() => setSelectedDayIndex(index)}
                  >
                    <span className="week-day-short">{item.short}</span>
                    <span className="week-day-date">{item.date}</span>
                    <span className="week-day-focus">{item.focus}</span>
                  </button>
                ))}
              </div>
            </div>

            <div className="calendar-card">
              <div className="section-head">
                <div>
                  <h2>Selected Day Details</h2>
                  <p>Detailed plan for {selectedDay?.day}</p>
                </div>
                <span className={`type-badge ${selectedDay?.type}`}>
                  {selectedDay?.type}
                </span>
              </div>

              <div className="selected-day-card">
                <div className="selected-day-top">
                  <div>
                    <h3>{selectedDay?.title}</h3>
                    <p>{selectedDay?.description}</p>
                  </div>

                  <div className="selected-day-meta">
                    <div>
                      <span>Time</span>
                      <strong>{selectedDay?.time}</strong>
                    </div>
                    <div>
                      <span>Duration</span>
                      <strong>{selectedDay?.duration}</strong>
                    </div>
                  </div>
                </div>

                <div className="task-checklist">
                  {(selectedDay?.tasks || []).map((task, index) => (
                    <div key={index} className="task-check-item">
                      <span className="task-dot"></span>
                      <p>{task}</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          <div className="calendar-right-column">
            <div className="calendar-card">
              <div className="section-head">
                <div>
                  <h2>Upcoming Tasks</h2>
                  <p>Your most important learning checkpoints.</p>
                </div>
              </div>

              <div className="upcoming-list">
                {upcomingTasks.map((task, index) => (
                  <div key={index} className="upcoming-item">
                    <div className="upcoming-item-top">
                      <span>{task.label}</span>
                      <strong>{task.value}</strong>
                    </div>
                    <p>{task.note}</p>
                  </div>
                ))}
              </div>
            </div>

            <div className="calendar-card ai-card">
              <div className="section-head">
                <div>
                  <h2>AI Study Suggestions</h2>
                  <p>Adaptive tips based on your roadmap behavior.</p>
                </div>
              </div>

              <div className="ai-suggestion-list">
                {aiSuggestions.map((suggestion, index) => (
                  <div key={index} className="ai-suggestion-item">
                    <span className="ai-icon">✦</span>
                    <p>{suggestion}</p>
                  </div>
                ))}
              </div>

              <button
                className="calendar-primary-btn full-width"
                onClick={generatePlan}
                disabled={loadingPlan}
              >
                {loadingPlan ? "Generating..." : "Generate Smarter Plan"}
              </button>
            </div>
          </div>
        </section>
      </main>
    </>
  );
}

export default CalendarPage;