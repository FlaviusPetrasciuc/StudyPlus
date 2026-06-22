# Study+ Setup and Running Instructions

## Technologies Used

Study+ is a mobile application developed using **Flutter** and **Dart**. The application uses **Supabase Cloud** as its backend service for authentication and data storage, and **Google Gemini AI** for generating project plans.

Development was carried out using **Android Studio**, and testing was performed using the **Pixel 5 Android Emulator**.

---

## Prerequisites

Before running the project, ensure the following software is installed:

* Flutter SDK
* Dart SDK
* Android Studio
* Node.js and npm
* A running Android Emulator (Pixel 5 recommended)
* Supabase project configuration
* Gemini API key

---

## Running the Flutter Application

### 1. Start the Android Emulator

Open Android Studio and launch the Pixel 5 emulator (or another Android device emulator).

### 2. Install Flutter Dependencies

Navigate to the root project directory and run:

```bash
flutter pub get
```

### 3. Run the Application

```bash
flutter run
```

The application will be built and launched on the running Android emulator.

---

## Running the Backend Server

### 1. Navigate to the Backend Directory

```bash
cd study_plus_backend
```

### 2. Install Backend Dependencies

```bash
npm install
```

### 3. Start the Backend Server

```bash
node server.js
```

You should see:

```text
Server running on port 3000
```

---

## Supabase Configuration

Study+ uses **Supabase Cloud** for:

* User Authentication
* Email Verification
* Project Storage
* Task Storage
* Team Collaboration Features

Before running the application, ensure that the Supabase project is configured correctly and that the required environment variables are provided.


---

## Gemini AI Configuration

The backend requires a Gemini API key to generate project plans.

Create a `.env` file inside the `study_plus_backend` directory:

```env
GEMINI_API_KEY=your_gemini_api_key
```

---

## Application Flow

1. Create a Study+ account.
2. Verify the email address using the verification code sent by Supabase.
3. Log in to the application.
4. Create a new project.
5. Generate an AI-powered 8-week project plan.
6. View project tasks in the calendar.
7. Invite team members using the generated invite code.
8. Collaborate on the same project plan.

```
```
