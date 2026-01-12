# VibecheckApp

## Note: Real iOS Device Required

This app uses **Core ML** for on-device image classification, which requires Apple’s **Neural Engine** hardware.  
The **iOS Simulator is not supported**, so the app must be run on a **physical iPhone or iPad**.

## Description

A simple SwiftUI app that allows you to select multiple photos and classifies each image as **“Cool”** or **“Not cool”** using a Core ML model.  
Results are displayed inline in a clean, scrollable gallery.

## Features

- Select multiple photos using `PhotosPicker`
- On-device image classification via
