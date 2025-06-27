# Webcam DINOv2 Demo

A real-time webcam demo that processes video streams using the DINOv2 (Data-efficient Image Transformer) model from the `timm` library. This project extracts both global (CLS token) and local (patch-level) features from each frame.

## Features

- Real-time webcam video processing
- DINOv2 model inference with cached weights
- Global image feature extraction (CLS token)
- Local patch-level feature extraction
- Live feature visualization overlay
- **NEW**: macOS SwiftUI viewer with real-time feature visualization

## Requirements

- Python 3.9+
- macOS (tested on macOS 21.6.0)
- Webcam access
- Xcode 15.0+ (for SwiftUI app)

## Installation

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd embodied_eq_demo
   ```

2. **Create a virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

## Usage

### Option 1: Python Script Only

1. **Activate the virtual environment:**
   ```bash
   source venv/bin/activate
   ```

2. **Run the demo:**
   ```bash
   python webcam_demo.py
   ```

3. **Controls:**
   - Press `q` to quit the application
   - The video window must be selected to receive keyboard input

### Option 2: Python + SwiftUI Viewer (Recommended)

1. **Build the SwiftUI app:**
   ```bash
   open DINOv2Viewer.xcodeproj
   ```
   - In Xcode, press `Cmd+R` to build and run the app
   - The SwiftUI viewer will open and show "Disconnected" status

2. **Run the Python script with UI mode:**
   ```bash
   source venv/bin/activate
   python webcam_demo.py --no-window
   ```

3. **Connect in the SwiftUI app:**
   - Click the "Start" button in the SwiftUI viewer
   - You should see real-time feature data flowing in

### Command Line Options

- `--no-window`: Hide the OpenCV window (use with SwiftUI viewer)
- `--no-ui`: Don't send data to SwiftUI app (use with OpenCV window)

## What You'll See

### Python Script (OpenCV Window)
- Live webcam feed with overlaid feature information:
  - **CLS Features: 384 dims** - Global image representation
  - **Patches: X x 384 dims** - Local patch-level features
  - **First 3: [values]** - First 3 values of the CLS token

### SwiftUI Viewer
- **Modern macOS interface** with:
  - Real-time feature visualization graphs
  - Global and patch feature cards
  - Live statistics (min, max, mean, std)
  - FPS counter
  - Connection status indicator
  - Beautiful feature plots

## Model Details

- **Model:** `vit_small_patch14_dinov2.lvd142m`
- **Input Size:** 518x518 pixels
- **Feature Dimensions:** 384
- **Patch Size:** 14x14 pixels
- **Number of Patches:** ~1369 (37x37 grid)

## Project Structure

```
embodied_eq_demo/
├── webcam_demo.py              # Main Python application script
├── requirements.txt            # Python dependencies
├── README.md                   # This file
├── DINOv2Viewer/              # SwiftUI macOS app
│   ├── DINOv2ViewerApp.swift   # Main app entry point
│   ├── ContentView.swift       # Main UI view
│   └── FeatureManager.swift    # Data management and networking
└── DINOv2Viewer.xcodeproj/     # Xcode project file
```

## Dependencies

### Python
- `opencv-python` - Video capture and display
- `torch` - PyTorch for deep learning
- `timm` - Model library with DINOv2
- `torchvision` - Image transforms

### SwiftUI (macOS)
- macOS 14.0+
- Xcode 15.0+
- Swift 5.0+

## Architecture

The system uses a client-server architecture:

1. **Python Script (Server)**: 
   - Captures webcam frames
   - Runs DINOv2 inference
   - Sends feature data via HTTP to localhost:8080

2. **SwiftUI App (Client)**:
   - Receives feature data via HTTP
   - Displays real-time visualizations
   - Provides modern macOS UI

## Troubleshooting

### Missing `_lzma` module error
If you encounter `ModuleNotFoundError: No module named '_lzma'`:

1. Install xz library:
   ```bash
   brew install xz
   ```

2. Reinstall Python (if using pyenv):
   ```bash
   pyenv uninstall 3.9.6
   pyenv install 3.9.6
   ```

3. Recreate virtual environment:
   ```bash
   rm -rf venv
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

### SwiftUI Connection Issues
- Make sure the Python script is running before clicking "Start" in the SwiftUI app
- Check that port 8080 is not blocked by firewall
- Ensure both apps are running on the same machine

## License

[Add your license here]

## Contributing

[Add contribution guidelines if desired] 