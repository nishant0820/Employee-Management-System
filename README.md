# Employee Management System (EMS)

A comprehensive, full-stack Employee Management System built with a scalable **Flutter** front-end and a secure **Node.js/Express** backend via **MongoDB**. 

The system provides robust HR capabilities with role-based dashboarding, persistent offline authentication, dynamic User Profiles, and custom Department layouts—tailored for Admins, Managers, and Employees.

## 🚀 Key Features

*   **Secure Authentication Pipeline**: End-to-end user registration and JWT-based authentication featuring `bcryptjs` password hashing and `shared_preferences` device encryption caching.
*   **Intuitive HR Dashboard**: View real-time aggregated metrics including Total Employees on staff, active attendance check-ins, Leave requests, and real-time portal statistics. 
*   **Dynamic Data Binding**: Deep bi-directional binding between User models and the Flutter UI natively serving Email Addresses, Phone Numbers, and organizational Department labels.
*   **Profile Administration**: Beautiful user-facing profile displays detailing secure Session Information, customizable Portal configuration wrappers, and one-tap secure Session Terminations.
*   **Agile Role/Department Assignment**: Built-in hierarchy and Department alignment (HR, Admin, Employee).
*   **Cross-Platform Architecture**: Compiles cleanly across Web, iOS, and Android thanks to standard material-3 design concepts embedded natively into Flutter.

---

## 🛠️ Technology Stack

### Frontend (Client)
*   **Framework**: Flutter (Dart)
*   **State Management**: `setState` with Stateful widgets
*   **Persistence**: `shared_preferences`
*   **Networking**: HTTP (`http` package for Dart)

### Backend (Server)
*   **Runtime**: Node.js
*   **Framework**: Express.js
*   **Database**: MongoDB
*   **ODM**: Mongoose 
*   **Security**: JSON Web Tokens (JWT) & bcryptjs

---

## ⚙️ Initial Setup & Installation

### Prerequisites
Before you begin, ensure you have the following installed locally:
1.  [Flutter SDK](https://docs.flutter.dev/get-started/install)
2.  [Node.js](https://nodejs.org/en/) & npm
3.  [MongoDB](https://www.mongodb.com/) (Local or Atlas URI)

### 1. Backend Server Setup
Navigate into the backend directory and download module dependencies:
```bash
cd backend
npm install
```

Create a `.env` file in the `backend/` root and provide your environment variables:
```env
PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_signing_key_here
```

Start the local API development node:
```bash
npm run dev
```

### 2. Frontend App Setup
Open a new terminal, navigate into your Flutter application, and pull the pub packages:
```bash
cd ems
flutter pub get
```

Start the application (on an emulator, connected device, or web wrapper):
```bash
flutter run
```

*(**Note:** Ensure your physical emulator configuration correctly targets your IPv4 or `10.0.2.2` backend endpoints).*

---

## 🔒 Security Posture

*   **Stateless Scaling**: The API generates timed session-based JWTs (`30d` expiry defaults) meaning servers seamlessly scale safely without clustered sessions. 
*   **No Plaintext Leaks**: All credentials passed natively from the `signup_screen` safely hit a mongoose `pre('save')` hook executing a rigorous 10-round `bcrypt.genSalt` function. 
*   **Absolute Session Destruction**: Flutter natively roots its active navigation navigator using `pushAndRemoveUntil()`, totally wiping local disk cache out on Logout ensuring no back-swipe exploits.

---

## 📂 Architecture Breakdown

### 📱 `ems/lib/screens/`
* `signup_screen.dart` / `login_screen.dart`: The core authentication gates. 
* `dashboard_screen.dart`: Securely lands authenticated valid tokens out of initial bootstrapping, pulling down dynamic metrics.
* `profile_screen.dart`: Deep-level secure view utilizing persistent session keys. Readies the schema out for configuration routing.
* `edit_profile_screen.dart`: Forms bridging database `phoneNumber`/`email` mutations via standard material form fields. 

### 🖥️ `backend/`
* `models/User.js`: Standard NO-SQL schemas mapping exact boundaries for properties like `fullName`, `phoneNumber`, `company`, etc.
* `controllers/authController.js`: Direct logic routing validating schemas synchronously against active Mongoose parameters before kicking responses down cleanly over Express wrappers. 
* `routes/`: Abstraction trees matching controllers to HTTP verbs.