# SignSpace - Real-Time ASL Learning with Apple Vision Pro

![SignSpace Banner](https://img.shields.io/badge/visionOS-2.5-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![License](https://img.shields.io/badge/license-MIT-green)

**Learn American Sign Language with instant, personalized feedback using spatial computing.**

Built at USC's **Good Vibes Only Buildathon 2025** | a16z x PayPal x Lovable x META x Apple

## 🎯 The Problem

- **430 million people worldwide** need hearing support and rehabilitation  
- **500,000+ people** in the US use American Sign Language  
- Learning ASL is challenging without real-time, personalized feedback  
- Traditional methods (videos, books) lack interactive guidance  
- No way to verify if you're making signs correctly  

## 💡 Our Solution

**SignSpace** leverages Apple Vision Pro's advanced hand tracking to provide:

- **Real-time gesture recognition** – Detects ASL signs using ML-based classification  
- **Specific, actionable feedback** – “Move your thumb closer to your palm” instead of generic errors  
- **Progress tracking** – Visual indicators showing mastery of each sign  
- **Spatial visualization** – 3D hand skeleton with joint-level accuracy
- **Ghost hands overlay (Unused for now)** – Transparent “target” hands show the correct position (will be expanded upon in the next update) 

## 🎥 Demo

> **[Demo Video Link Here](https://drive.google.com/file/d/1XPNRzenzS-k5-pO7UJ3PRrQrqJHE6at7/view?usp=sharing)**

### Key Features Showcased
1. Hand tracking initialization  
2. Learning letter "A" with instant feedback  
3. Real-time corrections and validation  
4. Progress through 5 ASL signs  
5. Celebratory confetti on mastery  

## 🛠️ Technology Stack

### Core Technologies
- **visionOS 2.5** – Native Apple Vision Pro development  
- **Swift 5.9** – Modern, type-safe programming  
- **SwiftUI** – Declarative UI framework  
- **RealityKit** – 3D rendering and spatial computing  
- **Hand Tracking API** – Real-time 27-joint precision tracking  
- **Core ML** – Integrated ASL gesture classifier  

### Key Features
- **Rule-Based + ML Gesture Recognition Engine** – Combines CoreML model with rule-based validation  
- **Spatial Hand Visualization** – 3D skeleton rendering with joint connections  
- **Adaptive Feedback System** – Confidence-based color coding (red/yellow/green)  
- **CSV Export + Share Sheet** – Export recorded samples for model retraining  
- **Mock Data Support** – Simulator testing without physical hardware  

## 🏗️ Architecture
```
SignSpace/
├── SignSpaceApp.swift # App entry point + immersive space setup
├── AppModel.swift # App state management
├── ContentView.swift # Main learning UI + feedback logic
├── ConfettiView.swift # Confetti animation when sign mastered
├── DataCollectionView.swift # Data collection & CSV export interface
├── CSVExporter.swift # Session data tracking & CSV writer
├── GestureRecognizer.swift # Rule-based ASL gesture recognition
├── MLGestureRecognizer.swift # CoreML-based gesture prediction
├── GhostHandData.swift # Ideal hand joint positions per sign 
├── HandTrackingManager.swift # ARKit session + real-time hand tracking
├── HandTrackingComponent.swift # RealityKit component for hand entities
├── HandTrackingSystem.swift # System managing ARKit anchor updates
├── HandTrackingView.swift # 3D hand entity rendering view
├── ImmersiveView.swift # RealityView for immersive mode
├── SoundManager.swift # Audio feedback for success/errors
├── ToggleImmersiveSpaceButton.swift # Button to toggle immersive view
└── Assets/ # ASL sign images + app assets
```

### Data Flow
```
Vision Pro Hand Tracking
        ↓
HandTrackingManager (extracts 27 joints)
        ↓
MLGestureRecognizer + GestureRecognizer (classifies + validates)
        ↓
ContentView (shows confidence, feedback, confetti)
        ↓
User sees real-time corrections + progress tracking
```


## 🎨 Features

### 1. **Real-Time Hand Tracking**
- Powered by `ARKitSession` and `HandTrackingProvider`
- 27 tracked joints with live position updates
- Works seamlessly in immersive space

### 2. **Ghost Hands Overlay**
- Shows ideal ASL hand positions (from `GhostHandData`)
- Used for reference and spatial guidance  

### 3. **Dual Recognition System**
- **Rule-based:** geometry & distances between joints  
- **ML-powered:** CoreML model trained from real CSV data  

### 4. **Intelligent Feedback**
- **Green (≥85%)**: Perfect! 🎉  
- **Yellow (65–85%)**: Almost there!  
- **Red (<65%)**: Needs correction  
- **Gray**: No hand detected  

### 5. **Progress Tracking & Celebration**
- Tracks completed signs  
- Displays progress bar  
- Confetti on completion  

### 6. **Sound Feedback**
- Success tone (correct)  
- Progress tone (improving)  
- Error tone (incorrect)  

### 7. **Data Collection & Export**
- Record hand samples for each sign  
- Export labeled CSV for training CoreML models  
- Share sheet for direct file sharing  

## 📚 Supported ASL Signs

| Sign | Description | Difficulty |
|------|-------------|-------------|
| **A** | Closed fist, thumb on side | Easy |
| **B** | Fingers straight up, thumb tucked | Medium |
| **C** | Hand forms "C" curve | Easy |
| **Hello** | Open hand, all fingers extended | Easy |
| **Thank You** | Flat hand, fingers together (custom sign for testing) | Medium |

**Future:** Expand to full alphabet and 50+ phrases  

## 🚀 Getting Started

### Prerequisites
- macOS 14.0 or later  
- Xcode 15.0 or later  
- Apple Vision Pro (for real testing)  
- Apple Developer account  

### Installation
1. **Install repo**
```bash
git clone https://github.com/yourusername/SignSpace.git
cd SignSpace
open SignSpace.xcodeproj
```

2. **Open in Xcode**
```bash
   open SignSpace.xcodeproj
```

3. **Add Hand Tracking Capability**
   - Select SignSpace project → Target → Signing & Capabilities
   - Click "+ Capability"
   - Add "Hand Tracking"

4. **Build and Run**
   - Select "Apple Vision Pro" simulator or physical device
   - Press `Cmd + R`

### Testing Without Vision Pro

The app includes **mock hand tracking** for simulator testing:
```swift
// In HandTrackingManager.swift (line 26)
var useMockData = true  // Simulator mode with animated hands
```

For real device testing:
```swift
var useMockData = false  // Real Vision Pro hand tracking
```

## 🎓 How It Works

### Hand Tracking Pipeline

1. **Initialize Session**
   - Requests `handTracking` authorization from ARKit.
   - Starts `ARKitSession` with `HandTrackingProvider`.
   - Continuously processes anchor updates at 90Hz for both hands.

2. **Extract Joint Data**
   - Captures 27 joints per hand: wrist, thumb, index, middle, ring, and pinky.
   - Converts joint transforms to world coordinates using `originFromAnchorTransform`.
   - Stores as `SIMD3<Float>` for spatial calculations.

3. **Gesture Recognition**
   - Two engines work in parallel:
     - **Rule-based**: Uses distances and angles between joints for precision feedback.
     - **ML-powered**: CoreML model (`ASLClassifierReal1.mlmodel`) predicts gestures from 12 extracted features (6 joints × 2D coordinates).
   - Combines both methods for accurate and interpretable recognition.

4. **Generate Feedback**
   - Calculates a confidence score (0–1).
   - Produces contextual feedback:
     - “Perfect!” if confidence > 0.9  
     - “Good try!” if 0.6–0.9  
     - “Show your hand” if tracking is lost
   - Feedback color dynamically updates (green/yellow/red/gray).

5. **Render Visualization**
   - `RealityView` displays real-time 3D hand skeletons.
   - `GhostHandData` overlays “ideal” hand position for the current sign.
   - Visual and audio cues provide instant correction guidance.

6. **Track Progress**
   - `ContentView` maintains user progress via `signsLearned` state.
   - Confetti and success sound trigger on first mastery.
   - Progress indicators fill based on completed signs.

7. **Data Collection Mode**
   - Switch to `DataCollectionView` for ML training.
   - Captures hand features for each ASL sign and saves them as CSV.
   - Built-in `ShareSheet` enables exporting data directly.

## 🏆 Technical Highlights

### Why This Showcases Vision Pro
- **Native Hand Tracking:** Uses Vision Pro’s most advanced capability without external hardware, being privacy-preserving (processed locally).  
- **Spatial Feedback Loop:** Ghost hands are anchored in 3D space, enabling natural alignment.  
- **Real-Time Performance:** 90Hz input rate with <10ms latency feedback pipeline.  
- **On-Device ML:** All gesture processing is performed locally using CoreML for privacy and speed.  
- **Immersive Accessibility-First Learning:** Users learn through kinesthetic feedback rather than static visuals, making ASL learning accessible to all.  

## 🔮 Future Roadmap

## 🔮 Future Roadmap

### Phase 1 (MVP – Completed)
- [x] Vision Pro hand tracking integration  
- [x] CoreML gesture recognition (5 signs)  
- [x] Visual and audio feedback system  
- [x] Confetti + progress tracking  
- [x] CSV export for model retraining  

### Phase 2 (Next 3 Months)
- [ ] Full ASL alphabet coverage  
- [ ] Improved CoreML accuracy with larger dataset 
- [ ] Lesson-based user flow  
- [ ] Advanced analytics dashboard  

### Phase 3 (6 Months)
- [ ] SharePlay multiplayer mode  
- [ ] Video recording and playback  
- [ ] BSL/LSF language expansion  

### Phase 4 (12 Months)
- [ ] Enterprise integration (schools, hospitals)  
- [ ] Collaboration with accessibility researchers  
- [ ] iOS companion app for progress tracking

## 🤝 Contributing
We welcome contributions! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Areas for Contribution
- Adding more ASL signs
- Improving gesture recognition accuracy
- UI/UX enhancements
- Accessibility features
- Documentation improvements

## 👥 Team

**Mustafa Nomair** – Computer Science @ USC  
*Led full product development — from design and coding to gesture detection, feedback logic, and Vision Pro app integration alongside Abdelaziz.*

**Abdelaziz Abderhman** – Electrical and Computer Engineering B.S. & Computer Engineering M.S. @ USC  
*Handled Vision Pro hardware setup and sensor integration for real-time hand tracking.*

**Ahmed Ataelfadeel** – Electrical and Computer Engineering @ USC  
*Assisted with hardware connectivity under Abdelaziz’s guidance.*

**Hamza Wako** – Computer Science and Business Administration @ USC  
*Served as project manager, coordinating tasks, deadlines, and testing cycles.*

**Ardysatrio Fakhri Haroen** – Computer Science (M.S.) @ USC  
*Mentored the team on ML model structure, app architecture, and performance tuning.*

**Built at**: Good Vibes Only Buildathon 2025  
**Location**: USC Information Sciences Institute, Marina Del Rey 

## 🙏 Acknowledgments
- **USC Viterbi School of Engineering** - Venue and support
- **PayPal** - Platinum sponsor
- **Lovable** - Technology partner and credits
- **Meta** - Judge participation
- **Microsoft** - Inclusive Tech Lab inspiration
- **Apple** - Apple Vision Pro access 
Special thanks to all mentors and organizers who made this possible!

## 📞 Contact
**Mustafa Nomair**  
- Email: nomair@usc.edu
- LinkedIn: [View Profile](https://www.linkedin.com/in/mustafa-nomair)
- Project Demo: [Video Link](https://drive.google.com/file/d/1XPNRzenzS-k5-pO7UJ3PRrQrqJHE6at7/view?usp=sharing)

*Making the world more inclusive, one sign at a time.* 🤟
