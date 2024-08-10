//
//  ContentView.swift
//  Instafilter
//
//  Created by Aaron Graves on 8/8/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import StoreKit
import SwiftUI

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 0.5
    @State private var filterScale = 0.5
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingFilters = false
    
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var filterButtonText = "Sepia Tone"
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                PhotosPicker(selection: $selectedItem) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem, loadImage)
                
                Spacer()
                
                Section {
                    HStack {
                        Text("Intensity\t")
                        Slider(value: $filterIntensity)
                            .onChange(of: filterIntensity, applyProcessing)
                    }
                    //.disabled(selectedItem == nil)
                    
                    HStack {
                        Text("Radius\t\t")
                        Slider(value: $filterRadius)
                            .onChange(of: filterRadius, applyProcessing)
                    }
                    //.disabled(selectedItem == nil)
                    
                    HStack {
                        Text("Scale\t\t")
                        Slider(value: $filterScale)
                            .onChange(of: filterScale, applyProcessing)
                    }
                    
                    HStack {
                        Button(filterButtonText, action: changeFilter)
                        
                        Spacer()
                        
                        if let processedImage {
                            ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                        }
                    }
                }
                .disabled(selectedItem == nil)
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                Button("Crystallize") { setFilter(CIFilter.crystallize(), "Crystallize") }
                Button("Edges") { setFilter(CIFilter.edges(), "Edges") }
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur(), "Gaussian Blur") }
                Button("Pixellate") { setFilter(CIFilter.pixellate(), "Pixellate") }
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone(), "Sepia Tone") }
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask(), "Unsharp Mask") }
                Button("Vignette") { setFilter(CIFilter.vignette(), "Vignette") }
                Button("Bokeh Blur") { setFilter(CIFilter.bokehBlur(), "Bokeh Blur") }
                Button("Motion Blur") { setFilter(CIFilter.motionBlur(), "Motion Blur") }
                Button("Cancel", role: .cancel) {  }
            }
        }
    }
    
    func changeFilter() {
        showingFilters = true
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterScale * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    @MainActor func setFilter(_ filter: CIFilter, _ title: String) {
        currentFilter = filter
        filterButtonText = title
        loadImage()
        
        filterCount += 1
        
        if filterCount >= 20 {
            requestReview()
        }
    }
}

#Preview {
    ContentView()
}
