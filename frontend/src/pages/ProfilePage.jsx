import { useEffect, useMemo, useState } from "react";
import Navbar from "../components/Navbar";
import "./ProfilePage.css";

function ProfilePage() {
  const [userData, setUserData] = useState(null);

  const user = useMemo(
    () =>
      JSON.parse(localStorage.getItem("user")) ||
      JSON.parse(sessionStorage.getItem("user")),
    []
  );

  useEffect(() => {
    const loadUser = async () => {
      if (!user?.id) return;

      try {
        const res = await fetch(`http://localhost:5001/user/${user.id}`);
        const data = await res.json();

        if (!res.ok) {
          throw new Error(data.message || "Failed to load user data");
        }

        setUserData(data);
      } catch (error) {
        console.error("PROFILE PAGE ERROR:", error);
      }
    };

    loadUser();
  }, [user]);

  if (!userData) {
    return (
      <>
        <Navbar />
        <div className="profile-page">
          <div className="profile-loading">Loading profile...</div>
        </div>
      </>
    );
  }

  const avatarLetter =
    userData.name?.charAt(0).toUpperCase() ||
    userData.email?.charAt(0).toUpperCase() ||
    "U";

  const profileCompletion =
    userData.name &&
    userData.email &&
    userData.phone &&
    userData.university_major
      ? 100
      : 75;

  return (
    <>
      <Navbar />

      <main className="profile-page">
        <div className="profile-page-bg">
          <div className="profile-grid-overlay"></div>
          <div className="profile-glow glow-1"></div>
          <div className="profile-glow glow-2"></div>
        </div>

        <section className="profile-header-card">
          <div className="profile-avatar-large">{avatarLetter}</div>

          <div className="profile-header-info">
            <div className="profile-badge">Personal Profile</div>
            <h1>{userData.name || "User Profile"}</h1>
            <p>
              View your personal details, current level, selected path, and your
              overall progress inside Cognito.
            </p>
          </div>
        </section>

        <section className="profile-summary-grid">
          <div className="profile-stat-card">
            <h3>Current Level</h3>
            <p>{userData.level || "Not determined yet"}</p>
          </div>

          <div className="profile-stat-card">
            <h3>Main Field</h3>
            <p>{userData.field || "Not selected yet"}</p>
          </div>

          <div className="profile-stat-card">
            <h3>Placement Score</h3>
            <p>
              {userData.placement_score !== null &&
              userData.placement_score !== undefined
                ? `${userData.placement_score}%`
                : "Not available"}
            </p>
          </div>

          <div className="profile-stat-card">
            <h3>Profile Completion</h3>
            <p>{profileCompletion}%</p>
          </div>
        </section>

        <section className="profile-details-card">
          <div className="section-title-row">
            <h2>Personal Information</h2>
          </div>

          <div className="profile-details-grid">
            <div className="profile-detail-item">
              <span className="detail-label">Full Name</span>
              <span className="detail-value">{userData.name || "-"}</span>
            </div>

            <div className="profile-detail-item">
              <span className="detail-label">Email</span>
              <span className="detail-value">{userData.email || "-"}</span>
            </div>

            <div className="profile-detail-item">
              <span className="detail-label">Phone</span>
              <span className="detail-value">{userData.phone || "-"}</span>
            </div>

            <div className="profile-detail-item">
              <span className="detail-label">Major</span>
              <span className="detail-value">
                {userData.university_major || userData.universityMajor || "-"}
              </span>
            </div>

            <div className="profile-detail-item">
              <span className="detail-label">Selected Field</span>
              <span className="detail-value">
                {userData.field || "Not selected yet"}
              </span>
            </div>

            <div className="profile-detail-item">
              <span className="detail-label">Detected Level</span>
              <span className="detail-value">
                {userData.level || "Not determined yet"}
              </span>
            </div>
          </div>
        </section>
      </main>
    </>
  );
}

export default ProfilePage;