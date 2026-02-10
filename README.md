# MoodMoments (Meta Glasses Photo <> Mood MVP)

A tiny iOS MVP that helps you discover emotion patterns by:

- importing photos (e.g., Ray-Ban Meta glasses photos) from your iPhone Photo Library
- assigning an emotion score **1–5**
  - via **hourly notification buttons** (recommended)
  - optionally via **hand-gesture scoring** in the photo (best-effort)
- classifying the scene into categories (gym/home/office/etc.)
- rendering and saving an overlay image (category + score badge)
- viewing a **timeline** and **insights chart** (avg score per category)

This runs **fully on-device**: no backend, no external APIs.

## Features

- ✅ Import latest photo from Photos (best for glasses workflow)
- ✅ Pick photos manually via Photos Picker
- ✅ Scene classification (Vision)
- ✅ Optional hand pose scoring (Vision) to estimate 1–5 score
- ✅ Hourly prompts with actionable 1–5 buttons (UserNotifications)
- ✅ Overlay image rendering and local persistence
- ✅ Timeline + detail editing
- ✅ Insights chart (Swift Charts)

## Requirements

- Xcode 15+ (recommended)
- iOS 17+ (uses SwiftData)
- A physical iPhone (recommended for Photos/Vision behavior)

## Run locally on your iPhone (not simulator)

### 1. Clone

```bash
git clone https://github.com/<YOUR_USER>/<REPO>.git
cd <REPO>
open MoodMoments.xcodeproj
```

### 2. Configure signing

In Xcode:

Click the project (blue icon) → select the MoodMoments target
Go to Signing & Capabilities
Check Automatically manage signing
Select your Team (your Apple ID)
Update the Bundle Identifier to something unique, e.g.:
com.yourname.moodmoments.dev

### 3. Enable Developer Mode on iPhone (iOS 16+)

On iPhone:

Settings → Privacy & Security → Developer Mode → ON
Restart the phone when prompted.

### 4. Select your device & run

Connect iPhone via USB (first time)
In Xcode toolbar device selector, choose your iPhone under iOS Devices
Press Run (⌘R)

### 5. Trust the developer profile (if prompted)

On iPhone:

Settings → General → VPN & Device Management
Under Developer App, tap your Apple ID → Trust

If you see “Unverified app” issues:

delete the app from the phone
remove the developer profile in VPN & Device Management
reboot the phone
run again from Xcode

### 6. Permissions

The app requests:
Photos access (read) — to import images
Notifications — to schedule hourly prompts with 1–5 actions
If Photos permission is Limited, “Import Latest” may not see the most recent image.
Use “Pick Photos” once to add the latest photo to the allowed selection.

### 7. How the scoring works

Score priority when importing a photo:

If you recently tapped a notification score (1–5), that score is attached to the next imported photo (within ~10 minutes).
Otherwise, if “gesture scoring” is enabled, the app tries to detect a hand pose and estimate fingers up (beta).
Otherwise, you can manually set the score before saving.

### 8. Contributing

PRs and issues welcome. A few good first tasks:

Improve scene category mapping rules
Add more robust hand scoring / confidence reporting
Add “place clustering” (optional) using GPS (opt-in)
Add tests for mapping logic
