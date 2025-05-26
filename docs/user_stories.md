# Historyjki użytkownika - Gradus

Ten dokument zawiera listę historyjek użytkownika dla aplikacji Gradus, ułożonych w kolejności implementacji zgodnej z architekturą Clean Architecture i offline-first podejściem.

## 1. Podstawowa infrastruktura Clean Architecture

### [US-001]

[ ] Status

Nazwa: Konfiguracja projektu Flutter z Clean Architecture

Krótki opis: Skonfigurowanie projektu Flutter z odpowiednią strukturą katalogów zgodnie z Clean Architecture (presentation/domain/data layers) i wzorcem BLoC. Konfiguracja dependency injection z GetIt.

**Szczegółowa struktura katalogów:**

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # Główna aplikacja
│   ├── router/                     # Routing i nawigacja
│   └── theme/                      # Konfiguracja motywów
├── core/
│   ├── constants/                  # Stałe aplikacji
│   ├── errors/                     # Definicje błędów
│   ├── utils/                      # Narzędzia pomocnicze
│   ├── extensions/                 # Rozszerzenia
│   └── di/                         # Dependency Injection (GetIt)
├── features/
│   ├── authentication/             # Moduł autentykacji
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_user.dart
│   │   │       ├── logout_user.dart
│   │   │       └── register_user.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── auth_cubit.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   ├── register_page.dart
│   │       │   └── profile_page.dart
│   │       └── widgets/
│   │           └── auth_form.dart
│   ├── documents/                  # Moduł dokumentów
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── document_local_datasource.dart
│   │   │   │   └── document_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── document_model.dart
│   │   │   │   ├── timeline_document_model.dart
│   │   │   │   └── project_document_model.dart
│   │   │   └── repositories/
│   │   │       └── document_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── document.dart
│   │   │   │   ├── timeline_document.dart
│   │   │   │   └── project_document.dart
│   │   │   ├── repositories/
│   │   │   │   └── document_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_document.dart
│   │   │       ├── update_document.dart
│   │   │       ├── delete_document.dart
│   │   │       └── get_document.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── document_cubit.dart
│   │       ├── pages/
│   │       │   ├── timeline_page.dart
│   │       │   └── project_page.dart
│   │       └── widgets/
│   │           ├── document_tile.dart
│   │           └── day_tile.dart
│   ├── blocks/                     # Moduł bloków
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── block_local_datasource.dart
│   │   │   │   └── block_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── block_model.dart
│   │   │   │   ├── text_block_model.dart
│   │   │   │   ├── todo_block_model.dart
│   │   │   │   └── ...
│   │   │   └── repositories/
│   │   │       └── block_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── block.dart
│   │   │   │   ├── text_block.dart
│   │   │   │   ├── todo_block.dart
│   │   │   │   └── ...
│   │   │   ├── repositories/
│   │   │   │   └── block_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_block.dart
│   │   │       ├── update_block.dart
│   │   │       └── delete_block.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── block_cubit.dart
│   │       │   └── command_palette_cubit.dart
│   │       ├── widgets/
│   │       │   ├── blocks/
│   │       │   │   ├── text_block_widget.dart
│   │       │   │   ├── todo_block_widget.dart
│   │       │   │   ├── heading_block_widget.dart
│   │       │   │   └── ...
│   │       │   ├── editors/
│   │       │   │   ├── custom_text_editor.dart
│   │       │   │   └── formatting_toolbar.dart
│   │       │   └── command_palette.dart
│   │       └── rendering/
│   │           ├── custom_render_object.dart
│   │           ├── text_renderer.dart
│   │           └── cursor_manager.dart
│   └── synchronization/            # Moduł synchronizacji
│       ├── data/
│       │   ├── datasources/
│       │   │   └── sync_remote_datasource.dart
│       │   └── repositories/
│       │       └── sync_repository_impl.dart
│       ├── domain/
│       │   ├── repositories/
│       │   │   └── sync_repository.dart
│       │   └── usecases/
│       │       ├── sync_documents.dart
│       │       └── sync_blocks.dart
│       └── presentation/
│           └── bloc/
│               └── sync_cubit.dart
├── shared/
│   ├── models/                     # Modele współdzielone
│   │   ├── text_formatting.dart
│   │   └── block_types/
│   │       └── formatted_span.dart
│   ├── widgets/                    # Widgety współdzielone
│   │   ├── loading_indicator.dart
│   │   └── error_widget.dart
│   ├── services/                   # Serwisy współdzielone
│   │   ├── realtime_sync_service.dart
│   │   ├── storage_service.dart
│   │   └── cache_service.dart
│   └── utils/                      # Narzędzia współdzielone
│       ├── date_utils.dart
│       └── text_utils.dart
└── generated/                      # Automatycznie generowane pliki
    ├── assets.gen.dart
    └── l10n/
