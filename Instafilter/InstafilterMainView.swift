//
//  InstafilterMainView.swift
//  Instafilter
//
//  Created by Николай Никитин on 22.10.2022.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct InstafilterMainView: View {

  //MARK: - View Properties
  @State private var image: Image!
  @State private var filterIntensity = 0.5
  @State private var filterRadius = 100.0
  @State private var filterScale = 5.0
  @State private var filterAmount = 1.0

  @State private var showingImagePicker = false
  @State private var inputImage: UIImage?
  @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
  @State private var showingFilterSheet = false
  @State private var processedImage: UIImage?
  @State private var filterName = "Change filter"
  @State private var isShowingAlert = false
  @State private var message = ""
  @State private var errorText = ""

  private var isSaveInactive: Bool {
    if image != nil { return false }
    return true
  }

  private var suppotsIntensity: Bool {
    if currentFilter.inputKeys.contains(kCIInputIntensityKey) { return true }
    return false
  }

  private var supportsRadius: Bool {
    if currentFilter.inputKeys.contains(kCIInputRadiusKey) { return true }
    return false
  }

  private var supportsScale: Bool {
    if currentFilter.inputKeys.contains(kCIInputScaleKey) { return true }
    return false
  }

  private var supportsAmount: Bool {
    if currentFilter.inputKeys.contains(kCIInputAmountKey) { return true }
    return false
  }

  let context = CIContext()

  //MARK: - View Body
  var body: some View {
    NavigationView {
      ZStack {
        LinearGradient(colors: [.purple, .orange],
                       startPoint: .top,
                       endPoint: .bottom)
        .ignoresSafeArea(.all)
        .opacity(0.5)

        VStack {
          ZStack {
            Rectangle()
              .fill(.secondary)
            Text("Tap to select a picture")
              .foregroundColor(.white)
              .font(.headline)
            image?
              .resizable()
              .scaledToFit()
          }
          .onTapGesture {
            showingImagePicker = true
          }

          Group {
            if suppotsIntensity {
              HStack {
                Text("Intensity")
                Slider(value: $filterIntensity)
                  .onChange(of: filterIntensity) { _ in
                    applyProcessing()
                  }
              }
              .padding(.vertical)
            }
            if supportsRadius {
              HStack {
                Text("Radius")
                Slider(value: $filterRadius)
                  .onChange(of: filterRadius) { _ in
                    applyProcessing()
                  }
              }
              .padding(.vertical)
            }
            if supportsScale {
              HStack {
                Text("Scale")
                Slider(value: $filterScale)
                  .onChange(of: filterScale) { _ in
                    applyProcessing()
                  }
              }
              .padding(.vertical)
            }
            if supportsAmount {
              HStack {
                Text("Amount")
                Slider(value: $filterAmount)
                  .onChange(of: filterAmount) { _ in
                    applyProcessing()
                  }
              }
              .padding(.vertical)
            }
          }
          HStack {
            Button("\(filterName)") {
              showingFilterSheet = true
            }
            Spacer()
            Button("Save", action: save)
              .disabled(isSaveInactive)
          }
        }
        .padding([.horizontal, .bottom])
        .alert("\(message)", isPresented: $isShowingAlert) {
          Text("\(errorText)")
        }
      }
      .navigationTitle("Instafilter")
      .onChange(of: inputImage) { _ in loadImage() }
      .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $inputImage) }
      .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
        Button("Crystallize") { setFilter(CIFilter.crystallize()) }
        Button("Edges") { setFilter(CIFilter.edges()) }
        Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
        Button("Pixellate") { setFilter(CIFilter.pixellate()) }
        Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
        Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
        Button("Vignette") { setFilter(CIFilter.vignette()) }
        Button("Vibrance") { setFilter(CIFilter.vibrance()) }
        Button("Gloom") {  setFilter(CIFilter.gloom()) }
        Button("Cancel", role: .cancel) { }
      }
    }
  }

  //MARK: - View Methods
  func loadImage() {
    guard let inputImage else { return }
    let beginImage = CIImage(image: inputImage)
    currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
    applyProcessing()
  }

  func save() {
    guard let processedImage else { return }
    let imageSaver = ImageSaver()
    imageSaver.successHandler = {
      message = "Success!"
      isShowingAlert = true
    }
    imageSaver.errorHandler = {
      message = "Oops!"
      errorText = "\($0.localizedDescription)"
      isShowingAlert = true
    }
    imageSaver.writeToPhotoAlbum(image: processedImage)
  }

  func applyProcessing() {
    let inputKeys = currentFilter.inputKeys
    if inputKeys.contains(kCIInputIntensityKey) {
      currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
    }
    if inputKeys.contains(kCIInputRadiusKey) {
      currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
    }
    if inputKeys.contains(kCIInputScaleKey) {
      currentFilter.setValue(filterScale, forKey: kCIInputScaleKey)
    }

    guard let outputImage = currentFilter.outputImage else { return }
    if let cgImg = context.createCGImage(outputImage, from: outputImage.extent) {
      let uiImage = UIImage(cgImage: cgImg)
      image = Image(uiImage: uiImage)
      processedImage = uiImage
    }
  }

  func setFilter(_ filter: CIFilter) {
    currentFilter = filter
    filterName = String(filter.name.dropFirst(2))
    loadImage()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    InstafilterMainView()
  }
}
