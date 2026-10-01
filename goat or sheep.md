PROJECT NAME: goat or sheep

META-INSTRUCTIONS:

<Read it all before acting. Ask about anything unclear, contradictory or
 underspecified — before starting and mid-build. Ask in the question widget
 (AskUserQuestion): related questions batched, concrete options, your
 recommendation first. Plain text only if the widget isn't available.>

<Don't expand scope. Anything not listed here is a proposal, including changes
 to this file — propose it, don't do it.>

<Prefer doing over describing: run the code, write the files, test it.>

<Always in scope, no proposal needed: when it goes on GitHub, a short README
 that leads with visuals (screenshots, a diagram or a chart) and a line on what
 it is, linking to docs/GUIDE.md for setup and usage; and a small unobtrusive
 feedback tab if what you're building is an application rather than a script.>

<If what you're building is an application, build it as a Mac app first; the
 website comes after, as its own step.>

<Name things the way a person would say them — "Goal Tracker", not
 goal_tracker — for the app, its windows, titles, files people open, repo
 descriptions and README headings. Where a name can't hold spaces (repo names,
 bundle IDs), use hyphens, never underscores.>

<Finish by listing every deliverable: path, what it is, how to check it works.>

<Git rules (no Claude attribution, never commit .claude/) are in
 ~/.claude/CLAUDE.md and apply on their own — nothing to repeat here.>

<Keep the changelog at the bottom current.>

CONTEXT:

figure out if youre a goat or a sheep

OPEN QUESTIONS / ASSUMPTIONS:

<Agent fills in: what it guessed, what it decided without asking.>

Asked and answered (2026-09-29):
- "Goat or sheep" = a personality quiz: Goat = independent/goes its own way, Sheep = follows the flock.
- Native Mac app only for now; no website yet.
- Feedback tab opens a pre-filled email draft to amal.mehta@gmail.com.
- Local git only at first; pushed to a public GitHub repo on 2026-10-01 at the user's request.
- Website (2026-09-30): local files in web/ plus a private claude.ai Artifact link. On 2026-10-01 it moved to GitHub Pages and the private link was deleted.

Decided without asking:
- SwiftUI + Swift Package Manager (no .xcodeproj); scripts/build-app.sh wraps it into "Goat or Sheep.app", ad-hoc signed, bundle ID com.amalmehta.goat-or-sheep.
- 9 questions × 4 answers (2 goat, 2 sheep); odd count so there's never a tie; majority wins.
- Emoji (🐐 🐑) as in-app artwork; the app icon is custom-drawn (goat and sheep on a hill), not Apple emoji, which aren't licensed for icons; fixed 560×520 window; macOS 14+.
- Website is one plain HTML/CSS/JS page (no framework) with the questions copied from the app; a test keeps the two in sync. Its feedback tab shows the address and a Copy button as well as a mailto link.
- README screenshots come from an offscreen renderer (RenderScreenshots target) rather than live screen capture.

CHANGELOG:

- 2026-09-29 — created
- 2026-09-29 — built v1: Goat or Sheep Mac app (9-question quiz, result screen, feedback tab), tests, README, docs/GUIDE.md
- 2026-09-30 — added a custom Mac app icon (drawn in code by RenderIcon, bundled by scripts/build-app.sh)
- 2026-09-30 — built the website version (web/index.html), published privately as a claude.ai Artifact
- 2026-10-01 — pushed to GitHub: https://github.com/amalmehta/goat-or-sheep (public)
- 2026-10-01 — turned on GitHub Pages for the website via a GitHub Actions workflow publishing web/: https://amalmehta.github.io/goat-or-sheep/
- 2026-10-01 — deleted the private claude.ai copy of the website; GitHub Pages is now the only hosted version
- 2026-10-01 — set the GitHub repo's homepage link to the GitHub Pages site
- 2026-09-15 — added meta-instruction: built-out applications include a small feedback tab
- 2026-09-15 — added meta-instruction: no "Claude" attribution in commits, PRs, or branches
- 2026-09-16 — added meta-instruction: always include a README when adding to GitHub
- 2026-09-16 — changed meta-instruction: ask clarifying questions in the question widget
- 2026-09-17 — added meta-instructions: Claude never a contributor; never commit .claude/
- 2026-09-26 — compressed the meta-instructions and every field prompt; git rules moved to the global instruction file
- 2026-09-27 — added meta-instruction: applications are built as a Mac app first, then a website
- 2026-09-28 — folded inputs, instructions, constraints, deliverables and done criteria into one free-form CONTEXT
- 2026-09-28 — changed meta-instruction: a README on GitHub always includes a visual
- 2026-09-28 — added meta-instruction: name things like a person would, never snake_case
- 2026-09-28 — changed meta-instruction: README leads with visuals; instructions live in a linked guide
