function setTheme(mode = null) {
  const userMode = localStorage.getItem("bs-theme");
  const sysMode = window.matchMedia("(prefers-color-scheme: light)").matches
    ? "light"
    : "dark";
  var modeChosen = mode ?? userMode ?? sysMode;

  localStorage.setItem("bs-theme", modeChosen);

  document.documentElement.setAttribute("data-bs-theme", modeChosen);
  updateIcon(modeChosen);
}

function updateIcon(mode) {
  const themeIcon = document.getElementById("theme-icon");

  if (mode === "light") {
    themeIcon.classList.remove("bi-moon");
    themeIcon.classList.add("bi-sun");
  } else {
    themeIcon.classList.remove("bi-sun");
    themeIcon.classList.add("bi-moon");
  }
}

setTheme();

document.getElementById("theme-toggle").addEventListener("click", () => {
  const currentMode =
    localStorage.getItem("bs-theme") === "light" ? "dark" : "light";
  setTheme(currentMode);
});

window
  .matchMedia("(prefers-color-scheme: light)")
  .addEventListener("change", () => setTheme());
