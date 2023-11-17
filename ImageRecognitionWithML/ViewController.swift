//
//  ViewController.swift
//  ImageRecognitionWithML
//
//  Created by Murad Yarmamedov on 17.11.23.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    
    var selectedImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


    @IBAction func selectImageButtonAction(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        
        if let image = imageView.image {
            if let ciImage = CIImage(image: image){
                selectedImage = ciImage
            }
        }
        
        recognizeImage(image: selectedImage)
    }
    
    func recognizeImage(image: CIImage) {
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { vnRequest, error in
                if let error = error {
                    self.makeAlert(title: "Error", message: error.localizedDescription)
                } else {
                    if let results = vnRequest.results as? [VNClassificationObservation] {
                        if results.count > 0 {
                            let mainResult = results.first
                            DispatchQueue.main.async {
                                let confidenceRate = (mainResult!.confidence) * 100
                                let rounded = Int (confidenceRate * 100) / 100
                                self.textLabel.text = "\(rounded)% it's \(mainResult!.identifier)"
                            }
                        }
                    }
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Handler Error")
                }
            }
        }
    }
    
    func makeAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: handler)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}

