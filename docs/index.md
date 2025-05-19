# Gradus Documentation

This directory contains detailed documentation for the Gradus application. Each file focuses on a specific aspect of the application's architecture and implementation.

## Documentation Structure

### [Architecture Summary](architecture_summary.md)
A comprehensive overview of the Gradus application architecture, including:
- Application overview
- Clean Architecture approach
- Core data model
- Key interaction mechanisms
- State management with BLoC pattern
- Data flow
- Storage strategy
- Performance considerations
- Accessibility features

### [Architecture Diagrams](architecture_diagrams.md)
Visual representations of the Gradus application architecture using Mermaid diagrams, including:
- Clean Architecture overview
- Block type hierarchy
- Document structure
- State management flow
- Command palette flow
- Todo repetition flow
- Data layer implementation
- Presentation layer implementation
- Widget hierarchy
- Dependency injection
- User interface layout

### [Application Mechanism Design](application_mechanism.md)
Detailed design of the application's core mechanisms, focusing on:
- Data model and block types
- UI components
- Interaction mechanisms (block editing, todo functionality)
- State management approach
- Implementation details (block editing flow, command palette, todo repetition)
- Persistence and synchronization
- Performance considerations
- Accessibility features
- Future extensions

### [Clean Architecture Implementation](clean_architecture_implementation.md)
Detailed implementation of Clean Architecture principles in the Gradus application, including:
- Architecture overview
- Domain layer (entities, repository interfaces, use cases)
- Data layer (models, data sources, repositories)
- Presentation layer (BLoCs/Cubits, UI components)
- Code examples for each component

### [Implementation Plan](implementation_plan.md)
Practical guide for implementing the Gradus application, including:
- Project structure
- Core data models with code examples
- Core widgets with code examples
- Implementation details for key components

### [Format Toolbar](format_toolbar.md)
Documentation for the Format Toolbar widget that enables rich text formatting:
- Implementation details
- Integration with TextBlock
- User experience for applying formatting to selected text

## How to Use This Documentation

1. Start with the [Architecture Summary](architecture_summary.md) to get a high-level understanding of the application's architecture and design principles.
2. Refer to the [Architecture Diagrams](architecture_diagrams.md) for visual representations of the architecture and component relationships.
3. Explore the [Application Mechanism Design](application_mechanism.md) to understand the core mechanisms and interaction patterns.
4. Dive into the [Clean Architecture Implementation](clean_architecture_implementation.md) for detailed implementation examples of Clean Architecture principles.
5. Use the [Implementation Plan](implementation_plan.md) as a practical guide when implementing specific components.

Each document is designed to be read independently, but they complement each other to provide a complete understanding of the Gradus application.
