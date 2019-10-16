//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Adriano Ramos on 15/10/19.
//  Copyright © 2019 Adriano Ramos. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    // MARK: - Variables
    var chosenImage = CIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.resultLabel.textColor = .black
    }
    
    // MARK: - Functions
    @IBAction func nextButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!) {
            chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage)
    }

    func recognizeImage(image: CIImage) {
        
        resultLabel.text = "Checking ..."
        
        // MARK: - Request
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        let topResults = results.first
                        
                        DispatchQueue.main.async {
                            let confidenceLevel = (topResults?.confidence ?? 0) * 100
                            let rounded = Int(confidenceLevel * 100) / 100
                            self.resultLabel.text = "\(rounded)% it's \(topResults!.identifier)"
                        }
                    }
                }
            }
            // MARK: - Handler
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("error")
                }
            }
        }
    }

}

