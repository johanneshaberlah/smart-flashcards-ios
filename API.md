# Smart Flashcards API - Comprehensive iOS Client Development Guide

> **Purpose:** This document provides complete API documentation for building an iOS client for the Smart Flashcards API. It includes all endpoints, data models, authentication flows, and implementation details.

---

## Table of Contents
1. [API Overview](#1-api-overview)
2. [Backend Codebase Structure](#2-backend-codebase-structure)
3. [Authentication](#3-authentication)
4. [Data Models](#4-data-models)
5. [API Endpoints](#5-api-endpoints)
6. [Spaced Repetition Algorithm](#6-spaced-repetition-algorithm)
7. [Error Handling](#7-error-handling)
8. [iOS Implementation Guidelines](#8-ios-implementation-guidelines)

---

## 1. API Overview

### Base Configuration
| Property | Value |
|----------|-------|
| **Base URL** | `http://localhost:3001` |
| **Content-Type** | `application/json` |
| **Authentication** | JWT Bearer Token |
| **CORS** | Enabled for all origins |

### Core Features
- **Flashcard Management:** Create, read, update, delete flashcards organized in stacks (decks)
- **Spaced Repetition Learning:** SM-2 inspired algorithm with 3 difficulty levels
- **AI-Powered Card Generation:** Upload PDFs to auto-generate flashcards via OpenAI
- **AI Hints:** Automatic hint generation for learning assistance

### Technology Stack (Backend)
- **Framework:** Spring Boot 3.2.5
- **Language:** Java 17
- **Database:** MySQL 8.0
- **ORM:** Hibernate/JPA
- **Authentication:** JWT (jjwt, java-jwt)
- **Password Hashing:** BCrypt
- **API Docs:** OpenAPI/Swagger (SpringDoc)
- **AI Integration:** OpenAI Assistant API

---

## 2. Backend Codebase Structure

### Project Directory Layout

```
src/main/java/org/iu/flashcards/api/
├── SmartFlashcardsApiApplication.java       (Main Spring Boot app)
├── login/                                    (Authentication & User Management)
│   ├── User.java
│   ├── LoginController.java
│   ├── LoginService.java
│   ├── LoginResult.java
│   ├── LoginRequestCredentials.java
│   ├── RegistrationModel.java
│   ├── UserComponent.java
│   ├── UserRepository.java
│   ├── TokenValidator.java
│   ├── AuthorizationFilter.java
│   ├── AuthorizationFilterConfiguration.java
│   └── LoginFailedException.java
├── stack/                                    (Flashcard Stacks)
│   ├── Stack.java
│   ├── StackUser.java
│   ├── StackContext.java
│   ├── StackController.java
│   ├── StackService.java
│   ├── StackRepository.java
│   ├── StackUserRepository.java
│   ├── StackNotFoundException.java
│   └── assistant/                            (AI Assistant Integration)
│       ├── AssistantController.java
│       ├── AssistantService.java
│       ├── AssistantConfiguration.java
│       ├── AssistantCredentials.java
│       ├── card/
│       │   ├── CardResponse.java
│       │   └── AssistantCardFactory.java
│       ├── file/
│       │   ├── File.java
│       │   └── FileUploadService.java
│       ├── message/
│       │   ├── Message.java
│       │   ├── MessageResponse.java
│       │   ├── MessageContent.java
│       │   ├── MessageText.java
│       │   └── MessageFactory.java
│       ├── run/
│       │   ├── Run.java
│       │   └── RunFactory.java
│       └── thread/
│           ├── Thread.java
│           └── ThreadFactory.java
├── card/                                     (Flashcard Management)
│   ├── Card.java
│   ├── CardMaturity.java
│   ├── CardContext.java
│   ├── CardController.java
│   ├── CardService.java
│   ├── CardRepository.java
│   ├── CardMaturityRepository.java
│   └── CardNotFoundException.java
├── learning/                                 (Learning/Study Management)
│   ├── LearningController.java
│   ├── LearningService.java
│   ├── CardRatingContext.java
│   └── CardDifficulty.java
└── common/                                   (Shared Utilities)
    ├── ApiError.java
    ├── Difficulty.java
    ├── DifficultyAndDuration.java
    ├── Duration.java
    ├── InternalControllerAdvice.java
    └── WebConfig.java
```

### Key Backend Components

#### Entity Relationships
```
User (1) ──────< StackUser >────── (1) Stack
                    │
                    │ (1)
                    ▼
              CardMaturity
                    ▲
                    │ (1)
                    │
Card (1) ──────────┘
  │
  └── belongs to Stack (many-to-one)
```

#### Database Configuration
- **Database Name:** `flashcards`
- **DDL Strategy:** `update` (auto-creates/updates schema)
- **Environment Variables:**
  - `SPRING_DATASOURCE_URL`
  - `SPRING_DATASOURCE_USERNAME`
  - `SPRING_DATASOURCE_PASSWORD`

#### AI/Assistant Configuration
- `OPEN_AI_KEY`: OpenAI API key
- `OPEN_AI_ASSISTANT`: Assistant ID for card generation
- `OPEN_AI_HINT_MACHINE`: Assistant ID for hint generation

---

## 3. Authentication

### 3.1 Overview
- **Type:** Stateless JWT authentication
- **Token Lifetime:** 7 days (604,800,000 milliseconds)
- **Algorithm:** HMAC256
- **No refresh token** - users must re-login after expiration

### 3.2 Login Flow

**Endpoint:** `POST /login`

**Request:**
```json
{
  "mail": "user@example.com",
  "password": "userpassword"
}
```

**Response (200 OK):**
```json
{
  "username": "John Doe",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Response (400 Bad Request):**
```json
{
  "message": "USER_NOT_FOUND"
}
```
or
```json
{
  "message": "WRONG_PASSWORD"
}
```

### 3.3 Registration Flow

**Endpoint:** `POST /signup`

**Request:**
```json
{
  "name": "John Doe",
  "mail": "user@example.com",
  "password": "userpassword"
}
```

**Validation Rules:**
- `name`: Minimum 2 characters, non-blank
- `mail`: Minimum 2 characters, non-blank, must be unique
- `password`: Minimum 2 characters, non-blank

**Response (200 OK):**
```json
{
  "username": "John Doe",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Response (400 Bad Request):**
```json
{
  "message": "USER_ALREADY_EXISTS"
}
```

### 3.4 Using the Token

Include the JWT token in the `Authorization` header for all protected endpoints:

```
Authorization: <JWT_TOKEN>
```

**Note:** No "Bearer" prefix is used - send the raw token.

### 3.5 Token Expiration

When a token expires, the API returns:
- **Status:** 401 Unauthorized
- **Response:** `{"message": "The token is expired"}`

iOS app should detect this and redirect to login screen.

---

## 4. Data Models

### 4.1 User
```swift
struct User {
    let id: Int64
    let uniqueId: String      // UUID - primary identifier for API calls
    let name: String
    let mail: String
    // password is never returned in API responses
}
```

**Backend Entity Fields:**
- `id`: Long (auto-generated)
- `uniqueId`: String (UUID)
- `name`: String
- `mail`: String
- `password`: String (BCrypt hashed)
- `stackUsers`: List<StackUser> (EAGER fetch)

### 4.2 Stack (Flashcard Deck)
```swift
struct Stack: Codable {
    let id: Int64
    let uniqueId: String      // UUID - use this for API calls
    let name: String
    let color: String         // Hex color code, e.g., "#FF5733"
    let cards: [Card]
}
```

**Backend Entity Fields:**
- `id`: Long (auto-generated)
- `uniqueId`: String (UUID)
- `name`: String
- `color`: String (hex)
- `stackUsers`: Set<StackUser> (EAGER, cascade ALL, orphan removal)
- `cards`: Set<Card> (EAGER, cascade ALL, orphan removal)

### 4.3 Card (Flashcard)
```swift
struct Card: Codable {
    let id: Int64
    let uniqueId: String                          // UUID - use this for API calls
    let question: String
    let answer: String
    let hint: String?                             // Optional, AI-generated
    let difficultyAndDurations: [DifficultyDuration]
    let maturity: CardMaturity?
}
```

**Backend Entity Fields:**
- `id`: Long (auto-generated)
- `uniqueId`: String (UUID)
- `question`: String
- `answer`: String
- `hint`: String (TEXT column, nullable)
- `stack`: Stack (many-to-one)
- `cardMaturities`: Set<CardMaturity> (EAGER, cascade ALL, orphan removal)
- `difficultyAndDurations`: List<DifficultyAndDuration> (transient - calculated)
- `maturity`: CardMaturity (transient - derived from cardMaturities)

### 4.4 CardMaturity (Learning Progress)
```swift
struct CardMaturity: Codable {
    let id: Int64
    let maturity: String      // ISO 8601 timestamp - next review date
    let level: Int            // 0-10 mastery level
}
```

**Backend Entity Fields:**
- `id`: Long (auto-generated)
- `maturity`: Instant (timestamp)
- `level`: int (0-10)
- `stackUser`: StackUser (many-to-one)
- `card`: Card (many-to-one)

### 4.5 DifficultyDuration (Review Options)
```swift
struct DifficultyDuration: Codable {
    let difficulty: Difficulty
    let duration: Duration
}

struct Difficulty: Codable {
    let id: Int
    let name: String          // "Einfach" (Easy), "Mittel" (Medium), "Schwer" (Hard)
    let color: String         // Hex color code
}

struct Duration: Codable {
    let amount: Int
    let unit: String          // "MINUTES", "HOURS", "DAYS", "SECONDS"
}
```

### 4.6 Difficulty Enum Values
| ID | Name (German) | Name (English) | Color |
|----|---------------|----------------|-------|
| 0 | Einfach | Easy | #22C55E (green) |
| 1 | Mittel | Medium | #F97316 (orange) |
| 2 | Schwer | Hard | #EF4444 (red) |

### 4.7 StackUser (Join Entity)
**Backend Entity (not directly exposed in API):**
- `id`: Long (auto-generated)
- `user`: User (many-to-one)
- `stack`: Stack (many-to-one)
- `cardMaturities`: Set<CardMaturity> (EAGER)

---

## 5. API Endpoints

### 5.1 Stack Management

#### Create Stack
**`POST /stack`**

**Request:**
```json
{
  "name": "Biology 101",
  "color": "#22C55E"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "uniqueId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Biology 101",
  "color": "#22C55E",
  "cards": []
}
```

---

#### List All Stacks
**`GET /stack`**

Returns all stacks owned by the authenticated user with all their cards.

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "uniqueId": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Biology 101",
    "color": "#22C55E",
    "cards": [
      {
        "id": 1,
        "uniqueId": "card-uuid-here",
        "question": "What is photosynthesis?",
        "answer": "The process by which plants convert light energy...",
        "hint": "Think about what plants need to grow",
        "difficultyAndDurations": [],
        "maturity": {
          "id": 1,
          "maturity": "2025-02-03T10:30:00.000Z",
          "level": 3
        }
      }
    ]
  }
]
```

---

#### Get Single Stack
**`GET /stack/{stackId}`**

**Path Parameters:**
- `stackId` (String): Stack's uniqueId (UUID)

**Response (200 OK):** Same as single stack object above

**Error (404 Not Found):**
```json
{
  "message": "Stack not found"
}
```

---

#### Delete Stack
**`DELETE /stack/{stackId}`**

**Path Parameters:**
- `stackId` (String): Stack's uniqueId (UUID)

**Response (200 OK):** Empty body

**Error (404 Not Found):**
```json
{
  "message": "Stack not found"
}
```

---

### 5.2 Card Management

#### Create Card
**`POST /card`**

**Request:**
```json
{
  "stackId": "stack-uuid-here",
  "cardId": null,
  "question": "What is the powerhouse of the cell?",
  "answer": "The mitochondria"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "uniqueId": "card-uuid-here",
  "question": "What is the powerhouse of the cell?",
  "answer": "The mitochondria",
  "hint": null,
  "difficultyAndDurations": [],
  "maturity": null
}
```

---

#### Get Single Card
**`GET /stack/{stackId}/card/{cardId}`**

**Path Parameters:**
- `stackId` (String): Stack's uniqueId
- `cardId` (String): Card's uniqueId

**Response (200 OK):** Full card object with difficultyAndDurations and maturity

**Errors:**
- 404: `{"message": "Stack not found"}` or `{"message": "Card not found"}`

---

#### Update Card
**`PUT /stack/{stackId}/card/{cardId}`**

**Path Parameters:**
- `stackId` (String): Stack's uniqueId
- `cardId` (String): Card's uniqueId

**Request:**
```json
{
  "stackId": "stack-uuid-here",
  "cardId": "card-uuid-here",
  "question": "Updated question text",
  "answer": "Updated answer text"
}
```

**Response (200 OK):** Updated card object

---

#### Delete Card
**`DELETE /stack/{stackId}/card/{cardId}`**

**Path Parameters:**
- `stackId` (String): Stack's uniqueId
- `cardId` (String): Card's uniqueId

**Request Body (required):**
```json
{
  "stackId": "stack-uuid-here",
  "cardId": "card-uuid-here",
  "question": "Card question",
  "answer": "Card answer"
}
```

**Response (200 OK):** Empty body

---

### 5.3 Learning System

#### Get Next Card to Study
**`GET /stack/{stackId}/card/next`**

This is the core endpoint for the learning flow. Returns the next card due for review.

**Path Parameters:**
- `stackId` (String): Stack's uniqueId

**Query Parameters:**
- `days-ahead` (Integer, optional, default: 0): Look ahead N days for cards

**Response (200 OK):**
```json
{
  "id": 1,
  "uniqueId": "card-uuid-here",
  "question": "What is photosynthesis?",
  "answer": "The process by which plants convert light energy into chemical energy",
  "hint": "Think about what happens in the leaves when sunlight hits them",
  "difficultyAndDurations": [
    {
      "difficulty": {
        "id": 0,
        "name": "Einfach",
        "color": "#22C55E"
      },
      "duration": {
        "amount": 2,
        "unit": "DAYS"
      }
    },
    {
      "difficulty": {
        "id": 1,
        "name": "Mittel",
        "color": "#F97316"
      },
      "duration": {
        "amount": 30,
        "unit": "MINUTES"
      }
    },
    {
      "difficulty": {
        "id": 2,
        "name": "Schwer",
        "color": "#EF4444"
      },
      "duration": {
        "amount": 2,
        "unit": "MINUTES"
      }
    }
  ],
  "maturity": {
    "id": 1,
    "maturity": "2025-02-03T10:30:00.000Z",
    "level": 3
  }
}
```

**Error (400 Bad Request):**
```json
{
  "message": "Card not found"
}
```
(This means no cards are due for review)

---

#### Submit Card Rating
**`POST /stack/rating`**

After the user reviews a card, submit their difficulty rating to update the spaced repetition schedule.

**Request:**
```json
{
  "stackId": "stack-uuid-here",
  "cardId": "card-uuid-here",
  "difficulty": 0
}
```

**Difficulty Values:**
| Value | Meaning | Effect on Schedule |
|-------|---------|-------------------|
| 0 | EASY | Increases level, longer interval |
| 1 | MEDIUM | Maintains level, medium interval |
| 2 | HARD | Decreases level, short interval |

**Response (200 OK):** Empty body

---

### 5.4 AI Card Generation

#### Generate Cards from PDF
**`POST /stack/{stackId}/createFromFile`**

Upload a PDF file to automatically generate flashcards using AI.

**Path Parameters:**
- `stackId` (String): Stack's uniqueId

**Request Type:** `multipart/form-data`

**Form Fields:**
- `file` (File): PDF file (max 10MB)
- `custom-instructions` (String): Additional instructions for AI

**Example cURL:**
```bash
curl -X POST \
  -H "Authorization: <token>" \
  -F "file=@lecture_notes.pdf" \
  -F "custom-instructions=Focus on chapter 3 definitions" \
  http://localhost:3001/stack/uuid-here/createFromFile
```

**Response (200 OK):** Empty body

**Important Notes:**
- Processing is **asynchronous** - cards appear gradually
- AI generates hints automatically (scheduled task runs every 2 minutes)
- Poll `GET /stack/{stackId}` to see newly created cards

---

## 6. Spaced Repetition Algorithm

### 6.1 How It Works

The API implements a spaced repetition system similar to SM-2:

1. **New cards** start at level 0
2. **User rates difficulty** after reviewing (Easy/Medium/Hard)
3. **Level adjusts** based on rating:
   - EASY: Level increases by 1 (max 10)
   - MEDIUM: Level stays the same
   - HARD: Level decreases (halved if > 4, otherwise -1, min 0)
4. **Next review time** calculated from difficulty intervals

### 6.2 Interval Schedules

**EASY Difficulty Intervals:**
| Level | Interval |
|-------|----------|
| 0 | 10 minutes |
| 1 | 1 hour |
| 2 | 6 hours |
| 3 | 12 hours |
| 4 | 2 days |
| 5 | 4 days |
| 6 | 7 days |
| 7 | 14 days |
| 8+ | 30 days |

**MEDIUM Difficulty Intervals:**
| Level | Interval |
|-------|----------|
| 0 | 2 minutes |
| 1 | 5 minutes |
| 2 | 10 minutes |
| 3 | 30 minutes |
| 4 | 45 minutes |
| 5 | 1 hour |
| 6+ | 2 hours |

**HARD Difficulty Intervals:**
| Level | Interval |
|-------|----------|
| 0 | 1 minute |
| 1 | 1 minute |
| 2 | 2 minutes |
| 3+ | 10 minutes |

### 6.3 Level Adjustment Logic

```java
// From CardDifficulty.java
public int applyOnLevel(int currentLevel) {
    return switch (this) {
        case EASY -> Math.min(currentLevel + 1, 10);
        case MEDIUM -> currentLevel;
        case HARD -> currentLevel > 4
            ? currentLevel / 2
            : Math.max(currentLevel - 1, 0);
    };
}
```

### 6.4 Learning Session Flow

```
1. iOS App: GET /stack/{id}/card/next
2. API returns card with difficulty options + durations
3. User sees question, thinks of answer
4. User reveals answer
5. User taps difficulty button (Easy/Medium/Hard)
6. iOS App: POST /stack/rating with difficulty
7. Repeat from step 1 until no cards due
```

---

## 7. Error Handling

### 7.1 HTTP Status Codes

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Request successful |
| 400 | Bad Request | Invalid input, login failure, resource not found (learning) |
| 401 | Unauthorized | Missing/invalid/expired token |
| 404 | Not Found | Stack or card doesn't exist |
| 500 | Internal Server Error | Server error |

### 7.2 Error Response Format

All errors return JSON:
```json
{
  "message": "Error description here"
}
```

### 7.3 Common Error Messages

| Message | Cause |
|---------|-------|
| `USER_NOT_FOUND` | Email not registered |
| `WRONG_PASSWORD` | Incorrect password |
| `USER_ALREADY_EXISTS` | Email already registered |
| `The token is expired` | JWT expired (7+ days old) |
| `Stack not found` | Invalid stack UUID |
| `Card not found` | Invalid card UUID or no cards due |

### 7.4 Backend Exception Handling

The API uses `@ControllerAdvice` for centralized exception handling:

```java
// InternalControllerAdvice.java
@ExceptionHandler(StackNotFoundException.class)
public ResponseEntity<ApiError> stackNotFound(StackNotFoundException exception) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND)
        .body(new ApiError("Stack not found"));
}

@ExceptionHandler(CardNotFoundException.class)
public ResponseEntity<ApiError> cardNotFound(CardNotFoundException exception) {
    return ResponseEntity.status(HttpStatus.BAD_REQUEST)
        .body(new ApiError("Card not found"));
}

@ExceptionHandler(LoginFailedException.class)
public ResponseEntity<ApiError> loginFailed(LoginFailedException exception) {
    return ResponseEntity.status(HttpStatus.BAD_REQUEST)
        .body(new ApiError(exception.getMessage()));
}
```

---

## 8. iOS Implementation Guidelines

### 8.1 Network Layer Setup

```swift
// Base configuration
let baseURL = "http://localhost:3001"
var authToken: String?

// Request helper
func makeRequest(
    endpoint: String,
    method: String,
    body: Data? = nil
) -> URLRequest {
    var request = URLRequest(url: URL(string: baseURL + endpoint)!)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    if let token = authToken {
        request.setValue(token, forHTTPHeaderField: "Authorization")
    }

    request.httpBody = body
    return request
}
```

### 8.2 Authentication State Management

```swift
class AuthManager {
    static let shared = AuthManager()

    var token: String? {
        didSet {
            // Store in Keychain for persistence
            KeychainHelper.save(token, for: "auth_token")
        }
    }

    var isLoggedIn: Bool {
        return token != nil
    }

    func logout() {
        token = nil
        // Navigate to login screen
    }

    func handleUnauthorized() {
        // Token expired - clear and redirect to login
        logout()
    }
}
```

### 8.3 UUID Usage

**Critical:** Always use `uniqueId` (UUID strings) for API calls, not numeric `id` fields.

```swift
// Correct
let endpoint = "/stack/\(stack.uniqueId)/card/\(card.uniqueId)"

// Incorrect - don't use numeric IDs
let endpoint = "/stack/\(stack.id)/card/\(card.id)"
```

### 8.4 Color Parsing

Stacks have hex color codes. Parse them for UIColor:

```swift
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: 1
        )
    }
}

// Usage
let stackColor = UIColor(hex: stack.color)
```

### 8.5 Learning UI Flow

Recommended UI states for card review:

```
┌─────────────────────┐
│  Question Display   │
│                     │
│  "What is...?"      │
│                     │
│  [Show Answer]      │
└─────────────────────┘
         ↓ tap
┌─────────────────────┐
│  Question + Answer  │
│                     │
│  Answer: "..."      │
│  Hint: "..."        │
│                     │
│ [Easy]  [Med]  [Hard]│
│  2d     30m     2m   │
└─────────────────────┘
         ↓ rate
┌─────────────────────┐
│  Next Card...       │
└─────────────────────┘
```

### 8.6 Handling "No Cards Due"

When `GET /stack/{id}/card/next` returns 400 with "Card not found":

```swift
func getNextCard(stackId: String) async throws -> Card? {
    do {
        let card = try await api.fetchNextCard(stackId: stackId)
        return card
    } catch APIError.notFound(let message) where message == "Card not found" {
        // No cards due - show "All caught up!" message
        return nil
    }
}
```

### 8.7 Date Handling

The `maturity` field is an ISO 8601 timestamp:

```swift
let dateFormatter = ISO8601DateFormatter()
dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

if let maturityString = card.maturity?.maturity,
   let date = dateFormatter.date(from: maturityString) {
    // Card is due if date <= now
    let isDue = date <= Date()
}
```

### 8.8 File Upload for AI Generation

```swift
func uploadPDF(stackId: String, fileURL: URL, instructions: String) async throws {
    let boundary = UUID().uuidString
    var request = URLRequest(url: URL(string: "\(baseURL)/stack/\(stackId)/createFromFile")!)
    request.httpMethod = "POST"
    request.setValue(authToken, forHTTPHeaderField: "Authorization")
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()

    // Add file
    let fileData = try Data(contentsOf: fileURL)
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
    body.append(fileData)
    body.append("\r\n".data(using: .utf8)!)

    // Add instructions
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"custom-instructions\"\r\n\r\n".data(using: .utf8)!)
    body.append(instructions.data(using: .utf8)!)
    body.append("\r\n".data(using: .utf8)!)
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = body

    let (_, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw APIError.uploadFailed
    }
}
```

### 8.9 Recommended App Structure

```
SmartFlashcards/
├── Models/
│   ├── User.swift
│   ├── Stack.swift
│   ├── Card.swift
│   ├── CardMaturity.swift
│   └── DifficultyDuration.swift
├── Services/
│   ├── APIService.swift
│   ├── AuthManager.swift
│   └── KeychainHelper.swift
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── SignupView.swift
│   ├── Stacks/
│   │   ├── StackListView.swift
│   │   ├── StackDetailView.swift
│   │   └── CreateStackView.swift
│   ├── Cards/
│   │   ├── CardListView.swift
│   │   ├── CardDetailView.swift
│   │   └── CreateCardView.swift
│   └── Learning/
│       ├── LearningSessionView.swift
│       ├── CardReviewView.swift
│       └── SessionCompleteView.swift
└── ViewModels/
    ├── AuthViewModel.swift
    ├── StackViewModel.swift
    └── LearningViewModel.swift
```

### 8.10 Complete Swift Model Definitions

```swift
// MARK: - Login Models

struct LoginRequest: Codable {
    let mail: String
    let password: String
}

struct SignupRequest: Codable {
    let name: String
    let mail: String
    let password: String
}

struct LoginResult: Codable {
    let username: String
    let token: String
}

// MARK: - Stack Models

struct Stack: Codable, Identifiable {
    let id: Int64
    let uniqueId: String
    let name: String
    let color: String
    let cards: [Card]
}

struct StackContext: Codable {
    let name: String
    let color: String
}

// MARK: - Card Models

struct Card: Codable, Identifiable {
    let id: Int64
    let uniqueId: String
    let question: String
    let answer: String
    let hint: String?
    let difficultyAndDurations: [DifficultyAndDuration]
    let maturity: CardMaturity?
}

struct CardContext: Codable {
    let stackId: String
    let cardId: String?
    let question: String
    let answer: String
}

struct CardMaturity: Codable {
    let id: Int64
    let maturity: String  // ISO 8601 timestamp
    let level: Int
}

// MARK: - Difficulty Models

struct DifficultyAndDuration: Codable {
    let difficulty: Difficulty
    let duration: Duration
}

struct Difficulty: Codable {
    let id: Int
    let name: String
    let color: String
}

struct Duration: Codable {
    let amount: Int
    let unit: String  // "MINUTES", "HOURS", "DAYS", "SECONDS"
}

// MARK: - Rating Models

struct CardRatingContext: Codable {
    let stackId: String
    let cardId: String
    let difficulty: Int  // 0 = EASY, 1 = MEDIUM, 2 = HARD
}

// MARK: - Error Models

struct APIError: Codable {
    let message: String
}
```

### 8.11 API Service Implementation

```swift
import Foundation

enum NetworkError: Error {
    case invalidURL
    case unauthorized
    case notFound(String)
    case badRequest(String)
    case serverError
    case decodingError
    case uploadFailed
}

class APIService {
    static let shared = APIService()

    private let baseURL = "http://localhost:3001"
    private var token: String?

    private init() {}

    func setToken(_ token: String?) {
        self.token = token
    }

    // MARK: - Authentication

    func login(email: String, password: String) async throws -> LoginResult {
        let request = LoginRequest(mail: email, password: password)
        return try await post("/login", body: request, authenticated: false)
    }

    func signup(name: String, email: String, password: String) async throws -> LoginResult {
        let request = SignupRequest(name: name, mail: email, password: password)
        return try await post("/signup", body: request, authenticated: false)
    }

    // MARK: - Stacks

    func getStacks() async throws -> [Stack] {
        return try await get("/stack")
    }

    func getStack(id: String) async throws -> Stack {
        return try await get("/stack/\(id)")
    }

    func createStack(name: String, color: String) async throws -> Stack {
        let context = StackContext(name: name, color: color)
        return try await post("/stack", body: context)
    }

    func deleteStack(id: String) async throws {
        try await delete("/stack/\(id)")
    }

    // MARK: - Cards

    func createCard(stackId: String, question: String, answer: String) async throws -> Card {
        let context = CardContext(stackId: stackId, cardId: nil, question: question, answer: answer)
        return try await post("/card", body: context)
    }

    func getCard(stackId: String, cardId: String) async throws -> Card {
        return try await get("/stack/\(stackId)/card/\(cardId)")
    }

    func updateCard(stackId: String, cardId: String, question: String, answer: String) async throws -> Card {
        let context = CardContext(stackId: stackId, cardId: cardId, question: question, answer: answer)
        return try await put("/stack/\(stackId)/card/\(cardId)", body: context)
    }

    func deleteCard(stackId: String, cardId: String, question: String, answer: String) async throws {
        let context = CardContext(stackId: stackId, cardId: cardId, question: question, answer: answer)
        try await deleteWithBody("/stack/\(stackId)/card/\(cardId)", body: context)
    }

    // MARK: - Learning

    func getNextCard(stackId: String, daysAhead: Int = 0) async throws -> Card {
        var endpoint = "/stack/\(stackId)/card/next"
        if daysAhead > 0 {
            endpoint += "?days-ahead=\(daysAhead)"
        }
        return try await get(endpoint)
    }

    func submitRating(stackId: String, cardId: String, difficulty: Int) async throws {
        let context = CardRatingContext(stackId: stackId, cardId: cardId, difficulty: difficulty)
        try await postNoResponse("/stack/rating", body: context)
    }

    // MARK: - File Upload

    func uploadPDF(stackId: String, fileURL: URL, instructions: String) async throws {
        // Implementation shown in section 8.8
    }

    // MARK: - Private Helpers

    private func get<T: Decodable>(_ endpoint: String) async throws -> T {
        let request = makeRequest(endpoint: endpoint, method: "GET")
        return try await execute(request)
    }

    private func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B, authenticated: Bool = true) async throws -> T {
        var request = makeRequest(endpoint: endpoint, method: "POST", authenticated: authenticated)
        request.httpBody = try JSONEncoder().encode(body)
        return try await execute(request)
    }

    private func postNoResponse<B: Encodable>(_ endpoint: String, body: B) async throws {
        var request = makeRequest(endpoint: endpoint, method: "POST")
        request.httpBody = try JSONEncoder().encode(body)
        let (_, response) = try await URLSession.shared.data(for: request)
        try handleResponse(response)
    }

    private func put<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        var request = makeRequest(endpoint: endpoint, method: "PUT")
        request.httpBody = try JSONEncoder().encode(body)
        return try await execute(request)
    }

    private func delete(_ endpoint: String) async throws {
        let request = makeRequest(endpoint: endpoint, method: "DELETE")
        let (_, response) = try await URLSession.shared.data(for: request)
        try handleResponse(response)
    }

    private func deleteWithBody<B: Encodable>(_ endpoint: String, body: B) async throws {
        var request = makeRequest(endpoint: endpoint, method: "DELETE")
        request.httpBody = try JSONEncoder().encode(body)
        let (_, response) = try await URLSession.shared.data(for: request)
        try handleResponse(response)
    }

    private func makeRequest(endpoint: String, method: String, authenticated: Bool = true) -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL + endpoint)!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if authenticated, let token = token {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(response, data: data)

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    private func handleResponse(_ response: URLResponse, data: Data? = nil) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 404:
            if let data = data,
               let error = try? JSONDecoder().decode(APIError.self, from: data) {
                throw NetworkError.notFound(error.message)
            }
            throw NetworkError.notFound("Not found")
        case 400:
            if let data = data,
               let error = try? JSONDecoder().decode(APIError.self, from: data) {
                throw NetworkError.badRequest(error.message)
            }
            throw NetworkError.badRequest("Bad request")
        default:
            throw NetworkError.serverError
        }
    }
}
```

---

## Quick Reference - All Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/signup` | No | Register new user |
| POST | `/login` | No | Login user |
| GET | `/stack` | Yes | List all stacks |
| POST | `/stack` | Yes | Create stack |
| GET | `/stack/{id}` | Yes | Get stack details |
| DELETE | `/stack/{id}` | Yes | Delete stack |
| POST | `/card` | Yes | Create card |
| GET | `/stack/{id}/card/{cardId}` | Yes | Get card |
| PUT | `/stack/{id}/card/{cardId}` | Yes | Update card |
| DELETE | `/stack/{id}/card/{cardId}` | Yes | Delete card |
| GET | `/stack/{id}/card/next` | Yes | Get next card to study |
| POST | `/stack/rating` | Yes | Submit difficulty rating |
| POST | `/stack/{id}/createFromFile` | Yes | Generate cards from PDF |

