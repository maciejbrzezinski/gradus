## General
- Keep code idiomatic and concise.
- Only add comments that explain *why*, not *what*. Limit their number as much as possible, add only key ones

## UI & Widgets
- Extract reusable UI into dedicated widget **classes/files**; avoid large inline builder methods.
- Keep any single `build()` method under ~100 lines.
- Prefer `const` widgets when inputs are immutable.

## Code Style
- Follow Dart/Flutter naming: **PascalCase** for types, **lowerCamelCase** for members.
- Declare variables/fields `final` unless they must change.

## Project Boundaries
- Preserve existing architecture unless instructed otherwise.
- Do **not** modify generated artifacts or build outputs.