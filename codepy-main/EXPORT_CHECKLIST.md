# MathBlat Export & Deployment Guide

## Project Configuration

### Window Settings (800x600)
- ✅ Configured in `project.godot`
- Viewport: 800x600 pixels
- Stretch mode: canvas_levels with keep aspect ratio
- Works on desktop, tablet, and mobile orientations

### Rendering (Vulkan)
- ✅ Forward+ renderer enabled
- VRAM compression for ETC2/ASTC (mobile) and S3TC/BPTC (desktop)
- Proper texture streaming for lower-end devices

---

## Export Process by Platform

### 1. Windows Desktop

**Build Command:**
```bash
godot --headless --export-release "Windows Desktop" build/MathBlat.exe
```

**Testing Checklist:**
- [ ] Launch MathBlat.exe from build folder
- [ ] Main menu displays correctly (800x600 window)
- [ ] Single-player mode works with AI opponent
- [ ] Multiplayer: Host server on localhost:12345
- [ ] Multiplayer: Join localhost:12345 from another instance
- [ ] Score animation and visual effects play
- [ ] High scores save to user:// directory
- [ ] Pause menu (Esc key) functions correctly

**Distribution:**
- Distribute `MathBlat.exe` and any required DLLs
- Recommend placing in `C:\Program Files\MathBlat\` or similar

---

### 2. Linux/X11

**Build Command:**
```bash
godot --headless --export-release "Linux/X11" build/MathBlat.x86_64
```

**Testing Checklist:**
- [ ] Game runs on standard Linux desktop
- [ ] Window renders with Vulkan backend
- [ ] Network connectivity works (test multiplayer)
- [ ] High score saves to ~/.local/share/Godot/ (Linux user data)

**Distribution:**
- Distribute as AppImage or snap package
- Include in Linux game stores (itch.io, AUR, etc.)

---

### 3. macOS

**Build Command:**
```bash
godot --headless --export-release "macOS" build/MathBlat.dmg
```

**Prerequisites:**
- Apple Developer signing certificate
- Team ID configured in export preset
- Valid provisioning profile

**Testing Checklist:**
- [ ] .dmg mounts correctly
- [ ] App runs on Intel and Apple Silicon
- [ ] Notarization passes (if distribution through App Store)
- [ ] Multiplayer network connectivity works

**Distribution:**
- Submit to Mac App Store, or
- Distribute .dmg file directly

---

### 4. Android APK

**Build Prerequisites:**
```bash
# Install Android SDK/NDK via Android Studio or:
# Download NDK r25.1 (configured in export preset)
# Configure Android Studio path in Godot export settings
```

**Build Command:**
```bash
godot --headless --export-release "Android" build/MathBlat.apk
```

**Export Settings (Already Configured):**
- Package: `com.mathblat.game`
- Min SDK: 23 (Android 6.0)
- Target SDK: 33 (Android 13)
- Architectures: arm64-v8a, armeabi-v7a
- Permissions: INTERNET (for multiplayer)
- Screen: Portrait/Landscape orientation with immersive mode

**Device Testing Checklist:**
- [ ] Install APK: `adb install build/MathBlat.apk`
- [ ] Launch game on Android device (6.0+)
- [ ] Touch buttons respond correctly
- [ ] Math problems display and answer validation works
- [ ] Network connectivity: Test multiplayer from two devices
- [ ] Screen rotation: Verify game reorients properly
- [ ] High scores persist after app close/relaunch
- [ ] Battery: Monitor for excessive CPU usage (5-10% idle expected)

**Publishing:**
1. Generate keystore for signing:
```bash
keytool -genkey -v -keystore mathblat.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias mathblat
```

2. Configure signing in export preset:
   - `package/signature_keystore`: path to .keystore file
   - `package/signature_keystore_user`: alias name
   - `package/signature_keystore_password`: keystore password

3. Upload to Google Play Store

**Multiplayer Testing on Android:**
- Device A: Host server (port 12345)
- Device B: Join using Device A's IP address
- Verify sync: Scores update simultaneously on both devices

---

### 5. iOS/iPad

**Build Prerequisites:**
- Apple Developer account (€99/year)
- Xcode installed on macOS
- Development/Distribution certificates
- Provisioning profiles

**Build Command:**
```bash
godot --headless --export-release "iOS" build/MathBlat.ipa
```

**Export Settings (Already Configured):**
- Bundle ID: `com.mathblat.game`
- App Store Connect: Configure for TestFlight/App Store
- Supported architectures: arm64 (iPhone 6s+)
- Signing identity: Automatic or specific certificate

**Device Testing Checklist:**
- [ ] Compile and deploy to iPhone/iPad via Xcode
- [ ] App launches without crashing
- [ ] Touch interface responsive (buttons sized for 44pt minimum)
- [ ] Game logic works identically to Android
- [ ] Network multiplayer: Test two iOS devices
- [ ] High scores save to iOS app sandbox
- [ ] Performance: Monitor CPU/GPU in Xcode Instruments

**Distribution:**
1. Archive in Xcode
2. Validate and upload to App Store Connect
3. Submit for review (24-48 hours typical)

---

### 6. Web (HTML5)

**Build Command:**
```bash
godot --headless --export-release "Web (HTML5)" build/index.html
```

**Output Files:**
- `index.html` - Main game page
- `index.js` - Godot engine code
- `index.wasm` - WebAssembly binary
- `index.pck` - Game resources
- `.wasm.br` / `.pck.br` - Brotli-compressed versions

**Export Settings (Already Configured):**
- Progressive Web App (PWA) enabled
- VRAM compression: Desktop only
- Canvas resize policy: Maintain aspect ratio

**Hosting (Choose one):**

**Option A: itch.io (Recommended for indie games)**
```bash
# 1. Create project at itch.io
# 2. Upload build/ folder
# 3. Mark as "HTML"
# 4. Enable "This file will be played in the browser"
# 5. Share public URL
```

**Option B: Self-hosted server**
```bash
# Serve from any web server with proper headers:
cd build
python3 -m http.server 8000

