import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var featureManager = FeatureManager()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("DINOv2 Feature Viewer")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                StatusIndicator(isConnected: featureManager.isConnected)
            }
            .padding()
            
            // Feature Display
            ScrollView {
                VStack(spacing: 16) {
                    // Global Features Card
                    FeatureCard(
                        title: "Global Features (CLS Token)",
                        subtitle: "\(featureManager.clsFeatures.count) dimensions",
                        features: featureManager.clsFeatures,
                        color: .blue
                    )
                    
                    // Patch Features Card
                    FeatureCard(
                        title: "Patch Features",
                        subtitle: "\(featureManager.patchFeatures.count) patches × \(featureManager.patchFeatures.first?.count ?? 0) dimensions",
                        features: featureManager.patchFeatures.flatMap { $0 },
                        color: .green
                    )
                    
                    // Feature Statistics
                    StatisticsView(featureManager: featureManager)
                }
                .padding()
            }
            
            // Connection Controls
            HStack {
                Button(action: {
                    if featureManager.isConnected {
                        featureManager.disconnect()
                    } else {
                        featureManager.connect()
                    }
                }) {
                    HStack {
                        Image(systemName: featureManager.isConnected ? "stop.circle.fill" : "play.circle.fill")
                        Text(featureManager.isConnected ? "Stop" : "Start")
                    }
                    .padding()
                    .background(featureManager.isConnected ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Text("FPS: \(featureManager.fps, specifier: "%.1f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 400)
        .background(Color(.windowBackgroundColor))
    }
}

struct StatusIndicator: View {
    let isConnected: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(isConnected ? "Connected" : "Disconnected")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct FeatureCard: View {
    let title: String
    let subtitle: String
    let features: [Float]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // Feature visualization
            if !features.isEmpty {
                FeatureVisualization(features: features, color: color)
            }
            
            // First few values
            if !features.isEmpty {
                Text("First 5 values: \(features.prefix(5).map { String(format: "%.3f", $0) }.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct FeatureVisualization: View {
    let features: [Float]
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = width / CGFloat(max(1, features.count - 1))
                
                for (index, value) in features.enumerated() {
                    let x = CGFloat(index) * stepX
                    let normalizedValue = CGFloat((value + 1) / 2) // Normalize to 0-1
                    let y = height - (normalizedValue * height)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color, lineWidth: 2)
        }
        .frame(height: 60)
    }
}

struct StatisticsView: View {
    @ObservedObject var featureManager: FeatureManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Statistics")
                .font(.headline)
            
            HStack {
                StatItem(title: "Min", value: featureManager.minValue, format: "%.3f")
                StatItem(title: "Max", value: featureManager.maxValue, format: "%.3f")
                StatItem(title: "Mean", value: featureManager.meanValue, format: "%.3f")
                StatItem(title: "Std", value: featureManager.stdValue, format: "%.3f")
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let title: String
    let value: Float
    let format: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(String(format: format, value))
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
} 