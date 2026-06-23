// Theme toggle — persist light/dark choice to localStorage.
// The initial <html data-theme> is set by an inline head script (anti-FOUC);
// this module only syncs the button state and handles clicks.

type Theme = "light" | "dark";

const root = document.documentElement;
const KEY = "theme";

function current(): Theme {
  return root.getAttribute("data-theme") === "dark" ? "dark" : "light";
}

function apply(theme: Theme): void {
  root.setAttribute("data-theme", theme);
  try {
    localStorage.setItem(KEY, theme);
  } catch {
    // localStorage may be unavailable (private mode) — state still applies in-session.
  }
  const btn = document.getElementById("theme-toggle");
  if (btn) {
    btn.setAttribute("aria-pressed", String(theme === "dark"));
    btn.setAttribute(
      "aria-label",
      theme === "dark" ? "切换到浅色主题" : "切换到深色主题",
    );
  }
}

// Sync the button to whatever the inline head script already chose.
apply(current());

document.getElementById("theme-toggle")?.addEventListener("click", () => {
  apply(current() === "dark" ? "light" : "dark");
});