# Visit: http://localhost:8000
```

**Option C: GitHub Pages**
```bash
git add build/
git commit -m "Build for web export"
git push origin main
# Enable GitHub Pages in repo settings → main/build directory
```

**Web Testing Checklist:**
- [ ] Load in Chrome/Firefox/Safari
- [ ] Game starts without CORS errors
- [ ] Touch controls work (mobile browser)
- [ ] Desktop controls work (mouse/keyboard)
- [ ] Audio plays (ensure browser allows)
- [ ] High scores: Check browser localStorage or IndexedDB
- [ ] Network: Multiplayer requires WebRTC relay (see Multiplayer Testing below)
- [ ] Performance: 60fps on desktop, 30fps on mobile expected
- [ ] Responsive: Test 800x600 on various screen sizes

**Browser Compatibility:**
- Chrome 90+
- Firefox 88+
- Safari 14+
- Mobile browsers (iOS Safari, Chrome Mobile)

---

## Multiplayer Testing Guide

### Local Testing (Single Machine)

**Single-player vs AI:**
- No network setup required
- Host and AI opponent play with hardcoded difficulty
- AI has 70% accuracy (by design)

**Local Multiplayer:**
```
1. Launch MathBlat twice
2. Instance A: Main Menu → Host → Select Difficulty
3. Instance B: Main Menu → Join → Enter "localhost" → Select Difficulty
4. Both load game_scene.tscn
5. Verify:
   - Problem displays on both screens
   - Answer from Player B syncs to Player A
   - Scores update simultaneously
   - Timer counts down in sync
```

### LAN Testing (Multiple Machines)

**Network Setup:**
```
Machine A (192.168.1.100):
  - Run MathBlat → Host → Difficulty: Easy
  - Note: Server listening on port 12345

Machine B (192.168.1.101):
  - Run MathBlat → Join → IP: 192.168.1.100 → Difficulty: Easy
  - Connects to 192.168.1.100:12345
```

**Find LAN IP:**
```bash
# Linux/macOS
ifconfig | grep "inet "

# Windows
ipconfig | findstr "IPv4 Address"
```

**Firewall Configuration:**
```bash
# Linux (if blocked)
sudo ufw allow 12345/tcp
sudo ufw allow 12345/udp

