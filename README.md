# Webcam DINOv2 Demo

A real-time webcam demo that processes video streams using the DINOv2 (Data-efficient Image Transformer) model from the `timm` library. This project extracts both global (CLS token) and local (patch-level) features from each frame.

## Features

- Real-time webcam video processing
- DINOv2 model inference with cached weights
- Global image feature extraction (CLS token)
- Local patch-level feature extraction
- Live feature visualization overlay

## Requirements

- Python 3.9+
- macOS (tested on macOS 21.6.0)
- Webcam access

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

## What You'll See

- Live webcam feed with overlaid feature information:
  - **CLS Features: 384 dims** - Global image representation
  - **Patches: X x 384 dims** - Local patch-level features
  - **First 3: [values]** - First 3 values of the CLS token

## Model Details

- **Model:** `vit_small_patch14_dinov2.lvd142m`
- **Input Size:** 518x518 pixels
- **Feature Dimensions:** 384
- **Patch Size:** 14x14 pixels
- **Number of Patches:** ~1369 (37x37 grid)

## Project Structure

```
embodied_eq_demo/
├── webcam_demo.py      # Main application script
├── requirements.txt    # Python dependencies
└── README.md          # This file
```

## Dependencies

- `opencv-python` - Video capture and display
- `torch` - PyTorch for deep learning
- `timm` - Model library with DINOv2
- `torchvision` - Image transforms

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

## License

[Add your license here]

## Contributing

[Add contribution guidelines if desired] 