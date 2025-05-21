# Gradus
> *Consistent steps toward mastery*

Gradus is a note-taking + task app that helps you trade short bursts of motivation for **steady, day-by-day progress**.  
It combines a powerful rich-text editor, lightweight task management and an **endless calendar scroll** into a single, offline-first Flutter application.

---

## Key Strengths

### Seamless Organization & Flow

| 💪 Feature | 🚀 What Gradus Offers | ⚠️ Pain it Solves |
|-----------|----------------------|-------------------|
| **Endless timeline** | Scroll vertically through days & weeks; drop notes or todos anywhere in the flow | Fragmented productivity where your content is scattered across multiple pages, requiring constant navigation and context switching |
| **Projects** | Create projects to group notes & tasks, with dated tasks automatically appearing on the timeline | The struggle of balancing organization with quick access—either too rigid (folders) or too complex (databases) for everyday use |

### Frictionless Task Management

| 💪 Feature | 🚀 What Gradus Offers | ⚠️ Pain it Solves |
|-----------|----------------------|-------------------|
| **Tasks are first-class** | Type `[]` or hit `⏎` to turn any line into a checklist, add due-dates & reminders | The frustration of complex task setup processes that interrupt your flow and discourage quick task creation |

### Rich Content Creation

| 💪 Feature | 🚀 What Gradus Offers | ⚠️ Pain it Solves |
|-----------|----------------------|-------------------|
| **Rich inline formatting** | Bold, italic, highlight, inline code, callouts, nested lists, slash-commands | The limitations of plain-text that prevent proper emphasis, structure, and visual organization of your thoughts |
| **Inline images** | Paste or drag​&​drop ↔ see a live preview, pinch/drag to resize | The disruption of your workflow when adding visual content requires multiple steps or downloads |

### Reliability & Extensibility

| 💪 Feature | 🚀 What Gradus Offers | ⚠️ Pain it Solves |
|-----------|----------------------|-------------------|
| **Offline-first** | Works underground, merges changes later without conflicts | The anxiety of losing work or being unable to access your notes when connectivity is limited or unavailable |
| **Plugin architecture** | Blocks for diagrams, code blocks with syntax, Mermaid, LaTeX (roadmap) | The compromise between having too many features (bloat) or too few (limitation) for your specific needs |

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
