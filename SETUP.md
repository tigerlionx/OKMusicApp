# OK Music — Native App Setup Guide

App ID: `net.okmusic.app`  
Framework: Capacitor 8 (wraps the existing web app)

---

## 1. Firebase — Add Native Apps (5 min)

Go to **Firebase Console → ok-music-903e7 → Project Settings → Your Apps**

### Add Android App
1. Click **"Add app"** → Android
2. Package name: `net.okmusic.app`
3. App nickname: `OK Music Android`
4. SHA-1: run this to get your debug key fingerprint:
   ```
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
   ```
5. Download **`google-services.json`**
6. Place it at: `android/app/google-services.json`

### Add iOS App
1. Click **"Add app"** → Apple (iOS)
2. Bundle ID: `net.okmusic.app`
3. App nickname: `OK Music iOS`
4. Download **`GoogleService-Info.plist`**
5. Place it at: `ios/App/App/GoogleService-Info.plist`
6. Open `ios/App/App/Info.plist` and replace `REVERSED_CLIENT_ID_PLACEHOLDER`
   with the `REVERSED_CLIENT_ID` value from `GoogleService-Info.plist`
   (looks like: `com.googleusercontent.apps.72922695981-XXXX`)

---

## 2. Build the Android App

### Prerequisites (one-time)
```bash
# Install Java 17
brew install openjdk@17
echo 'export PATH="/usr/local/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Download Android Studio from https://developer.android.com/studio
# Open Android Studio → SDK Manager → Install Android SDK 34
```

### Open in Android Studio
```bash
cd /Users/emmanuelleveille/Claude/Projects/OKMusicApp
npx cap open android
```
Android Studio will open. Click **"Run"** (▶) to install on a connected device or emulator.

### Build a debug APK (without Android Studio)
```bash
cd android
./gradlew assembleDebug
# APK is at: android/app/build/outputs/apk/debug/app-debug.apk
```

### Build a release APK for Google Play
```bash
cd android
./gradlew assembleRelease
# Then sign with your keystore and upload the AAB to Google Play
```

---

## 3. Build and Test the iOS App on Your iPad

### Prerequisites (one-time)
1. **Install Xcode** from the Mac App Store (free, ~15 GB)
2. After install, accept the license: `sudo xcodebuild -license accept`
3. Install CocoaPods: `sudo gem install cocoapods`

### Open in Xcode
```bash
cd /Users/emmanuelleveille/Claude/Projects/OKMusicApp
npx cap open ios
```

Xcode opens `ios/App/App.xcodeproj`.

### Configure signing
1. In Xcode → click **"App"** in the project navigator
2. → **Signing & Capabilities** tab
3. Check **"Automatically manage signing"**
4. Team: select your Apple ID (add it via Xcode → Settings → Accounts)

> **Free Apple ID**: you can test on your own iPad for 7 days without a paid account.  
> **Apple Developer ($99/yr)**: required for TestFlight distribution and App Store.

### Run on your iPad
1. Connect your iPad via USB and trust the computer
2. In Xcode, select your iPad from the device dropdown
3. Click **Run** (▶)
4. First time: on iPad go to **Settings → General → VPN & Device Management → trust your developer account**

---

## 4. Google Sign-in Deep Link (iOS only)

For Google Sign-in to work after the redirect back to the app, iOS needs
to recognize the callback URL scheme. It's already in `Info.plist` as
`REVERSED_CLIENT_ID_PLACEHOLDER` — replace it with the real value from
`GoogleService-Info.plist`.

Also add `ok-music-903e7.firebaseapp.com` as an authorized domain in:
**Firebase Console → Authentication → Settings → Authorized domains**

---

## 5. Project Structure

```
OKMusicApp/
├── www/                    ← Web assets (copied from OK Music web app)
│   ├── index.html          ← Entry point (adapted for native)
│   ├── native-auth.js      ← Native Google Sign-in bridge
│   ├── community.js        ← Main app logic (unchanged)
│   └── ...                 ← All other JS/CSS/audio files
├── android/                ← Android native project (open in Android Studio)
│   └── app/src/main/
│       ├── assets/public/  ← Web assets copied here by cap sync
│       └── res/            ← Icons, splash screens, strings
├── ios/                    ← iOS native project (open in Xcode)
│   └── App/App/
│       ├── public/         ← Web assets copied here by cap sync
│       ├── Info.plist      ← iOS app config (add REVERSED_CLIENT_ID here)
│       └── Assets.xcassets/ ← App icons (all sizes generated)
├── capacitor.config.json   ← Capacitor configuration
└── package.json            ← npm dependencies
```

## 6. After Any Web Code Change

```bash
cd /Users/emmanuelleveille/Claude/Projects/OKMusicApp
# 1. Copy updated web files into www/
cp "/Users/emmanuelleveille/Claude/Projects/OK Music/publish/community.js" www/
# ... (other changed files)
# 2. Sync to native
npx cap sync
# 3. Rebuild / re-run in Android Studio or Xcode
```
