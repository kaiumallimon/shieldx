![Logo](assets/images/2.png)


# ShieldX - Flutter Client

ShieldX is a secure and scalable cross-platform password manager mobile application built with **Flutter** and **Firebase**. It allows users to store, manage, and retrieve their passwords with strong authentication and encryption.

## Features

- **User Authentication**: Secure sign-up and login using Firebase Authentication.
- **Password Management**: Store, edit, retrieve, and delete saved passwords.
- **Data Encryption**: AES encryption to keep passwords secure.
- **Biometric Authentication**: Unlock the app using fingerprint or Face ID.
- **Cross-Platform Support**: Works on both **Android** and **iOS**.
- **Cloud Sync**: Automatic sync across devices using Firebase Firestore.
- **Password Generator**: Generate strong passwords within the app. [Coming soon...]

## Tech Stack

- **Flutter** (Dart)
- **Firebase Authentication** (User management)
- **Cloud Firestore** (Database)
- **AES Encryption** (Secure password storage)
- **Provider / Riverpod** (State management)

## Project Structure

```bash
Will be updated
```

## Installation & Setup

### Prerequisites

- Install [Flutter](https://flutter.dev/) & set up the environment.
- Configure Firebase for your Flutter app.
- Enable Firebase Authentication & Firestore Database.

### 1. Clone the repository

```bash
git clone https://github.com/kaiumallimon/shieldx.git
cd shieldx
```

### 2. Install dependencies

```bash
flutter pub get
```
### 3. Run the app

```bash
flutter run
```

## API Endpoints

ShieldX interacts with the **ShieldX Server API** to manage authentication and passwords.

Example API Calls:

- **User Registration:** `POST /api/auth/register`
- **User Login:** `POST /api/auth/login`
- **Fetch Passwords:** `GET /api/password/all/:userId`
- **Store Password:** `POST /api/password/store`

Refer to the [ShieldX Server README](https://github.com/kaiumallimon/shieldx-server) for full API details.

## Screenshots

Coming soon...

## Contributing

Contributions are welcome! Please **fork** the repository and submit a **pull request** for improvements.

## License

This project is licensed under the **MIT License**.

## Author

[Kaium Al Limon](https://www.facebook.com/lemon.exee)