---

## Backend Source File Locations

| Component | Path |
|-----------|------|
| Main Application | `src/main/java/org/iu/flashcards/api/SmartFlashcardsApiApplication.java` |
| User Entity | `src/main/java/org/iu/flashcards/api/login/User.java` |
| Stack Entity | `src/main/java/org/iu/flashcards/api/stack/Stack.java` |
| Card Entity | `src/main/java/org/iu/flashcards/api/card/Card.java` |
| CardMaturity Entity | `src/main/java/org/iu/flashcards/api/card/CardMaturity.java` |
| Login Controller | `src/main/java/org/iu/flashcards/api/login/LoginController.java` |
| Stack Controller | `src/main/java/org/iu/flashcards/api/stack/StackController.java` |
| Card Controller | `src/main/java/org/iu/flashcards/api/card/CardController.java` |
| Learning Controller | `src/main/java/org/iu/flashcards/api/learning/LearningController.java` |
| Assistant Controller | `src/main/java/org/iu/flashcards/api/stack/assistant/AssistantController.java` |
| CardDifficulty Enum | `src/main/java/org/iu/flashcards/api/learning/CardDifficulty.java` |
| Application Config | `src/main/resources/application.properties` |
| Build Config | `build.gradle` |
| Docker Config | `docker-compose.yaml` |

---

*Document generated for iOS client development. All UUIDs should be used for API calls, not numeric IDs.*
