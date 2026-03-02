# Expense Tracker: Phase-wise Implementation Plan

This plan breaks down the development of the AI-powered expense tracker into logical phases, prioritizing the user flow and core functionality.

## End-to-End User Flow

```mermaid
graph TD
    A[App Launch] --> B{Authenticated?}
    B -- No --> C[Google Sign-In]
    C --> D[Request Permissions: Notifications/SMS]
    B -- Yes --> E[Dashboard]
    
    subgraph "Background Detection"
        F[Notification/SMS Received] --> G[Background Listener Captured]
        G --> H[LLM Parser API: Extract Amount, Merchant, Type, Category]
        H --> I[Auto-Categorization (Refined by LLM)]
        I --> J[Save to Firestore]
        J --> K[Local Notification to User]
    end
    
    E --> L[View Detected Transactions]
    L --> M[Manual Edit/Confirm]
    E --> N[View Charts & Stats]
    E --> O[Manual Transaction Entry]
    E --> P[Settings: Accounts, Currencies, Themes]
    
    K --> L
```

---

## Phase-wise Breakdown

### Phase 1: Design & Architecture (Current)
- Finalize Clean Architecture structure (Data, Domain, Presentation).
- Define Entity schemas for `Transaction`, `Account`, and `Category`.

### Phase 2: Setup & Authentication
- Initialize Flutter project with Riverpod.
- Configure Firebase (Android & iOS).
- Implement Google Sign-In flow.

### Phase 3: Core Engine (Notification Detection & LLM Parsing)
- Implement `NotificationListenerService` for Android.
- **LLM Integration**: Use an LLM API (e.g., Gemini Flash) with structured output (JSON schema) to parse messages into a defined `TransactionModel`.
- **Hybrid Parser**: Regex (for basic/fallback) + LLM (for complex merchant/context extraction).
- Implement background tasks for data extraction.

### Phase 4: Data & Processing
- Integrate Cloud Firestore for real-time synchronization.
- Implement categorization logic (e.g., matching merchant names to categories).
- Persistence layer for detected notifications to avoid duplicates.

### Phase 5: UI/UX (The "WOW" Factor)
- **Dashboard**: High-end visuals using gradients, glassmorphism, and `fl_chart`.
- **Transaction List**: Smooth scrolling list with daily/monthly grouping.
- **Settings Screen**: Manage accounts, default currencies, switch themes (Dark/Light), and user profile.
- **Forms**: Intuitive add/edit transaction screens.

### Phase 6: Verification & Refinement
- End-to-end testing with simulated bank notifications.
- Performance optimization for background services.
- Visual polish (micro-animations, haptic feedback).

---

## Verification Plan

### Automated
- **Unit Tests**: Parser logic tests with a suite of sample bank SMS/Notifications.
- **Domain Tests**: Test use cases for categorizing and saving transactions.

### Manual
- **Simulated Notification**: A debug menu to "Inject" a mock notification to test the listener and parser.
- **Profile Link**: Verify data persists across sign-ins.
