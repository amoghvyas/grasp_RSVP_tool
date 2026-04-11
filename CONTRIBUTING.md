# Contributing to Grasp Scholarly

Thank you for your interest in contributing to **Grasp Scholarly**. We are building a high-precision ecosystem for academic absorption, and your expertise—whether in code, design, or research—is invaluable.

---

## 🏛️ Our Mission
To transform digital reading into a deep focus experience by combining scientifically-backed speed reading techniques with ultra-fast AI intelligence.

## ⚖️ Code Standards

### 1. Minimalist & Monochromatic
We follow an Apple-inspired design philosophy. Avoid generic colors; use curated HSL palettes or macOS-grade tokens (e.g., `#0071E3` for emphasis, `#FF3B30` for scholarly guides).

### 2. State Management
Grasp uses **Provider + ChangeNotifier** for performance and simplicity.
- Use the `copyWith` pattern for `ReaderState`.
- Keep business logic in `Services` or `Providers`; keep `Widgets` focused on rendering.

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
