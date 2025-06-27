import Foundation
import Combine

class FeatureManager: ObservableObject {
    @Published var clsFeatures: [Float] = []
    @Published var patchFeatures: [[Float]] = []
    @Published var isConnected: Bool = false
    @Published var fps: Float = 0.0
    
    private var server: HTTPServer?
    private var timer: Timer?
    private var frameCount: Int = 0
    private var lastFrameTime: Date = Date()
    
    func connect() {
        startServer()
        startFPSCounter()
    }
    
    func disconnect() {
        stopServer()
        stopFPSCounter()
        isConnected = false
    }
    
    private func startServer() {
        server = HTTPServer()
        server?.delegate = self
        server?.start()
        isConnected = true
    }
    
    private func stopServer() {
        server?.stop()
        server = nil
    }
    
    private func startFPSCounter() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let now = Date()
            let timeDiff = now.timeIntervalSince(self.lastFrameTime)
            self.fps = Float(self.frameCount) / Float(timeDiff)
            self.frameCount = 0
            self.lastFrameTime = now
        }
    }
    
    private func stopFPSCounter() {
        timer?.invalidate()
        timer = nil
        frameCount = 0
        fps = 0.0
    }
    
    // Computed properties for statistics
    var allFeatures: [Float] {
        return clsFeatures + patchFeatures.flatMap { $0 }
    }
    
    var minValue: Float {
        return allFeatures.min() ?? 0.0
    }
    
    var maxValue: Float {
        return allFeatures.max() ?? 0.0
    }
    
    var meanValue: Float {
        guard !allFeatures.isEmpty else { return 0.0 }
        return allFeatures.reduce(0, +) / Float(allFeatures.count)
    }
    
    var stdValue: Float {
        guard !allFeatures.isEmpty else { return 0.0 }
        let mean = meanValue
        let variance = allFeatures.map { pow($0 - mean, 2) }.reduce(0, +) / Float(allFeatures.count)
        return sqrt(variance)
    }
}

// MARK: - HTTPServerDelegate
extension FeatureManager: HTTPServerDelegate {
    func server(_ server: HTTPServer, didReceiveData data: Data) {
        frameCount += 1
        
        do {
            let featureData = try JSONDecoder().decode(FeatureData.self, from: data)
            
            DispatchQueue.main.async {
                self.clsFeatures = featureData.clsFeatures
                self.patchFeatures = featureData.patchFeatures
            }
        } catch {
            print("Error decoding feature data: \(error)")
        }
    }
}

// MARK: - Data Models
struct FeatureData: Codable {
    let clsFeatures: [Float]
    let patchFeatures: [[Float]]
    let timestamp: TimeInterval
}

// MARK: - Simple HTTP Server
protocol HTTPServerDelegate: AnyObject {
    func server(_ server: HTTPServer, didReceiveData data: Data)
}

class HTTPServer {
    weak var delegate: HTTPServerDelegate?
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    
    func start() {
        // Create a simple TCP server on localhost:8080
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "localhost" as CFString, 8080, &readStream, &writeStream)
        
        guard let readStream = readStream?.takeRetainedValue(),
              let writeStream = writeStream?.takeRetainedValue() else {
            print("Failed to create streams")
            return
        }
        
        inputStream = readStream as InputStream
        outputStream = writeStream as OutputStream
        
        inputStream?.delegate = self
        inputStream?.schedule(in: .current, forMode: .default)
        inputStream?.open()
        
        outputStream?.delegate = self
        outputStream?.schedule(in: .current, forMode: .default)
        outputStream?.open()
    }
    
    func stop() {
        inputStream?.close()
        outputStream?.close()
        inputStream = nil
        outputStream = nil
    }
}

extension HTTPServer: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            if let inputStream = aStream as? InputStream {
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
                defer { buffer.deallocate() }
                
                let bytesRead = inputStream.read(buffer, maxLength: 4096)
                if bytesRead > 0 {
                    let data = Data(bytes: buffer, count: bytesRead)
                    delegate?.server(self, didReceiveData: data)
                }
            }
        case .errorOccurred:
            print("Stream error occurred")
        default:
            break
        }
    }
} 