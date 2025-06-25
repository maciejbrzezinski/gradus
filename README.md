# Gradus 
*Build your story - day by day.*

Timeline-first planner where **tasks, notes & ideas live together naturally**.  
Open-source, built with **Flutter + Firebase**.

![gif](https://github.com/user-attachments/assets/6d05d621-d044-4ace-8f40-8f5f89e7cc29)


## 🏗️ Architecture

Built with **Clean Architecture** principles:
- **Pages** → **Widgets** → **Cubits** → **Use Cases** → **Repositories** → **Data Sources**
- **Freezed** entities for immutable data models
- **GetIt + Injectable** for dependency injection
- **Either pattern** for error handling
- **Stream-based** real-time updates

## 💡 Key Concepts

- **Timeline-First** - Everything lives on your weekly timeline
- **Mixed Content** - Tasks, notes, and ideas coexist naturally
- **Project Contexts** - Filter your timeline by Personal, Work, or custom projects
- **Smart Input** - Type `[]` for tasks, `/` for type selection, plain text for notes
- **Drag & Drop** - Move anything anywhere with visual feedback

## 🎯 Vision

Gradus understands that your week is more than just a checklist. It's where tasks, notes, and random thoughts come together in a timeline that tells the story of your days.

*Clean, focused, and intuitive. Just your timeline, your way.*

## 🚀 Current Status

### ✅ Implemented Features
- **🔐 Authentication System** - Full authentication system with email/password and Google Sign-In
- **🏗️ Clean Architecture** - Clean layer separation with Cubits, Use Cases, Repositories
- **📱 Timeline Foundation** - Horizontal scrolling day columns with today highlighting
- **🎯 Project System** - Animated project tabs for switching between Personal/Work contexts
- **✅ Task Management** - Checkbox completion, inline editing with auto-save
- **🎨 Type Selector** - Modal for choosing item types (text, headlines, tasks)
- **🔄 Basic Drag & Drop** - Move items between days with visual feedback
- **☁️ Firebase Integration** - Firestore sync, offline-first architecture
- **🎨 Theme System** - Comprehensive design system with consistent styling

### 🔄 Partially Implemented
- **📅 Recurring Tasks** - Data model exists, shows "Daily" badge but needs full UI
- **📄 Note Cards** - Note entity exists but display needs refinement
- **♾️ Infinite Scroll** - Timeline scrolling foundation exists but disabled
- **📝 Item Creation** - Smart text parsing (`[]` for tasks, `/` for type selector modal)

## 📋 Development Roadmap

### 🎯 Core Features (High Priority)
- [ ] **Enter Key Creation** - Add new items by pressing Enter in any day
- [ ] **Backspace Deletion** - Delete items using backspace key
- [ ] **Enhanced Drag & Drop** - Generic system with target index + landing animations

### 🎨 UX Improvements (Medium Priority)
- [ ] **Recurring Tasks UI** - Beautiful interface for daily/weekly/monthly tasks
- [ ] **Cross-Project Movement** - Move items between projects
- [ ] **Add Project Button** - UI for creating and customizing new project contexts

## 🔥 Firebase Setup

This project requires Firebase configuration. To set up Firebase:

1. **Install Firebase CLI and FlutterFire CLI:**
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```

2. **Create your own Firebase project** at https://console.firebase.google.com

3. **Configure Firebase for this Flutter project:**
   ```bash
   flutterfire configure
   ```

4. **Follow the prompts** to select your Firebase project and platforms

This will generate the required `firebase_options.dart` file and platform-specific configuration files.

5. **Replace the Google Sign-In client ID** in `lib/core/di/firebase_module.dart` with your own client ID from your Firebase project's Google Sign-In configuration.

For detailed instructions, see: https://firebase.flutter.dev/docs/cli/
