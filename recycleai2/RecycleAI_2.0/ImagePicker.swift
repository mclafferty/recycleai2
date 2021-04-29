//
//  File.swift
//  RecycleAI_2.0
//
//  Created by Morgan Lafferty on 4/22/21.
//

import SwiftUI
import UIKit
import CoreML
import Vision
import ImageIO

struct ImagePicker: UIViewControllerRepresentable {
    typealias SourceType = UIImagePickerController.SourceType

    let sourceType: SourceType
    
    class Coordinator: NSObject,
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let uiImage = info[.originalImage] as?
                UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>)
    -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        //picker.sourceType = sourceType
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
       
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>)
    {
        
    }
}


    
   
