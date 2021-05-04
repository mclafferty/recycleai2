//
//  ViewController.swift
//  Recycle.ai
//
//  Created by Maylin van Cleeff on 4/20/21.
//

import UIKit
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var chooseButton: UIButton!
    @IBOutlet var recyclingLabel: UILabel!
    
    func processClassifications(for image: UIImage) {
        let modelSize = 100
        // Converting UIImage to CVPixelBuffer
        UIGraphicsBeginImageContextWithOptions(CGSize(width: modelSize, height: modelSize), true, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: modelSize, height: modelSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else { return }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        // Initializing Model
        let model = cnn()
        // Making a prediction
        guard let prediction = try? model.prediction(rescaling_6_input: pixelBuffer!) else { return }
        // Accessing classification
        let classifications = prediction.Identity.self
        // Finding index of classification with argmax
        let argmax = MLMultiArray.toDoubleArray(classifications).argmax()!
        // Converting classification result to text label for use in UI
        self.classificationLabel.text = String(argmax)
        classificationLabel.textAlignment = .center
        var data = readDataFromCSV(fileName: "RecyclingCodes", fileType: ".csv")
        data = cleanRows(file: data!)
        let csvRows = csv(data: data!)
//        self.recyclingLabel.text = csvRows[1][argmax + 1]
    }
    // Select picture
    @IBAction func takePicture() {
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    // CSV parsing code
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
            guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
                else {
                    return nil
            }
            do {
                var contents = try String(contentsOfFile: filepath, encoding: .utf8)
                contents = cleanRows(file: contents)
                return contents
            } catch {
                print("File Read Error for file \(filepath)")
                return nil
            }
        }
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
        return cleanFile
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ";")
            result.append(columns)
        }
        return result
    }
    
}
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Handling Image Picker Selection

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        processClassifications(for: image)
    }
}
// Code for handling model outuput
extension MLMultiArray {
    /// All values will be stored in the last dimension of the MLMultiArray (default is dims=1)
    static func from(_ arr: [Int], dims: Int = 1) -> MLMultiArray {
        var shape = Array(repeating: 1, count: dims)
        shape[shape.count - 1] = arr.count
        /// Examples:
        /// dims=1 : [arr.count]
        /// dims=2 : [1, arr.count]
        ///
        let o = try! MLMultiArray(shape: shape as [NSNumber], dataType: .int32)
        let ptr = UnsafeMutablePointer<Int32>(OpaquePointer(o.dataPointer))
        for (i, item) in arr.enumerated() {
            ptr[i] = Int32(item)
        }
        return o
    }
    
    /// This will concatenate all dimensions into one one-dim array.
    static func toIntArray(_ o: MLMultiArray) -> [Int] {
        var arr = Array(repeating: 0, count: o.count)
        let ptr = UnsafeMutablePointer<Int32>(OpaquePointer(o.dataPointer))
        for i in 0..<o.count {
            arr[i] = Int(ptr[i])
        }
        return arr
    }
    
    /// This will concatenate all dimensions into one one-dim array.
    static func toDoubleArray(_ o: MLMultiArray) -> [Double] {
        var arr: [Double] = Array(repeating: 0, count: o.count)
        let ptr = UnsafeMutablePointer<Double>(OpaquePointer(o.dataPointer))
        for i in 0..<o.count {
            arr[i] = Double(ptr[i])
        }
        return arr
    }
    
    /// Helper to construct a sequentially-indexed multi array,
    /// useful for debugging and unit tests
    /// Example in 3 dimensions:
    /// ```
    /// [[[ 0, 1, 2, 3 ],
    ///   [ 4, 5, 6, 7 ],
    ///   [ 8, 9, 10, 11 ]],
    ///  [[ 12, 13, 14, 15 ],
    ///   [ 16, 17, 18, 19 ],
    ///   [ 20, 21, 22, 23 ]]]
    /// ```
    static func testTensor(shape: [Int]) -> MLMultiArray {
        let arr = try! MLMultiArray(shape: shape as [NSNumber], dataType: .double)
        let ptr = UnsafeMutablePointer<Double>(OpaquePointer(arr.dataPointer))
        for i in 0..<arr.count {
            ptr.advanced(by: i).pointee = Double(i)
        }
        return arr
    }
}
extension Array where Element: Comparable {
    func argmax() -> Index? {
        return indices.max(by: { self[$0] < self[$1] })
    }
    
    func argmin() -> Index? {
        return indices.min(by: { self[$0] < self[$1] })
    }
}





