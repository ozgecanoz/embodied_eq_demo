import cv2
import torch
import timm
from torchvision import transforms

# Load the model
model = timm.create_model('vit_small_patch14_dinov2.lvd142m', pretrained=True)
model.eval()
model = model.to('cpu')  # Use CPU for inference

# Define transforms for the model
transform = transforms.Compose([
    transforms.ToPILImage(),
    transforms.Resize((518, 518)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

def get_patch_features(model, input_tensor):
    """Extract patch features from DINOv2 model"""
    with torch.no_grad():
        # Use forward_features to get intermediate outputs
        features = model.forward_features(input_tensor)
        
        # For DINOv2, we can get patch tokens from the last layer
        # The shape should be [batch_size, num_patches, feature_dim]
        if isinstance(features, tuple):
            # Some models return tuple, get the last element
            patch_features = features[-1]
        else:
            patch_features = features
            
        return patch_features

def process_frame(frame):
    # Convert BGR to RGB (OpenCV uses BGR, torchvision expects RGB)
    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    
    # Preprocess for model
    input_tensor = transform(frame_rgb).unsqueeze(0)  # Add batch dimension
    
    # Run inference
    with torch.no_grad():
        output = model(input_tensor)
    
    # Get patch features
    patch_features = get_patch_features(model, input_tensor)
    
    # Get feature vector (for DINOv2, this is the CLS token)
    features = output  # Shape: [1, 384] for vit_small
    
    # Display original frame with feature info
    # Convert features to text for display
    feature_text = f"CLS Features: {features.shape[1]} dims"
    cv2.putText(frame, feature_text, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
    
    # Show patch features info
    patch_text = f"Patches: {patch_features.shape[1]} x {patch_features.shape[2]} dims"
    cv2.putText(frame, patch_text, (10, 70), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
    
    # Show first few feature values
    feature_values = f"First 3: {features[0, :3].cpu().numpy()}"
    cv2.putText(frame, feature_values, (10, 110), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    
    return frame

def main():
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("Cannot open webcam")
        return
    while True:
        ret, frame = cap.read()
        if not ret:
            print("Can't receive frame (stream end?). Exiting ...")
            break
        processed = process_frame(frame)
        cv2.imshow('Webcam Feed', processed)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main() 