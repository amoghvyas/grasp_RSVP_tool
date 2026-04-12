# Contributing to Grasp Scholarly

Thank you for your interest in contributing to **Grasp Scholarly**. We are maintaining a framework for analytical information absorption, and your technical expertise is valued.

---

## 🏛️ Our Objective
To enhance the pre-analytical phase of research by providing a high-speed RSVP engine combined with deterministic AI synthesis tools.

## ⚖️ Technical Standards

### 1. Functional Minimalism
We adhere to a minimalist design philosophy centered on focus. Use curated HSL palettes or formal monochromatic tokens (e.g., `#0071E3` for emphasis) to minimize visual fatigue.

### 2. State Management
### 3. AI Safety & Privacy
- **Client-Side Only**: Never implement features that require a centralized database or track user identity.
- **LPU Optimized**: Ensure all new AI features are compatible with Groq API structures.
- **Hallucination Safeguards**: When generating study tools, use precise prompts to minimize noise.

---

## 🚀 How to Contribute

### 1. Identify an Issue
Check our GitHub issues for research needs or feature requests. If proposing a new feature, open a "Request for Scholarship" issue first.

### 2. Fork and Branch
```bash
git checkout -b feat/your-scholarly-feature
```

### 3. Rigorous Testing
Run the scholarly analysis tool before pushing:
```bash
dart analyze
flutter test
```

### 4. Pull Request Requirements
- **Descriptive Title**: e.g., `feat: integrate multi-page OCR support`.
- **Demos**: Include screenshots or videos of UI changes.
- **Clean Commits**: Follow [Conventional Commits](https://www.conventionalcommits.org/).

---

## 🧪 Development Workflow

### API Key Management
Never commit `GROQ_API_KEY` to the repository. Use `--dart-define` for local development.

### UI Guidelines
Any new screen must maintain:
- **Glassmorphic** depth (`BackdropFilter`).
- **Outfit** or high-precision typography.
- **Apple-grade animations** (physics-based).

---

## 🙏 Recognition
All contributors will be recognized in the repository as "Scholar Contributors."

**Built with pride for students, by the community.**