# Windows: Open port 12345 in Windows Defender Firewall
```

**Testing Checklist:**
- [ ] Connection established (check console for "peer_connected")
- [ ] Host generates first problem
- [ ] Client receives problem via RPC
- [ ] Both players answer independently
- [ ] Scores sync and update correctly
- [ ] Pause menu works on host (client sees pause)
- [ ] Victory screen triggers at 100 points on both sides
- [ ] Disconnect handling: Closing one client shows error dialog on other

### Internet Testing (Port Forwarding)

**Router Configuration:**
1. Log into router admin panel (typically 192.168.1.1)
2. Port Forwarding section:
   - External Port: 12345
   - Internal Port: 12345
   - Internal IP: 192.168.1.100 (host machine)
   - Protocol: TCP + UDP

3. Find public IP:
```bash
curl ifconfig.me  # Returns public IP (e.g., 203.0.113.45)
```

4. Remote player connects to: `203.0.113.45:12345`

**Limitations:**
- UPnP can auto-configure some routers
- Requires both players have public IPs
- NAT traversal issues may prevent connection
- **Recommended: Use relay service (see below)**

### Relay Service (ENet Relay)

**Why Use Relay:**
- Bypass NAT/firewall issues
- Works from any internet connection
- No manual port forwarding
- Minimal latency overhead

**Free Relay Services:**
1. **Godot Wild Jam Relay** (deprecated)
2. **Self-hosted using Netify or Nakama** (advanced)
3. **Playfab backend** (Microsoft cloud)

**Simple Relay Setup (for development):**
```bash
# Install simple ENet relay (example using Python)
# pip install python-socketio python-engineio

# Create relay server:
# See: https://github.com/eressea/relay (public domain example)

# Configure MathBlat to connect through relay:
# (Requires code modification - future enhancement)
```

**Current Recommendation:**
- Use LAN testing for initial multiplayer validation
- Port forwarding for trusted players on same network
- Plan relay service integration for public beta

---

## High Score System

### Data Storage

**Location:**
```
Windows: C:\Users\[User]\AppData\Roaming\Godot\app_userdata\mathblat_highscores.json
Linux: ~/.local/share/godot/app_userdata/mathblat_highscores.json
macOS: ~/Library/Application\ Support/Godot/app_userdata/mathblat_highscores.json
Web: Browser IndexedDB or localStorage
Android: /data/data/com.mathblat.game/files/mathblat_highscores.json
iOS: App sandbox Documents folder
```

**JSON Format:**
```json
[
  {"name":"Player1","score":1250,"difficulty":"Hard","date":"2024-01-15 14:32"},
  {"name":"Player2","score":980,"difficulty":"Medium","date":"2024-01-14 19:45"},
  {"name":"AI","score":750,"difficulty":"Easy","date":"2024-01-14 10:20"}
]
```

### Modifying High Scores

**In-Game (Victory Screen):**
1. Player reaches 100 points
2. Victory screen displays final score
3. Enter player name (default: "Player")
4. Press "Save Score"
5. Score saved to high_score_manager.gd

**Manual Reset:**
```gdscript
# In Godot console:
HighScoreManager.clear_high_scores()
```

**File Direct Edit (Windows):**
```
1. Close MathBlat
2. Open: C:\Users\[User]\AppData\Roaming\Godot\app_userdata\mathblat_highscores.json
3. Edit in Notepad++, ensure valid JSON
4. Save file
5. Relaunch MathBlat
```

---

## Build Automation

### GitHub Actions (CI/CD)

**Create `.github/workflows/godot-export.yml`:**
```yaml
name: Export MathBlat

on:
  push:
    tags:
      - 'v*'

jobs:
  export-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-dotnet@v1
        with:
          dotnet-version: '7.0'
      - name: Download Godot
        run: |
          wget https://github.com/godotengine/godot-builds/releases/download/4.5-stable/Godot_v4.5-stable_linux.x86_64.zip
          unzip Godot_v4.5-stable_linux.x86_64.zip
      - name: Export Web
        run: |
          ./Godot_v4.5-stable_linux.x86_64 --headless --export-release "Web (HTML5)" build/index.html
      - name: Upload Artifact
        uses: actions/upload-artifact@v2
        with:
          name: mathblat-web
          path: build/
