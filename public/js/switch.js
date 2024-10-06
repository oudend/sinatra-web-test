function setTheme(mode = null) {
  const userMode = localStorage.getItem("bs-theme");
  const sysMode = window.matchMedia("(prefers-color-scheme: light)").matches
    ? "light"
    : "dark";
  var modeChosen = mode ?? userMode ?? sysMode;

  localStorage.setItem("bs-theme", modeChosen);

  document.documentElement.setAttribute("data-bs-theme", modeChosen);
  document
    .querySelectorAll(".mode-switch .btn")
    .forEach((e) => e.classList.remove("text-body"));

  document.getElementById(modeChosen).classList.add("text-body");
}

setTheme();
document
  .querySelectorAll(".mode-switch .btn")
  .forEach((e) => e.addEventListener("click", () => setTheme(e.id)));
window
  .matchMedia("(prefers-color-scheme: light)")
  .addEventListener("change", () => setTheme());
