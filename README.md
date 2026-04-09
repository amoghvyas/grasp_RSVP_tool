<div align="center">

# ✦ Grasp

**Read faster. Retain more. Ace every exam.**

An AI-powered RSVP speed reading app built for students — completely free and open source.

[![MIT License](https://img.shields.io/badge/License-MIT-6C63FF?style=for-the-badge)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-Web-00D9FF?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Gemini AI](https://img.shields.io/badge/Gemini-AI_Powered-FF6B9D?style=for-the-badge&logo=google)](https://ai.google.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=for-the-badge)](CONTRIBUTING.md)

</div>

---

## What is Grasp?

Grasp uses **RSVP (Rapid Serial Visual Presentation)** — a scientifically-backed speed reading technique — to help students read textbooks, papers, and study material at up to **1000 words per minute**.

It also includes **AI-powered study tools** that generate exam summaries and viva questions from your uploaded content using Google's Gemini API.

**Zero cost. No sign-up. Runs entirely in your browser.**

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 📖 **RSVP Engine** | Read at 100–1000 WPM with an ORP (Optimal Recognition Point) aligned display |
| 📂 **Multi-format Input** | Paste text or upload `.txt`, `.docx`, `.pdf` files |
| 🤖 **AI Summary** | Generate structured, exam-optimized summaries with key terms highlighted |
| ❓ **Viva Q&A Generator** | Get 15–20 exam-style questions with model answers |
| 🇬🇧🇮🇳 **English / Hinglish** | Toggle between English and Hinglish output for AI tools |
| ⚡ **Punctuation Pacing** | Smart micro-pauses at commas, periods, and sentence boundaries |
| 🎨 **Premium UI** | Glassmorphic design with animated gradient backgrounds |
| 🔒 **Fully Client-Side** | No backend, no data collection — everything runs in your browser |

---

## 🖼️ Screenshots

<div align="center">

| Landing Page | AI Study Tools |
|:---:|:---:|
| ![Landing](https://via.placeholder.com/400x250/05050A/6C63FF?text=Grasp+Landing) | ![AI Tools](https://via.placeholder.com/400x250/05050A/00D9FF?text=AI+Study+Tools) |

| RSVP Reader | Settings |
|:---:|:---:|
| ![Reader](https://via.placeholder.com/400x250/020204/FF6B9D?text=RSVP+Reader) | ![Settings](https://via.placeholder.com/400x250/020204/6C63FF?text=Settings+Overlay) |

</div>

> **Replace these placeholders** with actual screenshots after deployment. Use the screenshots from [the browser recordings](#) or take new ones.

---

## 🚀 Quick Start

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- A [Gemini API key](https://aistudio.google.com/apikey) (free)

### Run Locally

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/grasp_RSVP_tool.git
cd grasp_RSVP_tool

# Install dependencies
flutter pub get

# Run with your Gemini API key
flutter run -d chrome --dart-define=GEMINI_API_KEY=your_api_key_here
```

### Build for Production

```bash
flutter build web --release --dart-define=GEMINI_API_KEY=your_api_key_here
```

The output will be in `build/web/` — deploy it to any static hosting provider.

---

## 🏗️ Architecture

```
lib/
├── main.dart                      # App entry, theme, routing
├── models/
│   └── reader_state.dart          # Immutable state model (copyWith pattern)
├── providers/
│   └── reader_provider.dart       # ChangeNotifier — state + pacing engine
├── services/
│   ├── sanitizer_service.dart     # 4-step RegEx text cleaning pipeline
│   ├── orp_service.dart           # Optimal Recognition Point calculator
│   ├── file_parser_service.dart   # .txt / .docx / .pdf extraction
│   └── gemini_service.dart        # Gemini API client + prompt engineering
├── screens/
│   ├── input_screen.dart          # Dashboard with text input + file upload
│   └── reader_screen.dart         # Full-screen RSVP reading canvas
└── widgets/
    ├── animated_background.dart   # Gradient mesh + glassmorphism components
    ├── word_display.dart          # ORP-aligned word renderer
    ├── dropzone_widget.dart       # HTML5 drag-and-drop file zone
    ├── settings_overlay.dart      # WPM + font size controls
    └── study_tools_panel.dart     # AI summary + viva Q&A tabs
```

### Key Design Decisions

- **No backend** — Everything runs client-side. No data leaves the browser except Gemini API calls.
- **No persistence** — State is ephemeral. Close the tab = full reset. No cookies, no local storage.
- **Provider + copyWith** — Lightweight state management without code generation.
- **Gemini API key via `--dart-define`** — Injected at build time, never hardcoded in source.

---

## 🔑 API Key Setup

Grasp uses the [Gemini API](https://ai.google.dev/) for AI-powered study tools. The API key is injected at build time — it is **never committed to the repository**.

### For Local Development

```bash
flutter run -d chrome --dart-define=GEMINI_API_KEY=your_key
```

### For GitHub Pages Deployment

1. Go to your repo **Settings → Secrets and variables → Actions**
2. Click **New repository secret**
3. Name: `GEMINI_API_KEY`, Value: your API key
4. Push to `main` — the included GitHub Actions workflow handles the rest

> **Note:** The free Gemini API tier (Gemini 2.0 Flash) includes 250K tokens/minute and ~1000 requests/day — more than enough for personal and student use.

---

## 🌐 Deployment

### GitHub Pages (Recommended)

This repo includes a pre-configured GitHub Actions workflow (`.github/workflows/deploy.yml`) that automatically builds and deploys on every push to `main`.

1. Push your code to GitHub
2. Add your `GEMINI_API_KEY` as a repository secret
3. Go to **Settings → Pages → Source → GitHub Actions**
4. Done! Your site deploys automatically.

### Custom Domain (Free for Students)

1. Claim a free `.me` domain from [Namecheap via GitHub Student Pack](https://education.github.com/pack)
2. Configure DNS (A records + CNAME) — see [deployment guide](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)
3. Enter your domain in **Settings → Pages → Custom domain**

---

## 🧪 Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter Web (Dart) |
| **State** | Provider + ChangeNotifier |
| **AI** | Google Gemini API (`google_generative_ai`) |
| **PDF Parsing** | Syncfusion Flutter PDF (Community License) |
| **DOCX Parsing** | `docx_to_text` |
| **File Input** | `file_picker` + `flutter_dropzone` |
| **Typography** | Google Fonts (Inter) |
| **Deployment** | GitHub Pages + GitHub Actions |

---

## 🤝 Contributing

Contributions are welcome! Whether it's a bug fix, new feature, or documentation improvement — every contribution helps students learn better.

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Ideas for Contributions

- [ ] Dark/light theme toggle
- [ ] Reading session history and statistics
- [ ] Keyboard shortcuts (spacebar to pause, arrow keys to navigate)
- [ ] Epub file format support
- [ ] Text-to-speech integration
- [ ] Mobile-responsive layout improvements
- [ ] Accessibility improvements (screen reader support, high contrast mode)
- [ ] Localization for more languages

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev) — Beautiful, natively compiled apps from a single codebase
- [Google Gemini](https://ai.google.dev/) — Free AI API powering the study tools
- [Syncfusion](https://www.syncfusion.com/products/communitylicense) — Free community license for PDF parsing
- RSVP research by Spritz, Rayner, and others — for the science behind speed reading

---

<div align="center">

**Built with ❤️ for students, by students.**

⭐ Star this repo if Grasp helped you study faster!

</div>
