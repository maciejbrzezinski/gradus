# Gradus
> *Consistent steps toward mastery*

Gradus is a note-taking + task app that helps you trade short bursts of motivation for **steady, day-by-day progress**.  
It combines a powerful rich-text editor, lightweight task management and an **endless calendar scroll** into a single, offline-first Flutter application.

---

## Key Strengths

| 💪 Feature | 🚀 Gradus | ⚠️ Pain it solves |
|-----------|-----------|-------------------|
| **Endless timeline** | Scroll vertically through days & weeks; drop notes or todos anywhere in the flow | No more clicking into separate "pages" or databases—your past & future stay in one stream |
| **Rich inline formatting** | Bold, italic, highlight, inline code, callouts, nested lists, slash-commands | Superlist's plain-text style can't capture nuance or structure |
| **Inline images** | Paste or drag​&​drop ↔ see a live preview, pinch/drag to resize | Superlist forces a file download and won't let you shrink images in the editor |
| **Tasks are first-class** | Type `[]` or hit `⏎` to turn any line into a checklist, add due-dates & reminders | Notion hides tasks behind databases; setup is clunky for quick todos |
| **Offline-first** | Works underground, merges changes later without conflicts | Notion/Superlist need a live connection for most edits |
| **Plugin architecture** | Blocks for diagrams, code blocks with syntax, Mermaid, LaTeX (roadmap) | Extensibility without bloated workspaces |

---

## Architecture Overview

Gradus implements **Clean Architecture** principles with **BLoC pattern** for state management. This architectural approach provides several key benefits including separation of concerns, dependency management, testability, flexibility, and scalability.

The application is divided into three main layers:
1. **Presentation Layer** - UI components and state management (BLoCs/Cubits)
2. **Domain Layer** - Business logic, entities, and repository interfaces
3. **Data Layer** - Repository implementations, data sources, and models

For detailed information about the architecture, please refer to the documentation in the `docs` directory:

- [Architecture Summary](docs/architecture_summary.md) - Comprehensive overview of the architecture
- [Architecture Diagrams](docs/architecture_diagrams.md) - Visual representations of the architecture
- [Clean Architecture Implementation](docs/clean_architecture_implementation.md) - Detailed implementation examples
- [Application Mechanism](docs/application_mechanism.md) - Core application mechanisms
- [Implementation Plan](docs/implementation_plan.md) - Project structure and implementation details
