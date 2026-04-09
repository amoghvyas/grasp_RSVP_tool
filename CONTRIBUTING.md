# Contributing to Grasp

Thank you for your interest in making Grasp better! Every contribution helps students read faster and study smarter.

## How to Contribute

### 1. Fork & Clone

```bash
# Fork the repo on GitHub first, then:
git clone https://github.com/YOUR_USERNAME/grasp_RSVP_tool.git
cd grasp_RSVP_tool
flutter pub get
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

Use a descriptive branch name:
- `feature/keyboard-shortcuts`
- `fix/pdf-parsing-crash`
- `docs/update-readme`

### 3. Make Your Changes

- Follow the existing code style (Dart formatting with `dart format .`)
- Keep commits focused — one feature or fix per PR
- Add comments for non-obvious logic

### 4. Test Locally

```bash
# Run the app (you'll need a Gemini API key for AI features)
flutter run -d chrome --dart-define=GEMINI_API_KEY=your_key

# Run the analyzer
flutter analyze

# Format code
dart format .
```

### 5. Submit a Pull Request

1. Push your branch to your fork
2. Open a PR against the `main` branch
3. Describe what you changed and why
4. Link any related issues

## Code Guidelines

### Architecture

- **Services** (`lib/services/`) — Pure Dart logic, no Flutter imports
- **Models** (`lib/models/`) — Immutable data classes with `copyWith`
- **Providers** (`lib/providers/`) — State management via `ChangeNotifier`
- **Screens** (`lib/screens/`) — Full-page layouts
- **Widgets** (`lib/widgets/`) — Reusable UI components

### Style

- Use `GoogleFonts.inter()` for all text
- Keep the dark theme consistent (base: `#05050A`, accent: `#6C63FF`)
- Use `GlassCard` for container widgets
- New features should support both English and Hinglish if AI-related

### Don'ts

- ❌ Don't add backend dependencies — this app is fully client-side
- ❌ Don't hardcode API keys anywhere in the source
- ❌ Don't add persistent storage (localStorage, cookies, etc.)
- ❌ Don't add analytics or tracking

## Reporting Bugs

Open an issue with:
1. What you expected to happen
2. What actually happened
3. Steps to reproduce
4. Browser and OS version

## Feature Requests

Open an issue tagged `enhancement` and describe:
1. The problem you're solving
2. Your proposed solution
3. Who benefits from this feature

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
