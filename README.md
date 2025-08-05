# 📱 Inqrypt — Ultra-Private QR-Encrypted Notes App

**Inqrypt** is a fully offline app with hierarchical encryption, allowing users to create encrypted notes (with images) and store them as QR codes. The app uses biometric protection, supports localization, haptic feedback, and does not store any data in the cloud or on servers.

## 🎯 Core Mission & Principles

### Security Principles:
- **🔐 Hierarchical Encryption**: Master Key → Note Keys → Note Content + Images
- **📱 Biometric Protection**: Face ID / Touch ID to access master key
- **🚫 Fully Offline**: No network calls or cloud storage
- **🗑️ No History**: Notes are never stored in plain form
- **🔑 Unique Keys**: Each note has its own encryption key
- **🖼️ Encrypted Images**: Images are encrypted alongside text
- **🌍 Multilingual Support**: English and Russian supported
- **📳 Haptic Feedback**: UX improved with vibration response

### Security Architecture:
```
Master Key (M) ─▶ Encrypted Note Key (Kₙ) ─▶ Encrypted Note Content ─▶ Encrypted Images
      │                   │                        │                      │
      ▼                   ▼                        ▼                      ▼
Secure Storage       QR Code (Kₙ)         File System            File System
```

## 🧩 Features

| Feature | Status | Description |
|--------|--------|-------------|
| ✅ Create Notes | Done | Apple Notes-style editor with titles and content |
| ✅ Add Images | Done | Encrypted images from gallery/camera |
| ✅ Hierarchical Encryption | Done | M → Kₙ → Content + Images with [MAGIC]:: signature |
| ✅ Biometric Unlock | Done | Face ID / Touch ID unlock for Master Key |
| ✅ QR Code Generation | Done | Only encrypted Kₙ is in QR |
| ✅ QR Code Scanning | Done | Find note by decrypted Kₙ |
| ✅ Note Editing | Done | Edit and re-encrypt notes |
| ✅ Image Gallery | Done | Fullscreen viewing and deletion |
| ✅ Secure Storage | Done | `flutter_secure_storage` + filesystem |
| ✅ Note Deletion | Done | Biometrically protected mass delete |
| ✅ Share/Copy | Done | Share QR and content |
| ✅ Save QR to Gallery | Done | Export QR as image |
| ✅ Flutter Quill Editor | Done | Rich editor with images |
| ✅ Localization | Done | English and Russian |
| ✅ Vibration System | Done | Haptic UX for all actions |
| ✅ Navigation Feedback | Done | Vibrates on navigation |
| ✅ Notifications | Done | Vibrating notifications |
| ✅ Scan Animation | Done | Fast checkmark animation |
| ✅ Demo Mode | Done | Isolated App Store review mode |

## 🎭 Demo Mode

### Purpose:
Demo Mode exists to showcase full functionality without requiring biometric setup or encryption during App Store review.

### Flow Overview:
```
Main Screen ─▶ Demo Note ─▶ Mock QR Scanner ─▶ Demo View Page
```

### Key Elements:
- **Blue Demo Button** on main screen (replaces Security Status widget)
- **Pre-filled Editable Note** using QuillNoteEditor
- **Fake Encryption** using constant mock QR
- **Mock Scanner** with simulated animation
- **Demo View Page** mimicking real app UX
- **All localized**, full isolation from actual data

## 🔐 Encryption Architecture

### 1. Master Key (M)
- 32 bytes random
- Encrypted with biometric hash
- Stored via `flutter_secure_storage`
- Access via Face ID / Touch ID

### 2. Note Keys (Kₙ)
- 32 bytes per note
- AES-256-CBC encrypted using Master Key
- Stored in QR as: `base64(iv):base64(cipher)`

### 3. Note Content
- Begins with `[MAGIC]::`
- AES-256-CBC with Note Key
- Stored in device filesystem
- Quill Delta format for rich content

### 4. Images
- Compressed to max 1920x1920, JPEG/PNG
- Encrypted with Note Key (AES-256-CBC)
- Stored in encrypted folder
- Integrated into Quill via embeds

### 5. Encryption Flow
```
Create Note:
  Content + Images → [MAGIC]:: → Encrypt(Kₙ) → Encrypt(M) → Export QR

Scan QR:
  QR → Decrypt(M) → Decrypt(Kₙ) → Find note by signature → Decrypt images

Edit Note:
  Decrypt → Edit → Re-encrypt → Update note
```

## 💻 Tech Stack

| Component | Tech |
|----------|------|
| UI | Flutter 3.8+ |
| UI Theme | Material 3 (Dark) |
| Editor | Flutter Quill 11.4.2 |
| Encryption | `encrypt` 5.0.3 (AES-256-CBC) |
| Hashing | `crypto` 3.0.3 (SHA-256) |
| Secure Storage | `flutter_secure_storage` (Keychain/Keystore) |
| Biometric Auth | `local_auth` |
| QR Code | `mobile_scanner` |
| Image Picker | `image_picker` |
| Haptics | `vibration` |
| Localization | `flutter_localizations` |

## 🎨 UX Highlights

- **Apple Notes-style input** with auto-title from first line
- **Quill toolbar** above keyboard
- **Encrypted QR generation** at bottom right
- **Full gallery view** with swipe/zoom/delete
- **Fast animations**, haptic feedback, and smooth transitions

## 📊 Project Stats

- **Security Level**: HIGH
- **Encryption**: AES-256-CBC
- **Master Key Storage**: Secure + Biometric
- **Supported Platforms**: iOS
- **Languages**: English, Russian
- **Status**: Production-ready

## ☕ Support the Project

Inqrypt is free, open-source, and offline by design. If you value privacy-first tools, consider supporting development:

🔗 **[buymeacoffee.com/supportqlt](https://buymeacoffee.com/supportqlt)**

📫 **Contact**: support@inqrypt.com  
🌐 **Website**: [inqrypt.com](https://www.inqrypt.com/)

## 📄 License

This project is licensed under the **MIT License** — you're free to use, modify, and distribute it with proper attribution.
