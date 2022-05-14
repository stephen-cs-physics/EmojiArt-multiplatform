//
//  Camera.swift
//  EmojiArt
//
//  Created by stephen on 2022/05/13.
//

import SwiftUI

struct Camera: UIViewControllerRepresentable {
    
    var handlePickedImage: (UIImage?) -> Void
    
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)  //Controller in MVC
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(handlePickedImage: handlePickedImage)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true     //pinch/zoom...
        picker.delegate = context.coordinator           //send a msg  (uikit:d elegate -> swiftUI: closure)
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        //nothing to do
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var handlePickedImage: (UIImage?) -> Void
        
        init(handlePickedImage: @escaping (UIImage?) -> Void) {
            self.handlePickedImage = handlePickedImage
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            handlePickedImage(nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            handlePickedImage((info[.editedImage] ?? info[.originalImage]) as? UIImage)
        }
    }
}
