//
//  ImagePicker.swift
//  Instafilter
//
//  Created by Николай Никитин on 23.10.2022.
//

import PhotosUI
import SwiftUI

#warning("Step 1: Create a view controller for image picker as struct to wrap a UIViewController in a SwiftUI view")

struct ImagePicker: UIViewControllerRepresentable {

#warning("Step 3: Create a coordinator class between the structure and the UIKit PHPickerViewController")

  ///  Make shure that Coordinator is conforming NSObject (a base class for all UIKit) and PHPickerViewControllerDelegate with all needed methods implementation!
  //MARK: - Coordinator
  class Coordinator: NSObject, PHPickerViewControllerDelegate {

    var parent: ImagePicker

    init(_ parent: ImagePicker) {
      self.parent = parent
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      // Tell the picker to go away
      picker.dismiss(animated: true)

      // Exit if no selection was made
      guard let provider = results.first?.itemProvider else { return }

      // If this has an image we can use, use it
      if provider.canLoadObject(ofClass: UIImage.self) {
        provider.loadObject(ofClass: UIImage.self) { image, _ in
          self.parent.image = image as? UIImage
        }
      }
    }
  }

  //MARK: - Properties
  /// Allows  to create a binding from ImagePicker up to whatever created it
  @Binding var image: UIImage?

#warning("Step 2: Conform to UIViewControllerRepresentable")
  /// To conform UIViewControllerRepresentable use typealias UIViewControllerType = PHPickerViewController
  //MARK: - PHPickerViewController
  func makeUIViewController(context: Context) -> PHPickerViewController {
    var config = PHPickerConfiguration()
    config.filter = .images

    let picker = PHPickerViewController(configuration: config)

#warning("Step4:  Tell the PHPickerViewController that when something happens it should tell our coordinator by making coordinatar a delegate")

    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

  }

#warning("Step4: Implement specific methodfor Coordinator,  which SwiftUI will automatically call")

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}
