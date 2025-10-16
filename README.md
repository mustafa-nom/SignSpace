# SignSpace - Real-Time ASL Learning with Apple Vision Pro

![SignSpace Banner](https://img.shields.io/badge/visionOS-2.5-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![License](https://img.shields.io/badge/license-MIT-green)

**Learn American Sign Language with instant, personalized feedback using spatial computing.**

Built at **Good Vibes Only Buildathon 2025** | USC x PayPal x Lovable

## 🎯 The Problem

- **430 million people worldwide** need hearing support and rehabilitation
- **500,000+ people** in the US use American Sign Language
- Learning ASL is challenging without real-time, personalized feedback
- Traditional methods (videos, books) lack interactive guidance
- No way to verify if you're making signs correctly

## 💡 Our Solution

**SignSpace** leverages Apple Vision Pro's advanced hand tracking to provide:

- **Real-time gesture recognition** - Detects ASL signs with 90Hz precision
- **Ghost hands overlay** - Transparent "target" hands show the correct position
- **Specific, actionable feedback** - "Move your thumb closer to your palm" instead of generic errors
- **Progress tracking** - Visual indicators showing mastery of each sign
- **Spatial visualization** - 3D hand skeleton with joint-level accuracy


## 🎥 Demo

> **[Insert Demo Video Link Here]**

### Key Features Showcased:
1. Hand tracking initialization
2. Learning letter "A" with instant feedback
3. Ghost hands overlay guiding hand position
4. Real-time corrections and validation
5. Progress through 5 ASL signs
6. Celebratory confetti on mastery

## 🛠️ Technology Stack

### Core Technologies
- **visionOS 2.5** - Native Apple Vision Pro development
- **Swift 5.9** - Modern, type-safe programming
- **SwiftUI** - Declarative UI framework
- **RealityKit** - 3D rendering and spatial computing
- **Hand Tracking API** - 90Hz, 27-joint precision tracking

### Key Features
- **Custom Gesture Recognition Engine** - Rule-based ASL sign detection
- **Spatial Hand Visualization** - 3D skeleton rendering with joint connections
- **Adaptive Feedback System** - Confidence-based color coding (red/yellow/green)
- **Mock Data Support** - Simulator testing without physical hardware

## 🏗️ Architecture
```
SignSpace/
├── SignSpaceApp.swift              # App entry point
├── ContentView.swift                # Main UI + hand visualization
├── HandTrackingManager.swift        # Hand tracking abstraction (real + mock)
├── GestureRecognizer.swift          # ASL gesture detection + feedback
├── GhostHandData.swift              # Ideal hand positions for each sign
├── SoundManager.swift               # Audio feedback system
└── AppModel.swift                   # App state management
```

### Data Flow
```
Vision Pro Hand Tracking
    ↓
HandTrackingManager (extracts 27 joints)
    ↓
GestureRecognizer (analyzes positions)
    ↓
ContentView (displays feedback + ghost hands)
    ↓
User sees real-time corrections
```

## 🎨 Features

### 1. **Real-Time Hand Tracking**
- 90Hz update rate
- 27 joint points per hand
- Sub-millimeter accuracy
- Works in any lighting condition

### 2. **Ghost Hands Overlay**
- Semi-transparent green target hands
- Shows exact correct position for each sign
- Updates dynamically as you switch signs
- User "traces" ghost hands to learn

### 3. **Intelligent Feedback System**
- **Green (85%+ confidence)**: "Perfect! 🎉"
- **Yellow (65-85%)**: "Almost there! Move thumb closer"
- **Red (<65%)**: "Curl your index finger into your palm"
- **Gray**: "Show your hand to the camera"

### 4. **3D Skeleton Visualization**
- Connects joints with lines
- Blue for user's hands
- Green for target hands
- Professional medical-grade rendering

### 5. **Progress Tracking**
- Visual progress bar (0/5 → 5/5)
- Tracks which signs mastered
- Confetti celebration on completion
- Per-sign confidence percentage

### 6. **Sound Effects**
- Success tone (correct sign)
- Progress tone (getting closer)
- Error buzz (incorrect position)
- System haptic feedback

## 📚 Supported ASL Signs

Currently supports **5 foundational signs**:

| Sign | Description | Difficulty |
|------|-------------|-----------|
| **A** | Closed fist, thumb on side | Easy |
| **B** | Fingers straight up, thumb tucked | Medium |
| **C** | Hand forms "C" curve | Medium |
| **Hello** | Open hand, all fingers extended | Easy |
| **Thank You** | Flat hand, fingers together | Easy |

**Future**: Full alphabet (26 letters) + 50+ common phrases

## 🚀 Getting Started

### Prerequisites
- macOS 14.0 or later
- Xcode 15.0 or later
- Apple Vision Pro (for real device testing)
- Apple Developer account (free tier works)

### Installation

1. **Clone the repository**
```bash
   git clone https://github.com/yourusername/SignSpace.git
   cd SignSpace
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
   - Request hand tracking authorization
   - Start ARKitSession with HandTrackingProvider
   - Begin processing anchor updates at 90Hz

2. **Extract Joint Data**
   - 27 joints per hand: wrist, 5 fingers × 5 joints each
   - Convert from anchor space to world space
   - Store as SIMD3<Float> positions

3. **Gesture Recognition**
   - Calculate distances between key joints
   - Compare to predefined thresholds
   - Determine which sign (if any) is being made

4. **Generate Feedback**
   - Analyze WHY sign is incorrect
   - Provide specific correction instructions
   - Calculate confidence score (0-100%)

5. **Render Visualization**
   - Draw ghost hands at ideal positions
   - Draw user's hands at actual positions
   - Connect joints with skeleton lines
   - Color-code based on accuracy

## 🏆 Technical Highlights

### Why This Showcases Vision Pro

1. **Hand Tracking Excellence**
   - Uses Vision Pro's strongest feature
   - No external cameras needed
   - Privacy-preserving (processed locally)

2. **Spatial Computing**
   - 3D visualization in real space
   - Ghost hands feel like physical objects
   - Natural interaction paradigm

3. **Real-Time Performance**
   - 90Hz tracking + 60fps rendering
   - Zero latency feedback
   - Smooth skeleton animations

4. **Accessibility-First Design**
   - Makes ASL learning accessible to all
   - Removes barriers of traditional methods
   - Inclusive technology demonstrating "solve for one, extend to many"

## 📊 Impact & Market Opportunity

### Target Users
- **500K+** ASL users in the United States
- **Millions** learning ASL (family, friends, educators)
- **Special education teachers** (differentiated instruction)
- **Special Olympics athletes** (45% have hearing/vision impairments)

### Use Cases
- **Families** with deaf/HOH members
- **Schools** teaching ASL as second language
- **Therapy centers** for speech pathology
- **Corporate training** for ADA compliance

### Business Model
- **Freemium**: Basic signs free, advanced content paid
- **B2C**: $9.99/month individual subscription
- **B2B**: $199/month for institutional licenses (schools, hospitals)
- **B2G**: ADA compliance tool for government services

### Competitive Advantage
- Only spatial computing ASL app
- Real-time 3D feedback (vs 2D videos)
- Personalized corrections (vs generic tutorials)
- Gamified progress tracking

## 🔮 Future Roadmap

### Phase 1 (MVP - Completed ✅)
- [x] Hand tracking implementation
- [x] 5 basic ASL signs
- [x] Ghost hands overlay
- [x] Real-time feedback
- [x] Progress tracking

### Phase 2 (Next 3 Months)
- [ ] Full alphabet (26 letters)
- [ ] 50+ common phrases
- [ ] CoreML model for improved accuracy
- [ ] Lesson structure with curriculum
- [ ] Statistics dashboard

### Phase 3 (6 Months)
- [ ] Multiplayer mode (SharePlay)
- [ ] Record/playback practice sessions
- [ ] Integration with Brisk Teaching platform
- [ ] Additional sign languages (BSL, LSF)

### Phase 4 (12 Months)
- [ ] Enterprise partnerships (schools, hospitals)
- [ ] Research collaboration (USC deaf studies)
- [ ] Special Olympics integration
- [ ] iOS companion app (practice tracking)

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

**Mustafa Nomair** - Computer Science @ USC  
*Interested in inclusive communication and accessible technology*

**Built at**: Good Vibes Only Buildathon 2025  
**Location**: USC Information Sciences Institute, Marina Del Rey  
**Date**: October 16-17, 2025

## 🙏 Acknowledgments
- **USC Viterbi School of Engineering** - Venue and support
- **PayPal** - Platinum sponsor
- **Lovable** - Technology partner and credits
- **Meta** - Judge participation
- **Microsoft** - Inclusive Tech Lab inspiration
- **ASL Community** - Feedback and guidance
Special thanks to all mentors and organizers who made this possible!

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

**Mustafa Nomair**  
- Email: mnomair01@gmail.com
- LinkedIn: [View Profile](https://www.linkedin.com/in/mustafa-nomair)
- Project Demo: [Insert Video Link]
**Project Repository**: [github.com/yourusername/SignSpace](https://github.com/yourusername/SignSpace)

## 🌟 Star This Repo!
If SignSpace helped you or you believe in making ASL learning accessible, please ⭐ this repository!
*Making the world more inclusive, one sign at a time.* 🤟
