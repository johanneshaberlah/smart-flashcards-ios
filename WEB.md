# Smart Flashcards Application - iOS Recreation Specification

> This document provides complete specifications for recreating the Smart Flashcards web application as a native iOS app. It covers all features, screens, API endpoints, and design patterns.

---

## Table of Contents
1. [High-Level Overview](#high-level-overview)
2. [Current Project Status](#current-project-status)
3. [Application Architecture](#application-architecture)
4. [Authentication System](#authentication-system)
5. [Screen-by-Screen Documentation](#screen-by-screen-documentation)
6. [API Reference](#api-reference)
7. [Data Models](#data-models)
8. [Design System](#design-system)
9. [User Flows](#user-flows)
10. [iOS Implementation Notes](#ios-implementation-notes)

---

## High-Level Overview

### Application Purpose
Smart Flashcards is a spaced-repetition learning application that allows users to:
- Create and manage flashcard stacks (decks)
- Create, edit, and delete individual flashcards
- Study flashcards using an interactive flip-and-rate system
- Generate flashcards automatically from PDF documents using AI
- Track learning progress with maturity/due dates

### Key Features

| Feature | Description |
|---------|-------------|
| **Stack Management** | Create, view, and delete flashcard stacks with custom names and colors |
| **Card CRUD** | Full create, read, update, delete operations for flashcards |
| **Interactive Learning** | Tap-to-flip cards with difficulty rating system |
| **Spaced Repetition** | Cards have maturity dates based on difficulty ratings |
| **AI Generation** | Upload PDFs to automatically generate flashcards |
| **Hint System** | Optional hints during learning sessions |
| **Learn Ahead** | Study future cards before they're due |

### Tech Stack (Original Web App)
- **Framework**: Vue 3 with TypeScript
- **Styling**: Tailwind CSS
- **Router**: Vue Router
- **HTTP Client**: Axios
- **Auth**: Cookie-based JWT tokens
- **Language**: German UI

---

## Current Project Status

### Existing Codebase Analysis

The current project at `/Users/jhaberlah/projects/university/smart-flashcards-application` is a **Vue.js 3 + TypeScript web application**. There is **NO existing iOS project or Xcode workspace**.

### Current Folder Structure

```
smart-flashcards-application/
├── public/                          # Static assets
│   └── brain.svg
├── src/                             # Source code
│   ├── assets/                      # Application assets
│   │   ├── icons/                   # (currently empty)
│   │   ├── loading.gif
│   │   ├── logo.svg
│   │   └── main.css
│   ├── models/                      # TypeScript data models
│   │   ├── Card.ts
│   │   ├── CardContext.ts
│   │   ├── CardMaturity.ts
│   │   ├── CardRating.ts
│   │   ├── Difficulty.ts
│   │   ├── DifficultyAndDuration.ts
│   │   ├── Duration.ts
│   │   ├── Stack.ts
│   │   └── StackContext.ts
│   ├── router/                      # Vue Router configuration
│   │   ├── axiosInstance.ts         # HTTP client setup
│   │   └── index.ts                 # Route definitions
│   ├── services/                    # (currently empty directory)
│   ├── views/                       # Vue components
│   │   ├── Dashboard.vue
│   │   ├── Header.vue
│   │   ├── LandingPage.vue
│   │   ├── auth/
│   │   │   └── LoginRegister.vue
│   │   └── stack/
│   │       ├── CreateOrUpdateCard.vue
│   │       ├── CreateStack.vue
│   │       ├── Learning.vue
│   │       ├── Stack.vue
│   │       └── StackMagic.vue
│   ├── App.vue                      # Root Vue component
│   ├── index.css
│   └── main.ts                      # Application entry point
├── dist/                            # Built production files
├── Configuration files:
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   ├── docker-compose.yaml
│   ├── Dockerfile
│   └── README.md
└── .git/                            # Git repository
```

### Available Assets

| Asset | Location | Description |
|-------|----------|-------------|
| `brain.svg` | `/public/brain.svg` | Main logo/icon |
| `logo.svg` | `/src/assets/logo.svg` | Alternative logo |
| `loading.gif` | `/src/assets/loading.gif` | Loading animation (101KB) |

---

## Application Architecture

### Navigation Structure
```
/                           → Landing Page (unauthenticated)
├── /login                  → Login Screen
├── /register               → Registration Screen
└── /dashboard              → Main Dashboard (authenticated)
    └── /stack/create       → Create New Stack
    └── /stack/:stackId     → Stack Detail View
        ├── /learn          → Learning Session
        ├── /magic          → AI Card Generation
        └── /card/create    → Create Card
        └── /card/:cardId   → Edit Card
```

### Authentication Flow
1. Unauthenticated users see Landing Page
2. Login/Register → Receive JWT token
3. Token stored in cookie (7-day expiry)
4. All `/dashboard/*` routes require valid token
5. Invalid/missing token → Redirect to `/login`

---

## Authentication System

### Cookie Management
| Cookie | Value | Expiry |
|--------|-------|--------|
| `auth` | JWT token | 7 days |
| `name` | Username | Session |

### Protected Routes
All routes except `/`, `/login`, `/register` require authentication.

### API Authentication
All authenticated requests include:
```
Authorization: {token}
```

---

## Screen-by-Screen Documentation

### 1. Landing Page (`/`)

**Purpose**: Marketing page for unauthenticated users

**UI Elements**:
- Header with logo and "Anmelden" (Login) link
- Hero section with:
  - Headline: "Lernen neu gedacht." (Learning reimagined)
  - Subtext explaining AI flashcard generation
  - Two CTA buttons: "Jetzt loslegen" (Get Started) → `/register`, "Anmelden" (Login) → `/login`

**HTML Structure**:
```html
<header>
  <nav class="flex items-center justify-between pt-6 pb-4 lg:pt-8 border-b">
    <a href="/" class="-m-1.5 p-1.5">
      <img class="h-8 w-auto" src="brain.svg" alt="">
    </a>
    <a href="/login" class="text-sm font-semibold leading-6 text-gray-900">
      Anmelden <span aria-hidden="true">&rarr;</span>
    </a>
  </nav>
</header>

<main>
  <h1 class="text-6xl font-bold tracking-tight text-gray-900">
    Lernen neu gedacht.
  </h1>
  <p class="mt-4 text-lg leading-8 text-gray-600">
    Lasse dir von unserer innovativen künstlichen Intelligenz Karteikarten
    für deine nächste Klausur erstellen und lerne sie so effektiv wie nie zuvor.
  </p>
  <div class="flex items-center gap-x-6">
    <a href="/register" class="rounded-md bg-emerald-600 px-3.5 py-2.5 text-sm
      font-semibold text-white shadow-sm hover:bg-emerald-500">
      Jetzt loslegen
    </a>
    <a href="/login" class="text-sm font-semibold leading-6 text-gray-900">
      Anmelden <span aria-hidden="true">→</span>
    </a>
  </div>
</main>
```

---

### 2. Login Page (`/login`)

**Purpose**: Authenticate existing users

**Form Fields**:
| Field | Type | Label | Validation |
|-------|------|-------|------------|
| Email | email | "Email-Adresse" | Required |
| Password | password | "Passwort" | Required, min 8 chars |

**Buttons**:
- "Anmelden" (Login) - Primary submit button
- Link to register: "Du hast noch keinen Account?" → `/register`

**Error States**:
- Empty email: "Gebe deine E-Mail ein"
- Empty password: "Gebe dein Passwort ein"
- API error: "Login fehlgeschlagen. Überprüfe deine Eingaben."

**API Call**:
```
POST /login
Body: { mail: string, password: string }
Response: { token: string, username: string }
```

---

### 3. Registration Page (`/register`)

**Purpose**: Create new user accounts

**Form Fields**:
| Field | Type | Label | Validation |
|-------|------|-------|------------|
| Name | text | "Name" | Required, min 2 chars |
| Email | email | "Email-Adresse" | Required |
| Password | password | "Passwort" | Required, min 8 chars |

**Buttons**:
- "Registrieren" (Register) - Primary submit button
- Link to login: "Du hast bereits einen Account?" → `/login`

**Error States**:
- Empty name: "Gebe deinen Namen ein"
- Empty email: "Gebe deine E-Mail ein"
- Empty password: "Gebe dein Passwort ein"
- API error: "Registrierung fehlgeschlagen. Es existiert bereits ein Account mit dieser Mail."

**API Call**:
```
POST /signup
Body: { name: string, mail: string, password: string }
Response: { token: string, username: string }
```

---

### 4. Dashboard (`/dashboard`)

**Purpose**: Main hub showing all user's flashcard stacks

**Header Component** (shared across authenticated pages):
- Logo linking to `/dashboard`
- Username display with logout functionality

**Page Title & Actions**:
- Title: "Deine Stapel"
- "Erstellen" button → `/stack/create`

**Stacks Grid**:
- Grid layout: 1 column mobile, 2 columns tablet, 4 columns desktop
- Each stack shows:
  - Color badge with first 4 letters of name
  - Stack name
  - Card count: "{n} Karten"
  - Chevron button to navigate

**Empty State** (when no stacks exist):
- Dashed border container
- Document icon
- Text: "Erstelle deinen ersten Stapel"
- Links to `/stack/create`

**Loading State**: "Deine Stapel werden geladen..."

**API Call**:
```
GET /stack
Response: Stack[] (array of stacks with cards)
```

---

### 5. Create Stack Page (`/stack/create`)

**Purpose**: Create a new flashcard stack

**Form Fields**:
| Field | Type | Label | Required |
|-------|------|-------|----------|
| Name | text | "Name *" | Yes |
| Color | color picker | "Farbe *" | Yes (default: #000000) |

**Error Message**: "Beim Erstellen des Stapels ist ein Fehler aufgetreten. Bitte wähle einen Namen und eine Farbe für deinen Stapel."

**Buttons**:
- "Zurück" → `/dashboard`
- "Speichern" - Submit

**API Call**:
```
POST /stack
Body: { name: string, color: string }
Response: Success status
```

---

### 6. Stack Detail Page (`/stack/:stackId`)

**Purpose**: View stack details and manage cards

**Breadcrumb**:
- Mobile: Back arrow with "Zurück" → `/dashboard`
- Desktop: "Stapel" → "Stack Name"

**Page Header**:
- Stack name as title
- Action buttons:
  - "Löschen" (Delete) - Secondary button
  - "Jetzt lernen" (Learn) - Primary emerald button
  - "Automatisch erstellen" (AI Generate) - Yellow button

**Cards Section**:
- Section title: "Karteikarten"
- Description: "Anbei eine Liste aller Karteikarten in diesem Stapel mit ihrem Fälligkeitsdatum."
- "Karte erstellen" button

**Cards Table**:
| Column | Mobile | Desktop | Content |
|--------|--------|---------|---------|
| ID | Yes | Yes | First 6 chars of uniqueId (uppercase) |
| Vorderseite | Yes | Yes | Question (truncated to 32 chars) |
| Rückseite | No | Yes | Answer (truncated to 32 chars) |
| Fälligkeitsdatum | No | Yes | Maturity date + " Uhr" or "-" |
| Bearbeiten | Yes | Yes | Edit link |

**API Calls**:
```
GET /stack/{stackId}
Response: Stack with cards array

DELETE /stack/{stackId}
Response: Success status
```

---

### 7. Create/Edit Card Page (`/stack/:stackId/card/create` or `/stack/:stackId/card/:cardId`)

**Purpose**: Create new or edit existing flashcard

**Mode Detection**: If `cardId` param exists → Edit mode, otherwise Create mode

**Form Fields**:
| Field | Type | Label | Validation |
|-------|------|-------|------------|
| Question | text | "Vorderseite *" | Required |
| Answer | textarea (8 rows) | "Rückseite *" | Required |

**Form Header**:
- Title: "Neue Karteikarte anlegen"
- Description: "Lege eine neue Karteikarte an und beginne direkt mit dem Lernen. Achte darauf, dass sich die Vorderseiten nicht zu sehr ähneln für besseren Wiedererkennungswert."

**Answer Field Helper Text**: "Schreibe Stichpunkte oder Fließtext auf die Rückseite deiner Karteikarte."

**Error Message**: "Beim Erstellen der Karte ist ein Fehler aufgetreten. Bitte fülle die Vorder- und Rückseite deiner Karte korrekt aus."

**Success Message**:
- Title: "Karteikarte gespeichert"
- Text: "Die Karteikarte wurde gespeichert und dem Stapel hinzugefügt. Du kannst nun anfangen zu lernen oder weitere Karteikarten erstellen."
- "Stapel ansehen" button

**Edit Mode Extra Buttons**:
- "Löschen" (Delete) - Deletes current card
- "Neue Karte erstellen" - Switches to create mode

**API Calls**:
```
# Create Mode
POST /card
Body: { question: string, answer: string, stackId: string }

# Edit Mode - Fetch existing
GET /stack/{stackId}/card/{cardId}
Response: Card object

# Edit Mode - Update
PUT /stack/{stackId}/card/{cardId}
Body: { cardId: string, question: string, answer: string, stackId: string }

# Delete
DELETE /stack/{stackId}/card/{cardId}
```

---

### 8. Learning Page (`/stack/:stackId/learn`)

**Purpose**: Interactive study session with flip-and-rate system

**Breadcrumb**: "Stapel" → "Stack Name" → "Lernen"

**Main Card Display**:
- Card header shows question
- Hint button (only if card has hint)
- Card body shows answer (initially blurred)
- Flip icon overlay (visible when blurred)
- Hint display area (hidden by default)
- Difficulty rating buttons (hidden until card is flipped)

**Difficulty Buttons**:
- Dynamic colors from API
- Format: "{difficulty.name} ({duration.displayName})"

**Completion Modal**:
- Success icon (green checkmark)
- Title: "Toll gemacht!"
- Text: "Du bist für heute fertig, da das Fälligkeitsdatum aller Karten erst frühestens morgen ist."
- "Zurück zum Dashboard" button
- Learn Ahead feature:
  - "Für {X} Tage vorauslernen"
  - Number input
  - "Los gehts!" button

**Learning Flow**:
1. Fetch next due card from API
2. Display question (answer is blurred)
3. User taps card to flip → Remove blur, hide flip icon, show difficulty buttons
4. User selects difficulty rating
5. Submit rating to API
6. Reset card (re-blur answer, hide difficulty buttons)
7. Fetch next card
8. When no more cards → Show completion modal
9. Optional: Enter days to learn ahead

**API Calls**:
```
# Get next due card
GET /stack/{stackId}/card/next
Optional Query: ?days-ahead={number}
Response: Card object or 404 (no cards due)

# Submit rating
POST /stack/rating
Body: { stackId: string, cardId: string, difficulty: bigint }
```

---

### 9. AI Card Generation Page (`/stack/:stackId/magic`)

**Purpose**: Generate flashcards automatically from PDF using AI

**Breadcrumb**: "Stapel" → "Magie"

**Form Header**:
- Title: "Automatisch Karten erstellen."
- Description: "Lade hier deine Datei hoch. Eine künstliche Intelligenz wird basierend auf diesem Karteikarten für dich erstellen."

**Form Fields**:
| Field | Type | Label | Validation |
|-------|------|-------|------------|
| Custom Instructions | textarea (3 rows) | "Eigene Anweisungen (optional)" | Optional |
| File | file (PDF only) | "Datei *" | Required, max 10MB |

**File Upload Area**:
- Placeholder: "Formuliere alle Karteikarten in Stichpunkten."
- Upload text: "Klicke hier, um deine Datei hochzuladen"
- Restriction note: "Es werden ausschließlich PDF Dateien bis 10MB angenommen."

**Error Messages**:
- General error: "Beim magischen Erstellen der Karten ist ein Fehler aufgetreten. Wähle eine andere Datei, passe deine Anweisungen an oder versuche es später erneut."
- File error: "Beim magischen Erstellen der Karten ist ein Fehler aufgetreten. Bitte wähle eine Datei aus, bevor du fortfährst."

**Loading Modal Progress Text Timeline**:
| Time | Message |
|------|---------|
| 0s | "Die Karten werden importiert..." |
| 5s | "Deine Datei wird überprüft..." |
| 12s | "Deine Datei wird hochgeladen..." |
| 19s | "Deine Datei wird dem Sprachmodell bereitgestellt..." |
| 35s | "Karteikarten werden generiert..." |
| 45s | "Einen Moment noch, die Karteikarten werden noch generiert..." |
| 50s | "Dein Stapel wird aktualisiert..." |
| 60s | "Einen Moment noch, gleich sind wir soweit..." |

**API Call**:
```
POST /stack/{stackId}/createFromFile
Content-Type: multipart/form-data
Body: FormData { file: File, custom-instructions: string }
Response: Success status (redirects to stack view)
```

---

## API Reference

### Base URL
```
https://api.smart-flashcards.com
```

### Authentication
All authenticated endpoints require:
```
Authorization: {token}
```

### Complete Endpoint List

| Method | Endpoint | Purpose | Auth | Request Body | Response |
|--------|----------|---------|------|--------------|----------|
| POST | `/signup` | User registration | No | `{name, mail, password}` | `{token, username}` |
| POST | `/login` | User login | No | `{mail, password}` | `{token, username}` |
| GET | `/stack` | Get all stacks | Yes | - | `Stack[]` |
| POST | `/stack` | Create stack | Yes | `{name, color}` | Success |
| GET | `/stack/{stackId}` | Get stack details | Yes | - | `Stack` |
| DELETE | `/stack/{stackId}` | Delete stack | Yes | - | Success |
| POST | `/card` | Create card | Yes | `{question, answer, stackId}` | Success |
| GET | `/stack/{stackId}/card/{cardId}` | Get card | Yes | - | `Card` |
| PUT | `/stack/{stackId}/card/{cardId}` | Update card | Yes | `{cardId, question, answer, stackId}` | Success |
| DELETE | `/stack/{stackId}/card/{cardId}` | Delete card | Yes | - | Success |
| GET | `/stack/{stackId}/card/next` | Get next due card | Yes | Query: `?days-ahead=N` | `Card` or 404 |
| POST | `/stack/rating` | Submit card rating | Yes | `{stackId, cardId, difficulty}` | Success |
| POST | `/stack/{stackId}/createFromFile` | AI generate cards | Yes | FormData: `{file, custom-instructions}` | Success |

---

## Data Models

### Stack
```typescript
interface Stack {
  id: bigint;
  uniqueId: string;        // UUID
  name: string;
  color: string;           // Hex color (e.g., "#059669")
  cards: Card[];
}
```

### Card
```typescript
interface Card {
  id: bigint;
  uniqueId: string;        // UUID
  question: string;        // Front of card
  answer: string;          // Back of card
  hint: string;            // Optional hint
  maturity: CardMaturity;  // Due date tracking
  difficultyAndDurations: DifficultyAndDuration[];
}
```

### CardMaturity
```typescript
interface CardMaturity {
  id: bigint;
  maturity: string;        // ISO8601 timestamp
  level: bigint;
}
```

### Difficulty
```typescript
interface Difficulty {
  id: bigint;
  name: string;            // e.g., "Easy", "Medium", "Hard"
  color: string;           // Hex color for button
}
```

### Duration
```typescript
interface Duration {
  displayName: string;     // e.g., "1 day", "3 days", "7 days"
}
```

### DifficultyAndDuration
```typescript
interface DifficultyAndDuration {
  difficulty: Difficulty;
  duration: Duration;
}
```

### CardRating (Request Body)
```typescript
interface CardRating {
  stackId: string;
  cardId: string;
  difficulty: bigint;      // Difficulty ID
}
```

### StackContext (Create Stack Request)
```typescript
interface StackContext {
  name: string;
  color: string;
}
```

### CardContext (Create/Update Card Request)
```typescript
interface CardContext {
  cardId: string;          // Empty for create, UUID for update
  question: string;
  answer: string;
  stackId: string;
}
```

---

## Design System

### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Emerald 600 | `#059669` | Primary buttons, links, focus rings |
| Emerald 500 | `#10B981` | Hover states |
| Yellow 600 | `#D97706` | AI/Magic button |
| Yellow 500 | `#F59E0B` | AI button hover |
| Green 600 | `#16A34A` | Success states |
| Green 100/50 | `#DCFCE7` | Success backgrounds |
| Red 800 | `#991B1B` | Error text |
| Red 50 | `#FEF2F2` | Error backgrounds |
| Gray 900 | `#111827` | Primary text |
| Gray 600 | `#4B5563` | Secondary text |
| Gray 400 | `#9CA3AF` | Placeholder text |
| Gray 300 | `#D1D5DB` | Borders |
| Gray 200 | `#E5E7EB` | Dividers |

### Typography Scale

| Size | Class | Usage |
|------|-------|-------|
| 6XL | `text-6xl` | Landing hero heading |
| 3XL | `text-3xl` | Major page titles |
| 2XL | `text-2xl` | Page titles |
| Base | `text-base` | Section headers |
| SM | `text-sm` | Body text, labels |
| XS | `text-xs` | Helper text |

### Button Styles

**Primary Button**:
```css
rounded-md bg-emerald-600 px-3 py-2 text-sm font-semibold text-white
shadow-sm hover:bg-emerald-500 focus-visible:outline focus-visible:outline-2
focus-visible:outline-offset-2 focus-visible:outline-emerald-600
```

**Secondary Button**:
```css
inline-flex items-center rounded-md bg-white px-3 py-2 text-sm
font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300
hover:bg-gray-50
```

**Link Button**:
```css
text-sm font-semibold leading-6 text-emerald-600 hover:text-emerald-500
```

### Input Field Style
```css
block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm
ring-1 ring-inset ring-gray-300 placeholder:text-gray-400
focus:ring-2 focus:ring-inset focus:ring-emerald-600 sm:text-sm sm:leading-6
```

### Card Component Style
```css
overflow-hidden bg-white sm:rounded-lg sm:shadow
```

### Responsive Breakpoints
- **Mobile**: Base styles (< 640px)
- **SM**: 640px+ (`sm:` prefix)
- **MD**: 768px+ (`md:` prefix)
- **LG**: 1024px+ (`lg:` prefix)

---

## User Flows

### Registration Flow
```
Landing Page → Click "Jetzt loslegen" → Registration Form → Fill name/email/password
→ Submit → API: POST /signup → Set cookies → Redirect to Dashboard
```

### Login Flow
```
Landing Page → Click "Anmelden" → Login Form → Fill email/password
→ Submit → API: POST /login → Set cookies → Redirect to Dashboard
```

### Create Stack Flow
```
Dashboard → Click "Erstellen" → Create Stack Form → Enter name, pick color
→ Submit → API: POST /stack → Redirect to Dashboard
```

### Create Card Flow
```
Dashboard → Click stack → Stack Detail → Click "Karte erstellen" → Card Form
→ Enter question/answer → Submit → API: POST /card → Success message
→ Option: View stack OR create another
```

### Learning Flow
```
Dashboard → Click stack → Stack Detail → Click "Jetzt lernen" → Learning Screen
→ See question → Tap to flip → See answer → Select difficulty → API: POST /stack/rating
→ Next card → Repeat until done → Completion modal → Back to Dashboard
```

### AI Generation Flow
```
Dashboard → Click stack → Stack Detail → Click "Automatisch erstellen" → Magic Page
→ (Optional) Enter custom instructions → Upload PDF → Submit → Loading modal with progress
→ API: POST /stack/{id}/createFromFile → Redirect to Stack Detail with new cards
```

---

## iOS Implementation Notes

### Navigation Pattern
- Use `UINavigationController` for stack-based navigation
- Tab bar not needed (single navigation hierarchy)
- Modal presentation for completion dialogs

### Authentication Storage
- Store JWT in Keychain (not UserDefaults)
- Store username in UserDefaults

### Card Flip Animation
- Use `UIView.transition(with:options:)` with `.transitionFlipFromRight`
- Or custom `CATransform3D` rotation

### File Upload
- Use `UIDocumentPickerViewController` for PDF selection
- Validate file type and size before upload

### Color Handling
- Dynamic colors from API for difficulty buttons
- Store stack colors as hex strings, convert to UIColor

### Localization
- All strings are in German
- Consider making strings localizable from the start

### Recommended iOS Architecture

```
SmartFlashcards/
├── App/
│   ├── SmartFlashcardsApp.swift
│   └── ContentView.swift
├── Models/
│   ├── Stack.swift
│   ├── Card.swift
│   ├── CardMaturity.swift
│   ├── Difficulty.swift
│   ├── Duration.swift
│   ├── DifficultyAndDuration.swift
│   ├── CardRating.swift
│   ├── StackContext.swift
│   └── CardContext.swift
├── Views/
│   ├── LandingView.swift
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── RegisterView.swift
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── Stack/
│   │   ├── CreateStackView.swift
│   │   ├── StackDetailView.swift
│   │   ├── CreateCardView.swift
│   │   └── EditCardView.swift
│   └── Learning/
│       ├── LearningView.swift
│       └── MagicView.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── DashboardViewModel.swift
│   ├── StackViewModel.swift
│   └── LearningViewModel.swift
├── Services/
│   ├── APIService.swift
│   ├── AuthService.swift
│   └── KeychainService.swift
├── Utilities/
│   ├── Color+Hex.swift
│   └── Constants.swift
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

### SwiftUI vs UIKit Recommendation
- **SwiftUI** recommended for modern iOS development
- Use `@StateObject` and `@ObservableObject` for view models
- Use `NavigationStack` (iOS 16+) or `NavigationView` for navigation
- Use `async/await` for API calls

---

*Document generated for iOS app recreation based on Smart Flashcards web application analysis.*
*Last updated: 2026-02-03*
