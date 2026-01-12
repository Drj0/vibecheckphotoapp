#VibecheckApp

Note: Real iOS Device Required — This app uses CoreML for on-device image classification, which requires Apple's Neural Engine hardware. The iOS Simulator does not support this, so you must run the app on a physical iPhone or iPad.

A simple SwiftUI app that lets you pick multiple photos and classifies each image as “Cool” or “Not cool” using a Core ML model. Results are shown inline with a clean, scrollable gallery.

Features
• Select multiple photos with PhotosPicker
• On-device image classification via Core ML / Vision
• Clear, glanceable results for each photo
• Modern SwiftUI UI with NavigationStack

Permissions
• Photo Library access is required to select images.

Notes
• The project includes two classification approaches:
   • Vision + VNCoreMLRequest (expects a model like CoolCheck)
   • Direct Core ML inference (expects a model like coolcheker)

