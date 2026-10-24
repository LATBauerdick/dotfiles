// Finicky (https://github.com/johnste/finicky) — set as the macOS default
// browser so it can route links; Safari stays the effective default.
// Only sees links opened through the system (Mail, Obsidian, Slack, …),
// never clicks inside Safari itself. Live-linked: Finicky reloads on save.
export default {
  defaultBrowser: "Safari",
  handlers: [
    {
      // hold ⌥ Option while clicking a link → Brave
      match: () => finicky.getModifierKeys().option,
      browser: "Brave Browser",
    },
  ],
};