```

---

### [US-002]

[ ] Status

Nazwa: Abstrakcyjny model Document

Krótki opis: Implementacja abstrakcyjnej klasy Document z właściwościami: id, date (nullable dla projektów), title, icon, iconColor i listą bloków. Przygotowanie na specjalizacje TimelineDocument i ProjectDocument.

---

### [US-003]

[ ] Status

Nazwa: Abstrakcyjny model Block

Krótki opis: Implementacja abstrakcyjnego modelu Block z właściwościami: id, type, content, metadata (Map<String, dynamic>), children, projectId (nullable) i date (nullable). Każdy blok należy do projektu albo do dnia, albo ma ustawione to i to jednocześnie.

---

### [US-004]

[ ] Status

Nazwa: Repository interfaces (Domain Layer)

Krótki opis: Implementacja interfaces dla DocumentRepository i BlockRepository w domain layer, definiujących kontrakty dla operacji CRUD i synchronizacji.

---

### [US-005]

[ ] Status

Nazwa: Use Cases (Domain Layer)

Krótki opis: Implementacja podstawowych Use Cases: CreateDocument, UpdateDocument, DeleteDocument, GetDocument, CreateBlock, UpdateBlock, DeleteBlock w domain layer.

---

### [US-006]

[ ] Status

Nazwa: Dependency Injection setup

Krótki opis: Konfiguracja GetIt dla dependency injection, rejestracja wszystkich serwisów, repozytoriów, use cases i cubitów. Setup service locator pattern.

## 2. Lokalne przechowywanie (Offline-First)

### [US-007]

[ ] Status

Nazwa: Konfiguracja SQLite z Brick

Krótki opis: Konfiguracja SQLite jako głównej bazy danych z Brick jako ORM. Utworzenie tabel dla Documents i Blocks z odpowiednimi relacjami i indeksami.

---

### [US-008]

[ ] Status

Nazwa: Local Data Sources

Krótki opis: Implementacja LocalDocumentDataSource i LocalBlockDataSource w data layer, obsługujących operacje CRUD na lokalnej bazie SQLite z Brick.

---

### [US-009]

[ ] Status

Nazwa: Repository implementations (Data Layer)

Krótki opis: Implementacja DocumentRepositoryImpl i BlockRepositoryImpl w data layer, które najpierw wykorzystują lokalne data sources (offline-first approach).

---

### [US-010]

[ ] Status

Nazwa: Memory cache dla lokalnych danych

Krótki opis: Implementacja pamięci podręcznej dla często używanych dokumentów i bloków, optymalizującej wydajność lokalnego przechowywania.

---

### [US-011]

[ ] Status

Nazwa: Automatyczne zapisywanie z debounce

Krótki opis: Implementacja automatycznego zapisywania zmian w dokumentach i blokach z debounce mechanizmem, bez konieczności ręcznego zapisywania.

## 3. Custom RenderObject System

### [US-012]

[ ] Status

Nazwa: Custom RenderObject dla tekstu

Krótki opis: Implementacja custom RenderObject-based approach dla renderowania tekstu z pełną kontrolą nad renderowaniem, zgodnie z architekturą aplikacji.

---

### [US-013]

[ ] Status

Nazwa: Custom input handling

Krótki opis: Implementacja specialized input handling dla keyboard, touch i mouse interactions w custom RenderObject systemie.

---

### [US-014]

[ ] Status

Nazwa: Custom cursor i selection management

Krótki opis: Implementacja custom cursor rendering, movement i text selection w RenderObject systemie z pełną kontrolą nad wizualizacją.

---

### [US-015]

[ ] Status

Nazwa: Optymalizacje renderowania tekstu

Krótki opis: Implementacja wydajnego handling tekstu: incremental updates, caching rendered text spans, compositor-friendly layer management, asynchronous formatting calculations.

## 4. Formatowanie tekstu i Focus Management

### [US-016]

[ ] Status

Nazwa: Model TextFormatting

Krótki opis: Implementacja klasy TextFormatting definiującej atrybuty stylu: bold, italic, underline, strikethrough, color, background color, font family, font size.

---

### [US-017]

[ ] Status

Nazwa: FormattedSpan system

Krótki opis: Implementacja obiektów FormattedSpan definiujących zakresy tekstu z określonym formatowaniem, zgodnie z span-based approach z architektury.

---

### [US-018]

[ ] Status

Nazwa: Algorytm fragmentacji tekstu

Krótki opis: Implementacja fragmentation algorithm - dzielenie tekstu na fragmenty w miejscach zmiany formatowania, każdy fragment z unique combination formatting attributes.

---

### [US-019]

[ ] Status

Nazwa: Focus and Navigation Management System

Krótki opis: Implementacja dedicated focus management system: sequential navigation (Tab/Shift+Tab), intelligent Enter behavior, smart Backspace handling między blokami. Kliknięcie enter powinno poniżej stworzyć blok o tym samym typie jeśli jest taki sens.

---

### [US-020]

[ ] Status

Nazwa: Common Formatting Interface

Krótki opis: Implementacja common formatting interface dla wszystkich block types zawierających tekst, zapewniającego consistent behavior w całej aplikacji.

---

### [US-021]

[ ] Status

Nazwa: Pasek narzędzi formatowania

Krótki opis: Implementacja paska narzędzi pojawiającego się po zaznaczeniu tekstu, wykorzystującego common formatting interface.

## 5. Podstawowe typy bloków

### [US-022]

[ ] Status

Nazwa: Hybrid Rendering Architecture

Krótki opis: Implementacja hybrid approach łączącego custom RenderObject rendering z Flutter widgets: Core Rendering Level (RenderObject) + Widget Structure Level (Flutter widgets).

---

### [US-023]

[ ] Status

Nazwa: Paragraph Block

Krótki opis: Implementacja podstawowego bloku tekstowego z complete rich text formatting, support dla inline links, automatic conversion do innych block types.

---

### [US-024]

[ ] Status

Nazwa: Heading Blocks (H1, H2, H3)

Krótki opis: Implementacja trzech poziomów heading blocks z distinctive styling i font sizes, wykorzystujących shared formatting system z RenderObject.

---

### [US-025]

[ ] Status

Nazwa: Divider Block

Krótki opis: Implementacja horizontal line separator z multiple style options (solid, dashed, dotted), customizable thickness, shape i color.

---

### [US-026]

[ ] Status

Nazwa: Command Detection System

Krótki opis: Implementacja systemu wykrywania komend "/" z Command Palette (CommandPaletteCubit), trigger options dla różnych block types.

## 6. Timeline View (Endless Timeline)

### [US-027]

[ ] Status

Nazwa: TimelineDocument model

Krótki opis: Implementacja specialized TimelineDocument extending abstract Document, z date property i timeline-specific behavior.

---

### [US-028]

[ ] Status

Nazwa: Center Index Approach

Krótki opis: Implementacja endless timeline z center index approach: arbitrary large index (10000) jako center point mapped do current date, bidirectional scrolling.

---

### [US-029]

[ ] Status

Nazwa: Date-Index Mapping Algorithm

Krótki opis: Implementacja algorytmu dynamically calculating dates based na offset from center index, z constant-time lookups i efficient navigation.

---

### [US-030]

[ ] Status

Nazwa: Virtual Day Rendering

Krótki opis: Implementacja virtual day rendering: only visible days + buffer, days remain virtual until content added, memory optimization.

---

### [US-031]

[ ] Status

Nazwa: Document Lazy Loading dla Timeline

Krótki opis: Implementacja lazy loading - documents fetched tylko gdy date is getting closer do visible range, z configurable buffer system.

---

### [US-032]

[ ] Status

Nazwa: Variable Day Height System

Krótki opis: Implementacja dynamic day tile height based na content density, optimizing rendering performance.

---

### [US-033]

[ ] Status

Nazwa: Holiday Calendar Integration

Krótki opis: Implementacja holiday calendar integration (enabled by default, can be disabled) displaying national holidays, cultural events, important dates like Valentine's Day, Mother's Day.

## 7. Project View

### [US-034]

[ ] Status

Nazwa: ProjectDocument model

Krótki opis: Implementacja specialized ProjectDocument extending abstract Document, z title, icon, iconColor properties i project-specific behavior.

---

### [US-035]

[ ] Status

Nazwa: Project Document View

Krótki opis: Implementacja standard project document view z all content types, utilizing hybrid rendering architecture.

---

### [US-036]

[ ] Status

Nazwa: Project Timeline View

Krótki opis: Implementacja timeline view showing only project-related items, z filtering mechanism i project-specific timeline rendering.

---

### [US-037]

[ ] Status

Nazwa: Virtual References System

Krótki opis: Implementacja virtual references dla project tasks appearing na main timeline - displayed as references, not duplicated, maintaining data integrity.

## 8. Zaawansowane Block Types

### [US-038]

[ ] Status

Nazwa: List Blocks (Bulleted i Numbered)

Krótki opis: Implementacja bulleted list (•, -, ○) i numbered list (1., a., i.) z multi-level nesting, different marker styles per level, rich text formatting within items.

---

### [US-039]

[ ] Status

Nazwa: Toggle Blocks

Krótki opis: Implementacja toggle blocks z header text i collapsible content, animated transitions, memory of collapsed/expanded state between sessions, nested block support.

---

### [US-040]

[ ] Status

Nazwa: Quote i Callout Blocks

Krótki opis: Implementacja Quote blocks z distinctive styling i vertical accent line, Callout blocks z icons i background colors, multiple preset styles (info, warning, success).

---

### [US-041]

[ ] Status

Nazwa: Code Blocks

Krótki opis: Implementacja syntax-highlighted code blocks z language detection, monospace font, line numbers, copy functionality, horizontal scrolling dla long lines.

---

### [US-042]

[ ] Status

Nazwa: Image Blocks (Media Blocks)

Krótki opis: Implementacja embedded images z optional captions, multiple image formats, resizable z aspect ratio maintenance, lazy loading, click to expand/zoom functionality.

## 9. Todo Functionality i Task Management

### [US-043]

[ ] Status

Nazwa: Todo Block z metadanymi

Krótki opis: Implementacja Todo blocks z checkbox, content, metadata (due date, repetition), visual distinction między completed i pending tasks.

---

### [US-044]

[ ] Status

Nazwa: RepetitionRule model

Krótki opis: Implementacja flexible repetition system: RepetitionType (daily, weekly, monthly, custom), interval, daysOfWeek, dayOfMonth, endDate, maxOccurrences.

---

### [US-045]

[ ] Status

Nazwa: Visual Repetition Indicators

Krótki opis: Implementacja color-coded left border dla task widgets: Daily (Blue #2563EB), Weekly (Green #059669), Monthly (Orange #EA580C), Custom (Purple #7C3AED).

---

### [US-046]

[ ] Status

Nazwa: Task Completion Logic

Krótki opis: Implementacja task completion z generation next occurrence dla repeating tasks, different behavior dla timeline (new instances) vs projects (replacement w projekcie dla zachowania porządku, ale ukończone zadania pozostają widoczne na timeline dla zachowania historii).

---

### [US-047]

[ ] Status

Nazwa: System Sortowania na Poziomie Dokumentu

Krótki opis: Implementacja document-level sorting gdzie każdy dokument utrzymuje własną uporządkowaną tablicę bloków. Sortowana relacja jeden do wielu - bloki nie przechowują informacji o pozycji, dokument zarządza kolejnością poprzez tablicę ID bloków.

---

### [US-048]

[ ] Status

Nazwa: Drag-and-Drop Support dla Blocks

Krótki opis: Implementacja manual reordering blocks poprzez modyfikację tablicy bloków w dokumencie: dodawanie bloku (append ID do tablicy), przenoszenie bloku (zmiana pozycji w tablicy), usuwanie bloku (usunięcie ID z tablicy). Bloki nie muszą znać swojej pozycji - dokument zarządza kolejnością.

---

### [US-049]

[ ] Status

Nazwa: Dialog reguł powtarzania

Krótki opis: Implementacja dialog dla setting repetition rules z presets i custom options, integration z RepetitionRule model.

## 10. Block System Enhancements

### [US-050]

[ ] Status

Nazwa: Block Animation System

Krótki opis: Implementacja smooth transitions między block states i types: block type conversion, state changes, block reordering z consistent animation timing.

---

### [US-051]

[ ] Status

Nazwa: Block Transformation System

Krótki opis: Implementacja conversions między block types: content preservation, smart transformations, undo support dla reverting changes.

---

### [US-052]

[ ] Status

Nazwa: Przenoszenie bloków z animacjami

Krótki opis: Implementacja drag-and-drop dla blocks z dynamic animations, smooth reordering transitions, utilizing Block Animation System.

## 11. State Management (BLoC/Cubit)

### [US-053]

[ ] Status

Nazwa: DocumentCubit

Krótki opis: Implementacja DocumentCubit dla straightforward document state management, utilizing Use Cases z domain layer.

---

### [US-054]

[ ] Status

Nazwa: BlockCubit

Krótki opis: Implementacja BlockCubit dla block-level state management, handling different block types i their specific behaviors.

---

### [US-055]

[ ] Status

Nazwa: CommandPaletteCubit

Krótki opis: Implementacja CommandPaletteCubit dla command detection i block type selection, mentioned w architecture jako key component.

---

## 12. Autentykacja (Opcjonalna, Non-blocking)

### [US-056]

[ ] Status

Nazwa: Anonymous Sessions

Krótki opis: Implementacja anonymous sessions allowing app usage bez account creation, data stored locally only, supporting progressive enrollment approach.

---

### [US-057]

[ ] Status

Nazwa: Supabase Authentication Setup

Krótki opis: Konfiguracja Supabase dla email/password i Google authentication, z proper separation od core functionality.

---

### [US-058]

[ ] Status

Nazwa: Authentication Screens

Krótki opis: Implementacja Sign In, Sign Up, Password Reset, Account Management screens z user-friendly error handling.

---

### [US-059]

[ ] Status

Nazwa: Persistent Sessions z Performance

Krótki opis: Implementacja long-lived sessions, automatic token refresh, cached credentials w shared preferences, parallel initialization dla "super fast" authentication.

---

### [US-060]

[ ] Status

Nazwa: Token Management z Retry Logic

Krótki opis: Implementacja automatic token refresh, transparent retry failed requests due to token expiration, seamless background handling.

## 13. Synchronizacja (Cloud Integration)

### [US-061]

[ ] Status

Nazwa: Supabase Database Schema

Krótki opis: Utworzenie odpowiednich tabel i relacji w Supabase dla Documents i Blocks, supporting synchronization requirements.

---

### [US-062]

[ ] Status

Nazwa: Remote Data Sources

Krótki opis: Implementacja RemoteDocumentDataSource i RemoteBlockDataSource dla Supabase integration w data layer.

---

### [US-063]

[ ] Status

Nazwa: RealtimeSyncService

Krótki opis: Implementacja centralized RealtimeSyncService managing real-time synchronization: model registration, event handling (INSERT, UPDATE, DELETE), type-safe handling.

---

### [US-064]

[ ] Status

Nazwa: Repository Enhancement dla Sync

Krótki opis: Enhancement existing repository implementations o remote data sources, maintaining offline-first approach z cloud sync.

---

### [US-065]

[ ] Status

Nazwa: Brick Offline Queue Configuration

Krótki opis: Konfiguracja wbudowanego systemu offline queue w Brick podczas inicjalizacji Repository. Brick automatycznie kolejkuje operacje podczas braku połączenia i wykonuje je po przywróceniu łączności bez dodatkowej implementacji.

---

### [US-066]

[ ] Status

Nazwa: Conflict Resolution

Krótki opis: Implementacja conflict resolution mechanism dla concurrent edits, utilizing timestamps i "last write wins" strategy.

---

### [US-067]

[ ] Status

Nazwa: Background Sync z Debounce

Krótki opis: Implementacja background sync z debounced auto-save, immediate UI updates when changes received, proper handling task repetition.

## 14. Performance Optimizations

### [US-068]

[ ] Status

Nazwa: Virtualized Lists

Krótki opis: Implementacja virtualized lists dla efficient rendering dużych list bloków, only visible blocks + buffer rendered.

---

### [US-069]

[ ] Status

Nazwa: Timeline Performance Optimizations

Krótki opis: Implementacja scroll position management, efficient timeline navigation, memory optimization, day buffer system dla smooth scrolling.

---

### [US-070]

[ ] Status

Nazwa: Lazy Loading dla Media

Krótki opis: Implementacja lazy loading dla images i files, loading resources only when visible, performance optimization dla media-heavy documents.

---

### [US-071]

[ ] Status

Nazwa: Incremental Updates System

Krótki opis: Implementacja incremental updates updating only changed blocks instead of entire document, optimization dla large documents.

---

### [US-072]

[ ] Status

Nazwa: Responsive Design Support

Krótki opis: Implementacja responsive design dla both mobile i desktop screen sizes, ensuring optimal UX across different devices.
