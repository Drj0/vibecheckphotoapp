//  ContentView.swift
//  vibecheckphotoapp
//
//  Created by Dheeraj on 05/01/26.

import CoreML
import PhotosUI
import SwiftUI
import Vision

struct ContentView: View {
    @State private var photoResults: [(image: UIImage, result: String)] = []
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(Date.now, style: .date)
                    .font(.largeTitle).fontWeight(.bold)
                
                PhotosPicker(selection: $selectedItems, matching: .images) {
                    Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                        .font(.title2).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24).padding(.vertical, 12)
                        .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(16)
                }
                .onChange(of: selectedItems) { items in
                    photoResults.removeAll()
                    Task {
                        for item in items {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                let result = classifyImage(image)
                                await MainActor.run { photoResults.append((image, result)) }
                            }
                        }
                    }
                }
                
                Text("Selected: \(photoResults.count) photos").font(.subheadline).foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(photoResults.indices, id: \.self) { i in
                            VStack(spacing: 8) {
                                Image(uiImage: photoResults[i].image)
                                    .resizable().scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipped().cornerRadius(12)
                                
                                Text(photoResults[i].result)
                                    .font(.headline).fontWeight(.bold)
                                    .foregroundColor(photoResults[i].result == "Cool" ? .green : .red)
                                    .padding(.horizontal, 16).padding(.vertical, 6)
                                    .background(Capsule().fill((photoResults[i].result == "Cool" ? Color.green : .red).opacity(0.15)))
                            }
                        }
                    }.padding(.horizontal)
                }
                Spacer()
            }
            .navigationTitle("Vibe Check")
            .padding()
        }
    }
    
    func classifyImage(_ image: UIImage) -> String {
        #if targetEnvironment(simulator)
        print("⚠️ Running on simulator - CoreML not supported")
        return "Uncool" // Model doesn't work on simulator
        #else
        guard let cgImage = image.cgImage else {
            print("❌ Failed to get CGImage from UIImage")
            return "Uncool"
        }
        
        guard let model = try? VNCoreMLModel(for: CoolCheck(configuration: .init()).model) else {
            print("❌ Failed to load CoolCheck model")
            return "Uncool"
        }
        
        var result = "Uncool"
        let request = VNCoreMLRequest(model: model) { req, error in
            if let error = error {
                print("❌ Classification error: \(error)")
                return
            }
            
            if let classifications = req.results as? [VNClassificationObservation] {
                print("📊 All classifications:")
                for classification in classifications {
                    print("   - \(classification.identifier): \(classification.confidence * 100)%")
                }
                
                if let top = classifications.first {
                    print("✅ Top result: '\(top.identifier)' with \(top.confidence * 100)% confidence")
                    // Check for variations of "cool" label
                    let label = top.identifier.lowercased().trimmingCharacters(in: .whitespaces)
                    result = (label == "cool" || label.contains("cool")) && !label.contains("not") ? "Cool" : "Uncool"
                }
            }
        }
        
        do {
            try VNImageRequestHandler(cgImage: cgImage).perform([request])
        } catch {
            print("❌ VNImageRequestHandler error: \(error)")
        }
        
        return result
        #endif
    }
}

#Preview { ContentView() }

