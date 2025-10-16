# SignSpace - Real-Time ASL Learning with Apple Vision Pro

![SignSpace Banner](https://img.shields.io/badge/visionOS-2.5-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![License](https://img.shields.io/badge/license-MIT-green)

**Learn American Sign Language with instant, personalized feedback using spatial computing.**

Built at **Good Vibes Only Buildathon 2025** | USC x PayPal x Lovable

---

## 🎯 The Problem

- **430 million people worldwide** need hearing support and rehabilitation  
- **500,000+ people** in the US use American Sign Language  
- Learning ASL is challenging without real-time, personalized feedback  
- Traditional methods (videos, books) lack interactive guidance  
- No way to verify if you're making signs correctly  

---

## 💡 Our Solution

**SignSpace** leverages Apple Vision Pro's advanced hand tracking to provide:

- ✅ **Real-time gesture recognition** – Detects ASL signs with 90Hz precision  
- ✅ **Ghost hands overlay** – Transparent “target” hands show correct position  
- ✅ **Specific, actionable feedback** – “Move your thumb closer to your palm” instead of generic errors  
- ✅ **Progress tracking** – Visual indicators showing mastery of each sign  
- ✅ **Spatial visualization** – 3D hand skeleton with joint-level accuracy  

---

## 🎥 Demo

> **[Insert Demo Video Link Here]**

### Key Features Showcased
1. Hand tracking initialization  
2. Learning letter "A" with instant feedback  
3. Ghost hands overlay guiding hand position  
4. Real-time corrections and validation  
5. Progress through 5 ASL signs  
6. Celebratory confetti on mastery  

---

## 🛠️ Technology Stack

### Core Technologies
- **visionOS 2.5** – Native Apple Vision Pro development  
- **Swift 5.9** – Modern, type-safe programming  
- **SwiftUI** – Declarative UI framework  
- **RealityKit** – 3D rendering and spatial computing  
- **Hand Tracking API** – 90Hz, 27-joint precision tracking  

### Key Features
- **Custom Gesture Recognition Engine** – Rule-based ASL sign detection  
- **Spatial Hand Visualization** – 3D skeleton rendering with joint connections  
- **Adaptive Feedback System** – Confidence-based color coding (red/yellow/green)  
- **Mock Data Support** – Simulator testing without physical hardware  

---

## 🏗️ Architecture

```markdown
## 🏗️ Project Structure

SignSpace/
├── SignSpaceApp.swift # App entry point
├── ContentView.swift # Main UI + hand visualization
├── HandTrackingManager.swift # Hand tracking abstraction (real + mock)
├── GestureRecognizer.swift # ASL gesture detection + feedback
├── GhostHandData.swift # Ideal hand positions for each sign
├── SoundManager.swift # Audio feedback system
└── AppModel.swift # App state management
```


---

## 🎨 Features

### 1. Real-Time Hand Tracking
- 90Hz update rate  
- 27 joint points per hand  
- Sub-millimeter accuracy  
- Works in any lighting condition  

### 2. Ghost Hands Overlay
- Semi-transparent green target hands  
- Shows exact correct position for each sign  
- Updates dynamically as you switch signs  
- User “traces” ghost hands to learn  

### 3. Intelligent Feedback System
- **Green (85%+)** – “Perfect! 🎉”  
- **Yellow (65–85%)** – “Almost there! Move thumb closer”  
- **Red (<65%)** – “Curl your index finger into your palm”  
- **Gray** – “Show your hand to the camera”  

### 4. 3D Skeleton Visualization
- Connects joints with lines  
- Blue for user’s hands  
- Green for target hands  
- Medical-grade rendering  

### 5. Progress Tracking
- Visual progress bar (0/5 → 5/5)  
- Tracks mastered signs  
- Confetti celebration  
- Per-sign confidence tracking  

### 6. Sound Effects
- Success tone (correct sign)  
- Progress tone (improving)  
- Error buzz (incorrect position)  
- Haptic feedback  

---

## 📚 Supported ASL Signs

Currently supports **5 foundational signs**:

| Sign | Description | Difficulty |
|------|--------------|-------------|
| **A** | Closed fist, thumb on side | Easy |
| **B** | Fingers straight up, thumb tucked | Medium |
| **C** | Hand forms “C” curve | Medium |
| **Hello** | Open hand, all fingers extended | Easy |
| **Thank You** | Flat hand, fingers together | Easy |

**Future:** Full alphabet (26 letters) + 50+ common phrases  

---

## 🚀 Getting Started

### Prerequisites
- macOS 14.0 or later  
- Xcode 15.0 or later  
- Apple Vision Pro  
- Apple Developer account  

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/SignSpace.git
   cd SignSpace
   ```
2. **Open in XCode**
   ```bash
   open SignSpace.xcodeproj
   ```
3. **Add Hand Tracking Capability**
- Project → Target → Signing & Capabilities
- Add “Hand Tracking”
4. **Build and Run**
- Select Apple Vision Pro simulator or device
- Press Cmd + R

## Testing Without Vision Pro
```swift
// In HandTrackingManager.swift (line 26)
var useMockData = true  // Simulator mode
```

For real device testing:
```swift
var useMockData = false // Vision Pro mode
```