```

---

## Troubleshooting

### Export Errors

**"OpenSSL error"**
- Issue: Missing TLS library
- Fix: Install openssl-dev package
```bash
sudo apt install libssl-dev  # Linux
```

**"Export preset not found"**
- Issue: export_presets.cfg corrupted or missing
- Fix: Regenerate export presets via Godot editor
```
Project → Export → [Choose Platform] → Create
```

**"Invalid package name" (Android)**
- Issue: Package name doesn't follow com.domain.app format
- Fix: Update in export_presets.cfg:
```
package/name="com.company.mathblat"
package/unique_name="com.company.mathblat"
```

### Runtime Issues

**High Score Not Saving**
- Check user:// directory has write permissions
- Verify HighScoreManager is in autoload
- Test: `print(ProjectSettings.globalize_path("user://"))`

**Multiplayer Not Connecting**
- Verify both machines on same network (ping test)
- Check port 12345 not blocked by firewall
- Ensure main_menu.gd RPC signals connected
- Test single-player first to isolate issue

**Audio Distortion on Mobile**
- Reduce sample rate in _create_ding_sound()
- Lower volume: multiply AudioStreamGenerator output by 0.7

**Canvas Resize Issues on Web**
- Verify canvas_resize_policy=2 in export_presets.cfg
- Test with --canvas-resize-policy 2 launch flag

---

## Performance Optimization

### Desktop Target
- 60 FPS expected
- Monitor CPU < 15% idle, < 25% gameplay

### Mobile Target (Android/iOS)
- 30 FPS acceptable for math puzzles
- GPU optimizations via VRAM compression
- Reduce particle count if performance < 30 FPS

### Web Target
- Chrome desktop: 60 FPS
- Mobile web: 30 FPS (WebGL performance limited)
- Optimize: Disable non-critical visual effects on mobile

**Profiling:**
```gdscript
# In game_scene.gd _process():
var fps = Engine.get_frames_drawn() % 60
if fps == 0:
    print("FPS: %d" % int(1.0 / delta))
```

---

## Version Control & Releases

### Git Tags for Releases
```bash
git tag -a v1.0.0 -m "Initial MathBlat release"
git push origin v1.0.0
```

### Release Notes Template
```
# MathBlat v1.0.0

## Features
- Local and network multiplayer
- 3 difficulty levels
- High score persistence
- Smooth Tween animations
- Procedural audio

## Platforms
- Windows/Linux/macOS
- Android 6.0+
- iOS 14.0+
- Web (HTML5)

## Known Issues
- None at release

## Downloads
- [Windows](link)
- [macOS](link)
- [Linux](link)
- [Android APK](link)
- [Web Browser](link)
```

---

## QA Checklist Before Release

- [ ] All scenes load without errors
- [ ] Single-player AI works (70% accuracy)
- [ ] Multiplayer: Host and join both functional
- [ ] Score validation: Correct answers +points, wrong answers +0
- [ ] Timer: 15 seconds per problem, accurate countdown
- [ ] Animations: Button hover (1.1x), score pop (elastic), screen shake (wrong)
- [ ] Audio: Ding (correct), buzz (wrong), no distortion
- [ ] Pause menu: Esc toggles, Resume/Quit buttons work
- [ ] Victory: Triggers at 100 points, high score saves
- [ ] High scores: Load after app restart
- [ ] Platform-specific:
  - [ ] Desktop: Window 800x600, Vulkan rendering
  - [ ] Mobile: Touch buttons responsive, rotation works
  - [ ] Web: Loads in Chrome, Firefox, Safari; audio plays
- [ ] Network stability: Test 5+ minute session
- [ ] Disconnection: Proper error handling on drop
- [ ] Localization: No hardcoded paths, user:// works everywhere

---

## Support & Feedback

For issues or feature requests:
- Report bugs on project issue tracker
- Test multiplayer on multiple networks
- Suggest relay service implementation
- Request platform-specific optimizations

**Happy deploying! 🚀**
