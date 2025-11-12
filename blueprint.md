# Project Blueprint

## Overview

This document outlines the design, features, and development plan for the Flutter journaling application. It serves as a single source of truth for the project's current state and future direction.

## Implemented Features

### Authentication

*   **Firebase Authentication:** The application uses Firebase Authentication to manage user sign-up, login, and session management.
*   **Email/Password Authentication:** Users can create an account and log in using their email and password.
*   **Authentication Gate:** The application has an authentication gate (`AuthGate`) that directs users to the appropriate screen (login or home) based on their authentication state.
*   **Login Page:** A dedicated login page (`LoginPage`) with email and password fields, a login button, and a link to the registration page. The UI has been redesigned to be more modern and user-friendly.
*   **Registration Page:** A registration page (`RegistrationPage`) for new users to create an account.
*   **Forgot Password:** Users can reset their password via a link sent to their email address. This is handled by a new `ForgotPasswordPage` and the `sendPasswordResetEmail` method in `AuthService`.
*   **Loading Indicators:** The login and registration pages now display a loading indicator during the authentication process to provide better user feedback.
*   **Optimized Registration:** The user creation process is now faster as it no longer waits for the initial user data to be written to the initial user data to be written to the Realtime Database.

### Firestore

*   **Cloud Firestore:** The application uses Cloud Firestore to store and retrieve journal entries in real-time.
*   **Data Structure:** Journal entries are stored in a `journals` collection, with each user's entries organized in a subcollection named `entries` under a document identified by their unique user ID.
*   **Security Rules:** The database is secured with rules that only allow authenticated users to read and write their own journal entries.

### Features

*   **Weather Page (`WeatherPage`):** A dedicated page to display the current weather conditions for a searched city. It includes a search bar, the current temperature, a weather icon, and additional details like humidity, wind speed, and pressure. The page uses the OpenWeatherMap API to fetch the weather data.

### User Interface

*   **Main Interface (`HomePage`):** A new dashboard-style home screen that greets the user and provides navigation to different app features like "Weather" and "Diary". It also includes a "SPECIAL FOR YOU" section with Bible quotes.
*   **Journal Page (`JournalPage`):** The screen where users can view, add, edit, and delete their journal entries. The UI has been redesigned to match the user-provided image, featuring a cleaner layout, a floating action button for adding entries, and restyled entry cards.
*   **Expanded Journal View:** When a user taps on a journal entry, it expands into a detailed view, showing the full content of the entry. This view also has a back button and an edit button.
*   **Journal Entry Dialog:** A dialog for adding and editing journal entries with separate fields for title and content.
*   **Journal List:** A list of all journal entries, displayed in descending chronological order.
*   **Confirmation Dialog:** A confirmation dialog is now displayed before deleting a journal entry to prevent accidental data loss.
*   **Styling:** The application uses the `google_fonts` package for custom typography and a consistent color scheme based on Material Design principles.

## Current Plan

### Implemented: Weather Feature

*   **Objective:** To allow users to check the weather for a specific city.
*   **Steps:**
    1.  **`http` Package:** Added the `http` package to the `pubspec.yaml` file to make API requests.
    2.  **`WeatherPage` Creation:** Created a new `lib/weather_page.dart` file with a stateful widget to manage the weather data.
    3.  **API Integration:** Integrated the OpenWeatherMap API to fetch weather data using the provided API key.
    4.  **UI Implementation:** Designed a user interface with a search bar and a card to display the weather information.
    5.  **Routing:** Added a new `/weather` route in `lib/main.dart` and updated the `HomePage` to navigate to it.

### Implemented: Expanded Journal Entry View

*   **Objective:** To allow users to view the full content of a journal entry by tapping on it.
*   **Steps:**
    1.  **`JournalBody` as `StatefulWidget`:** Converted `JournalBody` to a `StatefulWidget` to manage the selected entry's state.
    2.  **`_JournalDetailView`:** Created a new `_JournalDetailView` widget to display the expanded entry, including the full text, a back button, and an edit button.
    3.  **`AnimatedSwitcher`:** Implemented an `AnimatedSwitcher` to provide a smooth fade transition between the journal list and the detailed view.
    4.  **Navigation:** Tapping a `_JournalListItem` now updates the state to show the `_JournalDetailView`, and the back button reverts the state.

### Implemented: Redesigned Journal Page UI

