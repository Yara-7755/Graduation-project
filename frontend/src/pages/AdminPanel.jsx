import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import "./AdminPanel.css";

const API_BASE = "http://localhost:5001";

const tabs = [
  { key: "overview", label: "Overview" },
  { key: "topics", label: "Topics" },
  { key: "questions", label: "Questions" },
  { key: "resources", label: "Resources" },
  { key: "learners", label: "Learners" },
  { key: "analytics", label: "Analytics" },
];

const initialTopicForm = {
  title: "",
  description: "",
  field: "",
  level: "Beginner",
  order_number: "",
};

const initialQuestionForm = {
  topic_id: "",
  question: "",
  option_a: "",
  option_b: "",
  option_c: "",
  option_d: "",
  correct_option: "A",
  difficulty: "Beginner",
  quiz_type: "topic",
};

const initialResourceForm = {
  topic_id: "",
  title: "",
  url: "",
  type: "VIDEO",
  level: "Beginner",
};

function AdminPanel() {
  const navigate = useNavigate();

  const [activeTab, setActiveTab] = useState("overview");
  const [loading, setLoading] = useState(false);
  const [pageMessage, setPageMessage] = useState("");
  const [pageMessageType, setPageMessageType] = useState("success");

  const [stats, setStats] = useState({
    usersCount: 0,
    topicsCount: 0,
    questionsCount: 0,
    resourcesCount: 0,
    completedQuizzesCount: 0,
  });

  const [topics, setTopics] = useState([]);
  const [questions, setQuestions] = useState([]);
  const [resources, setResources] = useState([]);
  const [learners, setLearners] = useState([]);
  const [analytics, setAnalytics] = useState({
    usersByLevel: [],
    topFields: [],
    avgQuizScore: 0,
  });

  const [topicForm, setTopicForm] = useState(initialTopicForm);
  const [questionForm, setQuestionForm] = useState(initialQuestionForm);
  const [resourceForm, setResourceForm] = useState(initialResourceForm);

  const [editingTopicId, setEditingTopicId] = useState(null);
  const [editingQuestionId, setEditingQuestionId] = useState(null);
  const [editingResourceId, setEditingResourceId] = useState(null);

  const [topicSearch, setTopicSearch] = useState("");
  const [questionSearch, setQuestionSearch] = useState("");
  const [resourceSearch, setResourceSearch] = useState("");
  const [learnerSearch, setLearnerSearch] = useState("");

  const user = useMemo(() => {
    try {
      return (
        JSON.parse(localStorage.getItem("user")) ||
        JSON.parse(sessionStorage.getItem("user"))
      );
    } catch {
      return null;
    }
  }, []);

  const authHeaders = useMemo(
    () => ({
      "Content-Type": "application/json",
      "x-user-role": user?.role || "",
      "x-user-id": String(user?.id || ""),
    }),
    [user]
  );

  useEffect(() => {
    if (!user || user.role !== "admin") {
      navigate("/home", { replace: true });
      return;
    }

    loadAllData();
  }, []);

  const showMessage = (msg, type = "success") => {
    setPageMessage(msg);
    setPageMessageType(type);
    setTimeout(() => {
      setPageMessage("");
      setPageMessageType("success");
    }, 2500);
  };

  const handleApiError = async (res, fallbackMessage) => {
    try {
      const data = await res.json();
      throw new Error(data?.message || fallbackMessage);
    } catch (err) {
      throw new Error(err.message || fallbackMessage);
    }
  };

  const fetchJson = async (url, fallbackMessage) => {
    const res = await fetch(url, { headers: authHeaders });
    if (!res.ok) {
      await handleApiError(res, fallbackMessage);
    }
    return res.json();
  };

  const loadAllData = async () => {
    if (!user || user.role !== "admin") {
      showMessage("Access denied", "error");
      return;
    }

    setLoading(true);

    try {
      await Promise.all([
        fetchStats(),
        fetchTopics(),
        fetchQuestions(),
        fetchResources(),
        fetchLearners(),
        fetchAnalytics(),
      ]);
    } catch (error) {
      console.error(error);
      showMessage(error.message || "Failed to load admin data", "error");
    } finally {
      setLoading(false);
    }
  };

  const fetchStats = async () => {
    const data = await fetchJson(`${API_BASE}/admin/stats`, "Failed to fetch stats");
    setStats({
      usersCount: data.usersCount || 0,
      topicsCount: data.topicsCount || 0,
      questionsCount: data.questionsCount || 0,
      resourcesCount: data.resourcesCount || 0,
      completedQuizzesCount: data.completedQuizzesCount || 0,
    });
  };

  const fetchTopics = async () => {
    const data = await fetchJson(`${API_BASE}/admin/topics`, "Failed to fetch topics");
    setTopics(Array.isArray(data) ? data : data.topics || []);
  };

  const fetchQuestions = async () => {
    const data = await fetchJson(`${API_BASE}/admin/questions`, "Failed to fetch questions");
    setQuestions(Array.isArray(data) ? data : data.questions || []);
  };

  const fetchResources = async () => {
    const data = await fetchJson(`${API_BASE}/admin/resources`, "Failed to fetch resources");
    setResources(Array.isArray(data) ? data : data.resources || []);
  };

  const fetchLearners = async () => {
    const data = await fetchJson(`${API_BASE}/admin/learners`, "Failed to fetch learners");
    setLearners(Array.isArray(data) ? data : data.learners || []);
  };

  const fetchAnalytics = async () => {
    const data = await fetchJson(`${API_BASE}/admin/analytics`, "Failed to fetch analytics");
    setAnalytics({
      usersByLevel: data.usersByLevel || [],
      topFields: data.topFields || [],
      avgQuizScore: data.avgQuizScore || 0,
    });
  };

  const refreshAfterChange = async () => {
    await Promise.all([
      fetchTopics(),
      fetchQuestions(),
      fetchResources(),
      fetchLearners(),
      fetchStats(),
      fetchAnalytics(),
    ]);
  };

  const resetTopicForm = () => {
    setEditingTopicId(null);
    setTopicForm(initialTopicForm);
  };

  const resetQuestionForm = () => {
    setEditingQuestionId(null);
    setQuestionForm(initialQuestionForm);
  };

  const resetResourceForm = () => {
    setEditingResourceId(null);
    setResourceForm(initialResourceForm);
  };

  const handleTopicSubmit = async (e) => {
    e.preventDefault();

    const payload = {
      title: topicForm.title.trim(),
      description: topicForm.description.trim(),
      field: topicForm.field.trim(),
      level: topicForm.level,
      order_number: Number(topicForm.order_number),
    };

    try {
      const url = editingTopicId
        ? `${API_BASE}/admin/topics/${editingTopicId}`
        : `${API_BASE}/admin/topics`;

      const method = editingTopicId ? "PUT" : "POST";

      const res = await fetch(url, {
        method,
        headers: authHeaders,
        body: JSON.stringify(payload),
      });

      if (!res.ok) {
        await handleApiError(
          res,
          editingTopicId ? "Failed to update topic" : "Failed to create topic"
        );
      }

      resetTopicForm();
      await refreshAfterChange();
      showMessage(editingTopicId ? "Topic updated" : "Topic created");
    } catch (error) {
      console.error(error);
      showMessage(error.message, "error");
    }
  };

  const handleQuestionSubmit = async (e) => {
    e.preventDefault();

    const payload = {
      topic_id: Number(questionForm.topic_id),
      question: questionForm.question.trim(),
      option_a: questionForm.option_a.trim(),
      option_b: questionForm.option_b.trim(),
      option_c: questionForm.option_c.trim(),
      option_d: questionForm.option_d.trim(),
      correct_option: questionForm.correct_option,
      difficulty: questionForm.difficulty,
      quiz_type: questionForm.quiz_type,
    };

    try {
      const url = editingQuestionId
        ? `${API_BASE}/admin/questions/${editingQuestionId}`
        : `${API_BASE}/admin/questions`;

      const method = editingQuestionId ? "PUT" : "POST";

      const res = await fetch(url, {
        method,
        headers: authHeaders,
        body: JSON.stringify(payload),
      });

      if (!res.ok) {
        await handleApiError(
          res,
          editingQuestionId
            ? "Failed to update question"
            : "Failed to create question"
        );
      }

      resetQuestionForm();
      await refreshAfterChange();
      showMessage(editingQuestionId ? "Question updated" : "Question created");
    } catch (error) {
      console.error(error);
      showMessage(error.message, "error");
    }
  };

  const handleResourceSubmit = async (e) => {
    e.preventDefault();

    const payload = {
      topic_id: Number(resourceForm.topic_id),
      title: resourceForm.title.trim(),
      url: resourceForm.url.trim(),
      type: resourceForm.type,
      level: resourceForm.level,
    };

    try {
      const url = editingResourceId
        ? `${API_BASE}/admin/resources/${editingResourceId}`
        : `${API_BASE}/admin/resources`;

      const method = editingResourceId ? "PUT" : "POST";

      const res = await fetch(url, {
        method,
        headers: authHeaders,
        body: JSON.stringify(payload),
      });

      if (!res.ok) {
        await handleApiError(
          res,
          editingResourceId
            ? "Failed to update resource"
            : "Failed to create resource"
        );
      }

      resetResourceForm();
      await refreshAfterChange();
      showMessage(editingResourceId ? "Resource updated" : "Resource created");
    } catch (error) {
      console.error(error);
      showMessage(error.message, "error");
    }
  };

  const deleteItem = async (type, id) => {
    const confirmed = window.confirm(
      `Are you sure you want to delete this ${type.slice(0, -1)}?`
    );
    if (!confirmed) return;

    try {
      const res = await fetch(`${API_BASE}/admin/${type}/${id}`, {
        method: "DELETE",
        headers: authHeaders,
      });

      if (!res.ok) {
        await handleApiError(res, `Failed to delete ${type}`);
      }

      await refreshAfterChange();
      showMessage(`${type.slice(0, -1)} deleted successfully`);
    } catch (error) {
      console.error(error);
      showMessage(error.message, "error");
    }
  };

  const startEditTopic = (topic) => {
    setEditingTopicId(topic.id);
    setTopicForm({
      title: topic.title || "",
      description: topic.description || "",
      field: topic.field || topic.field_name || "",
      level: topic.level || "Beginner",
      order_number: topic.order_number || topic.topic_order || "",
    });
    setActiveTab("topics");
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const startEditQuestion = (q) => {
    setEditingQuestionId(q.id);
    setQuestionForm({
      topic_id: q.topic_id || "",
      question: q.question || "",
      option_a: q.option_a || "",
      option_b: q.option_b || "",
      option_c: q.option_c || "",
      option_d: q.option_d || "",
      correct_option: q.correct_option || "A",
      difficulty: q.difficulty || "Beginner",
      quiz_type: q.quiz_type || "topic",
    });
    setActiveTab("questions");
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const startEditResource = (resource) => {
    setEditingResourceId(resource.id);
    setResourceForm({
      topic_id: resource.topic_id || "",
      title: resource.title || "",
      url: resource.url || "",
      type: resource.type || "VIDEO",
      level: resource.level || "Beginner",
    });
    setActiveTab("resources");
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const filteredTopics = topics.filter((topic) => {
    const text = `${topic.title || ""} ${topic.field || topic.field_name || ""} ${topic.level || ""}`.toLowerCase();
    return text.includes(topicSearch.toLowerCase());
  });

  const filteredQuestions = questions.filter((q) => {
    const topicName =
      topics.find((topic) => Number(topic.id) === Number(q.topic_id))?.title ||
      q.topic_title ||
      "";

    const text = `${q.question || ""} ${q.difficulty || ""} ${q.quiz_type || ""} ${topicName}`.toLowerCase();
    return text.includes(questionSearch.toLowerCase());
  });

  const filteredResources = resources.filter((r) => {
    const topicName =
      topics.find((topic) => Number(topic.id) === Number(r.topic_id))?.title ||
      r.topic_title ||
      "";

    const text = `${r.title || ""} ${r.type || ""} ${r.level || ""} ${topicName}`.toLowerCase();
    return text.includes(resourceSearch.toLowerCase());
  });

  const filteredLearners = learners.filter((learner) => {
    const text = `${learner.name || ""} ${learner.email || ""} ${learner.field || ""} ${learner.level || ""}`.toLowerCase();
    return text.includes(learnerSearch.toLowerCase());
  });

  const topicTitleById = (topicId) => {
    const topic = topics.find((item) => Number(item.id) === Number(topicId));
    return topic ? topic.title : `Topic #${topicId}`;
  };

  const renderOverview = () => (
    <div className="admin-section">
      <div className="admin-cards-grid">
        <div className="admin-stat-card">
          <span className="stat-label">Users</span>
          <h3>{stats.usersCount}</h3>
        </div>
        <div className="admin-stat-card">
          <span className="stat-label">Topics</span>
          <h3>{stats.topicsCount}</h3>
        </div>
        <div className="admin-stat-card">
          <span className="stat-label">Questions</span>
          <h3>{stats.questionsCount}</h3>
        </div>
        <div className="admin-stat-card">
          <span className="stat-label">Resources</span>
          <h3>{stats.resourcesCount}</h3>
        </div>
        <div className="admin-stat-card">
          <span className="stat-label">Completed Quizzes</span>
          <h3>{stats.completedQuizzesCount}</h3>
        </div>
      </div>

      <div className="admin-grid-two">
        <div className="admin-panel-card">
          <h3>Quick Summary</h3>
          <p>
            This admin panel helps you manage the Cognito platform from one page:
            topics, quiz questions, resources, learners, and analytics.
          </p>

          <div className="overview-list">
            <div><strong>Topics:</strong> organize roadmap modules by field and level.</div>
            <div><strong>Questions:</strong> manage quiz questions stored in the database.</div>
            <div><strong>Resources:</strong> attach videos, PDFs, and article links to topics.</div>
            <div><strong>Learners:</strong> monitor users, fields, and current levels.</div>
            <div><strong>Analytics:</strong> review usage and learning performance.</div>
          </div>
        </div>

        <div className="admin-panel-card">
          <h3>Current Admin</h3>
          <p><strong>Name:</strong> {user?.name || "Admin User"}</p>
          <p><strong>Email:</strong> {user?.email || "N/A"}</p>
          <p><strong>Role:</strong> {user?.role || "admin"}</p>
          <p><strong>Status:</strong> Active</p>

          <div className="admin-quick-actions">
            <button className="secondary-btn" onClick={() => setActiveTab("topics")}>
              Manage Topics
            </button>
            <button className="secondary-btn" onClick={() => setActiveTab("questions")}>
              Manage Questions
            </button>
            <button className="secondary-btn" onClick={() => setActiveTab("resources")}>
              Manage Resources
            </button>
          </div>
        </div>
      </div>
    </div>
  );

  const renderTopics = () => (
    <div className="admin-section">
      <div className="admin-grid-two admin-align-start">
        <form className="admin-form-card" onSubmit={handleTopicSubmit}>
          <h3>{editingTopicId ? "Edit Topic" : "Add Topic"}</h3>

          <label>Topic Title</label>
          <input
            type="text"
            value={topicForm.title}
            onChange={(e) => setTopicForm({ ...topicForm, title: e.target.value })}
            required
          />

          <label>Description</label>
          <textarea
            rows="4"
            value={topicForm.description}
            onChange={(e) => setTopicForm({ ...topicForm, description: e.target.value })}
          />

          <label>Field</label>
          <input
            type="text"
            value={topicForm.field}
            onChange={(e) => setTopicForm({ ...topicForm, field: e.target.value })}
            required
          />

          <label>Level</label>
          <select
            value={topicForm.level}
            onChange={(e) => setTopicForm({ ...topicForm, level: e.target.value })}
          >
            <option>Beginner</option>
            <option>Intermediate</option>
            <option>Advanced</option>
          </select>

          <label>Order</label>
          <input
            type="number"
            min="1"
            value={topicForm.order_number}
            onChange={(e) => setTopicForm({ ...topicForm, order_number: e.target.value })}
            required
          />

          <div className="admin-form-actions">
            <button type="submit" className="primary-btn">
              {editingTopicId ? "Update Topic" : "Add Topic"}
            </button>

            {editingTopicId && (
              <button type="button" className="secondary-btn" onClick={resetTopicForm}>
                Cancel
              </button>
            )}
          </div>
        </form>

        <div className="admin-table-card">
          <div className="admin-table-topbar">
            <h3>All Topics</h3>
            <input
              type="text"
              placeholder="Search topics..."
              value={topicSearch}
              onChange={(e) => setTopicSearch(e.target.value)}
            />
          </div>

          <div className="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Title</th>
                  <th>Field</th>
                  <th>Level</th>
                  <th>Order</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredTopics.length > 0 ? (
                  filteredTopics.map((topic) => (
                    <tr key={topic.id}>
                      <td>{topic.id}</td>
                      <td>{topic.title}</td>
                      <td>{topic.field || topic.field_name}</td>
                      <td>{topic.level}</td>
                      <td>{topic.order_number || topic.topic_order}</td>
                      <td>
                        <div className="table-actions">
                          <button type="button" className="edit-btn" onClick={() => startEditTopic(topic)}>
                            Edit
                          </button>
                          <button type="button" className="delete-btn" onClick={() => deleteItem("topics", topic.id)}>
                            Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="6" className="empty-cell">No topics found</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );

  const renderQuestions = () => (
    <div className="admin-section">
      <div className="admin-grid-two admin-align-start">
        <form className="admin-form-card" onSubmit={handleQuestionSubmit}>
          <h3>{editingQuestionId ? "Edit Question" : "Add Question"}</h3>

          <label>Topic</label>
          <select
            value={questionForm.topic_id}
            onChange={(e) => setQuestionForm({ ...questionForm, topic_id: e.target.value })}
            required
          >
            <option value="">Select topic</option>
            {topics.map((topic) => (
              <option key={topic.id} value={topic.id}>
                {topic.title} - {topic.level}
              </option>
            ))}
          </select>

          <label>Question</label>
          <textarea
            rows="4"
            value={questionForm.question}
            onChange={(e) => setQuestionForm({ ...questionForm, question: e.target.value })}
            required
          />

          <label>Option A</label>
          <input
            type="text"
            value={questionForm.option_a}
            onChange={(e) => setQuestionForm({ ...questionForm, option_a: e.target.value })}
            required
          />

          <label>Option B</label>
          <input
            type="text"
            value={questionForm.option_b}
            onChange={(e) => setQuestionForm({ ...questionForm, option_b: e.target.value })}
            required
          />

          <label>Option C</label>
          <input
            type="text"
            value={questionForm.option_c}
            onChange={(e) => setQuestionForm({ ...questionForm, option_c: e.target.value })}
            required
          />

          <label>Option D</label>
          <input
            type="text"
            value={questionForm.option_d}
            onChange={(e) => setQuestionForm({ ...questionForm, option_d: e.target.value })}
            required
          />

          <label>Correct Option</label>
          <select
            value={questionForm.correct_option}
            onChange={(e) => setQuestionForm({ ...questionForm, correct_option: e.target.value })}
          >
            <option value="A">A</option>
            <option value="B">B</option>
            <option value="C">C</option>
            <option value="D">D</option>
          </select>

          <label>Difficulty</label>
          <select
            value={questionForm.difficulty}
            onChange={(e) => setQuestionForm({ ...questionForm, difficulty: e.target.value })}
          >
            <option>Beginner</option>
            <option>Intermediate</option>
            <option>Advanced</option>
          </select>

          <label>Quiz Type</label>
          <select
            value={questionForm.quiz_type}
            onChange={(e) => setQuestionForm({ ...questionForm, quiz_type: e.target.value })}
          >
            <option value="topic">topic</option>
            <option value="placement">placement</option>
          </select>

          <div className="admin-form-actions">
            <button type="submit" className="primary-btn">
              {editingQuestionId ? "Update Question" : "Add Question"}
            </button>

            {editingQuestionId && (
              <button type="button" className="secondary-btn" onClick={resetQuestionForm}>
                Cancel
              </button>
            )}
          </div>
        </form>

        <div className="admin-table-card">
          <div className="admin-table-topbar">
            <h3>All Questions</h3>
            <input
              type="text"
              placeholder="Search questions..."
              value={questionSearch}
              onChange={(e) => setQuestionSearch(e.target.value)}
            />
          </div>

          <div className="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Topic</th>
                  <th>Question</th>
                  <th>Difficulty</th>
                  <th>Correct</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredQuestions.length > 0 ? (
                  filteredQuestions.map((q) => (
                    <tr key={q.id}>
                      <td>{q.id}</td>
                      <td>{q.topic_title || topicTitleById(q.topic_id)}</td>
                      <td className="question-cell">{q.question}</td>
                      <td>{q.difficulty}</td>
                      <td>{q.correct_option}</td>
                      <td>
                        <div className="table-actions">
                          <button type="button" className="edit-btn" onClick={() => startEditQuestion(q)}>
                            Edit
                          </button>
                          <button type="button" className="delete-btn" onClick={() => deleteItem("questions", q.id)}>
                            Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="6" className="empty-cell">No questions found</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );

  const renderResources = () => (
    <div className="admin-section">
      <div className="admin-grid-two admin-align-start">
        <form className="admin-form-card" onSubmit={handleResourceSubmit}>
          <h3>{editingResourceId ? "Edit Resource" : "Add Resource"}</h3>

          <label>Topic</label>
          <select
            value={resourceForm.topic_id}
            onChange={(e) => setResourceForm({ ...resourceForm, topic_id: e.target.value })}
            required
          >
            <option value="">Select topic</option>
            {topics.map((topic) => (
              <option key={topic.id} value={topic.id}>
                {topic.title} - {topic.level}
              </option>
            ))}
          </select>

          <label>Title</label>
          <input
            type="text"
            value={resourceForm.title}
            onChange={(e) => setResourceForm({ ...resourceForm, title: e.target.value })}
            required
          />

          <label>URL</label>
          <input
            type="url"
            value={resourceForm.url}
            onChange={(e) => setResourceForm({ ...resourceForm, url: e.target.value })}
            required
          />

          <label>Type</label>
          <select
            value={resourceForm.type}
            onChange={(e) => setResourceForm({ ...resourceForm, type: e.target.value })}
          >
            <option value="VIDEO">VIDEO</option>
            <option value="PDF">PDF</option>
            <option value="ARTICLE">ARTICLE</option>
          </select>

          <label>Level</label>
          <select
            value={resourceForm.level}
            onChange={(e) => setResourceForm({ ...resourceForm, level: e.target.value })}
          >
            <option>Beginner</option>
            <option>Intermediate</option>
            <option>Advanced</option>
          </select>

          <div className="admin-form-actions">
            <button type="submit" className="primary-btn">
              {editingResourceId ? "Update Resource" : "Add Resource"}
            </button>

            {editingResourceId && (
              <button type="button" className="secondary-btn" onClick={resetResourceForm}>
                Cancel
              </button>
            )}
          </div>
        </form>

        <div className="admin-table-card">
          <div className="admin-table-topbar">
            <h3>All Resources</h3>
            <input
              type="text"
              placeholder="Search resources..."
              value={resourceSearch}
              onChange={(e) => setResourceSearch(e.target.value)}
            />
          </div>

          <div className="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Topic</th>
                  <th>Title</th>
                  <th>Type</th>
                  <th>Level</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredResources.length > 0 ? (
                  filteredResources.map((resource) => (
                    <tr key={resource.id}>
                      <td>{resource.id}</td>
                      <td>{resource.topic_title || topicTitleById(resource.topic_id)}</td>
                      <td>{resource.title}</td>
                      <td>{resource.type}</td>
                      <td>{resource.level}</td>
                      <td>
                        <div className="table-actions">
                          <button type="button" className="edit-btn" onClick={() => startEditResource(resource)}>
                            Edit
                          </button>
                          <button type="button" className="delete-btn" onClick={() => deleteItem("resources", resource.id)}>
                            Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="6" className="empty-cell">No resources found</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );

  const renderLearners = () => (
    <div className="admin-section">
      <div className="admin-table-card full-width">
        <div className="admin-table-topbar">
          <h3>All Learners</h3>
          <input
            type="text"
            placeholder="Search learners..."
            value={learnerSearch}
            onChange={(e) => setLearnerSearch(e.target.value)}
          />
        </div>

        <div className="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Field</th>
                <th>Level</th>
                <th>Placement Score</th>
              </tr>
            </thead>
            <tbody>
              {filteredLearners.length > 0 ? (
                filteredLearners.map((learner) => (
                  <tr key={learner.id}>
                    <td>{learner.id}</td>
                    <td>{learner.name}</td>
                    <td>{learner.email}</td>
                    <td>{learner.field || "-"}</td>
                    <td>{learner.level || "-"}</td>
                    <td>{learner.placement_score ?? "-"}</td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="6" className="empty-cell">No learners found</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );

  const renderAnalytics = () => (
    <div className="admin-section">
      <div className="admin-grid-two">
        <div className="admin-panel-card">
          <h3>Users by Level</h3>
          {analytics.usersByLevel?.length > 0 ? (
            <div className="overview-list">
              {analytics.usersByLevel.map((item, index) => (
                <div key={index}>
                  <strong>{item.level || item.label || "Unknown"}:</strong>{" "}
                  {item.count || item.total}
                </div>
              ))}
            </div>
          ) : (
            <p>No analytics available yet.</p>
          )}
        </div>

        <div className="admin-panel-card">
          <h3>Top Fields</h3>
          {analytics.topFields?.length > 0 ? (
            <div className="overview-list">
              {analytics.topFields.map((item, index) => (
                <div key={index}>
                  <strong>{item.field || item.label || "Unknown"}:</strong>{" "}
                  {item.count || item.total}
                </div>
              ))}
            </div>
          ) : (
            <p>No field analytics available yet.</p>
          )}
        </div>

        <div className="admin-panel-card">
          <h3>Average Quiz Score</h3>
          <div className="big-analytics-value">
            {Number(analytics.avgQuizScore || 0).toFixed(2)}%
          </div>
        </div>

        <div className="admin-panel-card">
          <h3>Project Insight</h3>
          <p>
            This section gives the admin a quick overview of learner progress,
            field popularity, and quiz performance across the platform.
          </p>
        </div>
      </div>
    </div>
  );

 return (
  <div className="admin-page">
    <div className="admin-overlay"></div>

    <aside className="admin-sidebar">
      <div className="admin-brand">
        <div className="admin-brand-icon">C</div>
        <div>
          <h2>COGNITO</h2>
          <span>Admin Dashboard</span>
        </div>
      </div>

      <div className="admin-tabs">
        {tabs.map((tab) => (
          <button
            key={tab.key}
            className={`admin-tab ${activeTab === tab.key ? "active" : ""}`}
            onClick={() => setActiveTab(tab.key)}
          >
            {tab.key === "overview" && "▦"}
            {tab.key === "topics" && "📚"}
            {tab.key === "questions" && "❓"}
            {tab.key === "resources" && "🔗"}
            {tab.key === "learners" && "👥"}
            {tab.key === "analytics" && "📊"}
            <span>{tab.label}</span>
          </button>
        ))}
      </div>

      <button className="admin-back-btn" onClick={() => navigate("/home")}>
        Back to Website
      </button>
    </aside>

    <main className="admin-main">
      <div className="admin-header">
        <div>
          <div className="admin-badge">System Administration</div>
          <h1>Admin Control Panel</h1>
          <p>
            Manage Cognito learners, topics, quiz questions, resources, and
            analytics from one place.
          </p>
        </div>

        <button className="refresh-btn" onClick={loadAllData}>
          Refresh Data
        </button>
      </div>

      {pageMessage && (
        <div className={`page-message ${pageMessageType === "error" ? "error" : ""}`}>
          {pageMessage}
        </div>
      )}

      {loading ? (
        <div className="admin-loading">Loading admin data...</div>
      ) : (
        <>
          {activeTab === "overview" && renderOverview()}
          {activeTab === "topics" && renderTopics()}
          {activeTab === "questions" && renderQuestions()}
          {activeTab === "resources" && renderResources()}
          {activeTab === "learners" && renderLearners()}
          {activeTab === "analytics" && renderAnalytics()}
        </>
      )}
    </main>
  </div>
);
}

export default AdminPanel;