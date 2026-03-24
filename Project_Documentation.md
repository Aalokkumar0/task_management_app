# Task Management App - Project Documentation

## 1. Project Overview
The **Task Management App** is a fully functional, mobile application built with **Flutter**. It is designed to manage tasks effectively with features like creating, reading, updating, and deleting tasks (CRUD), searching and filtering, drag-and-drop reordering, and a special dependency logic system (Blocked Tasks). 

The app employs local data persistence using **SQLite** (via `sqflite`) and state management utilizing the **Provider** package. 

## 2. Core Features
- **Local Persistence:** Task data is persistently stored in a local SQLite database ensuring offline availability.
- **Simulated Delays:** A simulated 2-second network delay is implemented for task creation/updating to mock API integrations.
- **Auto-Saving Drafts:** Unfinished task creations are automatically saved as drafts and restored when the user returns.
- **Advanced Search & Filters:**
  - Real-time **debounced search** that highlights the search keywords in the task UI.
  - **Status filtering** (To-Do, In Progress, Done, Blocked).
- **Drag & Drop Reordering:** Users can physically reorder their tasks for prioritizing, which relies on a synchronized `sort_order` database column.
- **Special Logic (Blocked Tasks):** If `Task B` depends on `Task A`, `Task B` is grayed out and its interactions (edit, tap, delete) are completely disabled until `Task A` is marked as 'Done'.
- **Modern Attractive UI:** Incorporates a tailored design language using Seed Colors (Indigo), custom gradients, and visual hierarchy elements inside the Custom `AppTheme`.

---

## 3. Project Architecture
The project adheres to a clean architecture separating the UI logic from the business logic and the database layer.

### 3.1. Models (`lib/models/task.dart`)
- **TaskStatus Enum:** Defines `todo`, `inProgress`, `done`, and `blocked`.
- **Task Class:** 
  - Represents a single task entity with properties such as `id` (UUID), `title`, `description`, `dueDate`, `status`, `blockedById`, and `sortOrder`.
  - Includes helper functions like `isDone`, `copyWith()`, `toMap()`, and `fromMap()`.

### 3.2. Local Database (`lib/database/database_helper.dart`)
A singleton SQLite database helper handling schema creation and interactions:
- **Table schema (`tasks`)**: Stores text fields, dates as ISO strings, and sort integers.
- **Cascade Operations**: If a blocker task is deleted, the database gracefully unblocks tasks depending on it using `UPDATE tasks SET blocked_by_id = null`.
- **Batch Reordering**: Handles drag-and-drop array position swaps using DB `batch()` commits for high performance.

### 3.3. State Management / Providers
- **`TaskProvider`**:
  - The core "Brain" of the component, handling all state operations bridging the Database and the UI.
  - Contains collections for `allTasks` and cleanly filtered `filteredTasks`.
  - Calculates runtime dependency checks `isBlocked(task)` logic.
- **`DraftProvider`**:
  - Uses `SharedPreferences` to silently auto-save and restore the user's unfinished task drafts (`draft_title`, `draft_desc`).

### 3.4. User Interface Layer
- **`TaskListScreen`**: The primary dashboard housing:
  - An attractive top App Bar with a greeting.
  - A responsive Search TextField with prefix icons.
  - A horizontal selector of `FilterChip` items.
  - A `ReorderableListView` mapping the items into widgets.
- **`TaskFormScreen`**: The create/edit entry point for users:
  - TextFields for titles and descriptions.
  - Interactive Date picker, Custom segmented radio buttons for the UI Status selection.
  - A Dropdown to select "Blocked By" dependencies (filters out self).
- **`TaskCard` (Widget)**: 
  - Richly designed container featuring gradient top bars based on status color sets.
  - Embeds the `_HighlightedText` inline span builder to visually point out user search matches.
  - Respects the "Blocked Logic" rendering zero interactability if locked.

---

## 4. Theming Strategy (`lib/theme/app_theme.dart`)
Instead of standard Material 3 pallets, the app forces a highly-opinionated, modern UI theme:
- Typography uses large bold weights for headers (`FontWeight.w800`).
- Specialized logic like `AppTheme.statusColor()` forces semantic colors (ex: Amber for "In Progress", Red for "Blocked", Green for "Done").
- Utilizes transparent AppBar elevations, glass background scaffolds (`#F8FAFC`), and subtle card soft shadows.

## 5. Technical Stack
- **Framework:** Flutter SDK (Dart)
- **Database:** `sqflite`
- **State Management:** `provider`
- **Unique Identification:** `uuid`
- **Date Formatting:** `intl`
- **Storage:** `shared_preferences` (for drafts)