*   **Objective:** To update the journal page with a new, modern UI based on the user-provided image.
*   **Steps:**
    1.  **Layout:** The `JournalPage` has been redesigned with a new header, a floating action button for adding entries, and restyled cards for each journal entry.
    2.  **Add/Edit Dialog:** The `_showJournalEntryDialog` now handles both adding and editing entries, with separate fields for the title and content.
    3.  **Delete Confirmation:** A confirmation dialog is now displayed before deleting a journal entry to prevent accidental data loss.

### Implemented: New Main Interface

*   **Objective:** To create a central navigation hub for the application as per the user's design.
*   **Steps:**
    1.  **File Renaming:** Renamed the existing `lib/home_page.dart` to `lib/journal_page.dart`.
    2.  **New Home Page Creation:** Created a new `lib/home_page.dart` to serve as the main interface, featuring a dashboard layout.
    3.  **Routing Updates:** Updated `lib/main.dart` to include a new `/journal` route pointing to `JournalPage` and ensured the `/home` route directs to the new `HomePage`.
    4.  **Navigation:** The "Diary" card on the new `HomePage` now navigates to the `/journal` route.

### Implemented: Redesigned Forgot Password Page UI

*   **Objective:** To create a modern and visually appealing "Forgot Password" screen based on the user-provided design.
*   **Key Changes:**
    *   **Layout:** Adopted a centered, single-column layout for a clean and focused user experience.
    *   **Title and Subtitle:** Added a prominent "FORGOT PASSWORD" title and a descriptive subtitle.
    *   **Text Field:** The email field has been updated to include a prefix icon (`email_outlined`) and an underline border.
    *   **Button:** The "RESET" button is now a full-width `ElevatedButton` with a light blue background color and rounded corners.
    *   **Navigation:** Added a "Back to Sign In" `TextButton` to allow users to easily return to the login page.
    *   **Error Handling:** Kept the improved error handling to provide clear feedback to the user.

### Implemented: Forgot Password Functionality

*   **Objective:** To allow users to reset their password if they have forgotten it.
*   **Steps:**
    1.  **`AuthService` Update:** Added a `sendPasswordResetEmail` method to `lib/auth_service.dart` that uses `FirebaseAuth.instance.sendPasswordResetEmail`.
    2.  **`ForgotPasswordPage` Creation:** Created a new page (`lib/forgot_password_page.dart`) with a form for the user to enter their email address.
    3.  **Routing:** Added a new route for `/forgot-password` in `lib/main.dart` to navigate to the `ForgotPasswordPage`.
    4.  **UI Connection:** Linked the "Forgot Password?" button on the `LoginPage` to the new `/forgot-password` route.

### Implemented: Redesigned Login Page UI

*   **Objective:** To create a modern and visually appealing login screen based on the user-provided design.
*   **Key Changes:**
    *   **Layout:** Adopted a centered, single-column layout for a clean and focused user experience.
    *   **Title:** Added a prominent "SIGN IN" title with a large, bold font.
    *   **Text Fields:** The email and password fields have been updated to include prefix icons (`person_outline` and `lock_outline`) and an underline border for a more polished look.
    *   **Buttons:** 
        *   The "Register Here" link is now a `TextButton` aligned to the right.
        *   The "LOGIN" button has been transformed into a full-width `ElevatedButton` with a vibrant blue background color and rounded corners.
        *   A "Forgot Password?" `TextButton` has been added at the bottom.
    *   **Spacing:** Increased the spacing between UI elements to improve readability and visual balance.
    *   **AppBar Removal:** The `AppBar` has been removed to create a more immersive and focused login screen.

### Implemented: Optimize Registration Speed

*   **Objective:** To reduce the perceived latency during new user registration.
*   **Action:**
    *   Modified the `createUserWithEmailAndPassword` method in `lib/auth_service.dart`.
    *   Removed the `await` from the Realtime Database `set` operation (`_rtdb.child('users').child(user.uid).set(...)`).
    *   This allows the app to proceed to the home screen immediately after Firebase Authentication is successful, while the database write happens in the background.

### Implemented: Add Loading Indicators to Authentication

*   **Objective:** To provide visual feedback to the user during the login and registration processes.
*   **Steps:**
    1.  **Add `_isLoading` state:** Introduced a boolean `_isLoading` to manage the visibility of the loading indicator.
    2.  **Show `CircularProgressIndicator`:** Conditionally display a `CircularProgressIndicator` when `_isLoading` is true.
    3.  **Update State:** Set `_isLoading` to `true` before the asynchronous authentication call and to `false` after it completes (in a `finally` block to handle both success and failure cases).
    4.  **Apply to both Login and Registration:** Implemented this logic on both `lib/login_page.dart` and `lib/registration_page.dart`.
