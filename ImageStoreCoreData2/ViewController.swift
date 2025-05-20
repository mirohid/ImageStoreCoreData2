//
//  ViewController.swift
//  ImageStoreCoreData2
//
//  Created by MacMini6 on 19/05/25.
//

import UIKit
import AVFoundation
import MobileCoreServices
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var resetImage1Button: UIImageView!
    @IBOutlet weak var resetImage2Button: UIImageView!
    
    
    var selectedImageView: UIImageView?
    var selectedVideoURL1: URL?
    var selectedVideoURL2: URL?

    override func viewDidLoad() {
           super.viewDidLoad()

           let tap1 = UITapGestureRecognizer(target: self, action: #selector(image1Tapped))
           imageView1.addGestureRecognizer(tap1)
           imageView1.isUserInteractionEnabled = true

           let tap2 = UITapGestureRecognizer(target: self, action: #selector(image2Tapped))
           imageView2.addGestureRecognizer(tap2)
           imageView2.isUserInteractionEnabled = true

           let resetTap1 = UITapGestureRecognizer(target: self, action: #selector(resetImage1))
           resetImage1Button.addGestureRecognizer(resetTap1)
           resetImage1Button.isUserInteractionEnabled = true

           let resetTap2 = UITapGestureRecognizer(target: self, action: #selector(resetImage2))
           resetImage2Button.addGestureRecognizer(resetTap2)
           resetImage2Button.isUserInteractionEnabled = true
       }

       @objc func image1Tapped() {
           selectedImageView = imageView1
           openMediaPicker(forImageView: 1)
       }

       @objc func image2Tapped() {
           selectedImageView = imageView2
           openMediaPicker(forImageView: 2)
       }

       func openMediaPicker(forImageView tag: Int) {
           let picker = UIImagePickerController()
           picker.delegate = self
           picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
           picker.allowsEditing = true

           let alert = UIAlertController(title: "Upload Media", message: nil, preferredStyle: .actionSheet)

           alert.addAction(UIAlertAction(title: "Open Camera", style: .default, handler: { _ in
               if UIImagePickerController.isSourceTypeAvailable(.camera) {
                   picker.sourceType = .camera
                   picker.cameraCaptureMode = .video
                   self.present(picker, animated: true)
               } else {
                   self.showAlert(title: "Camera Not Available", message: "This device does not support camera.")
               }
           }))

           alert.addAction(UIAlertAction(title: "Pick from Gallery", style: .default, handler: { _ in
               picker.sourceType = .photoLibrary
               self.present(picker, animated: true)
           }))

           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           self.present(alert, animated: true)
       }

       // MARK: - Image/Video Picker
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

           if let mediaType = info[.mediaType] as? String {
               if mediaType == kUTTypeImage as String {
                   if let editedImage = info[.editedImage] as? UIImage {
                       selectedImageView?.image = editedImage
                   } else if let originalImage = info[.originalImage] as? UIImage {
                       selectedImageView?.image = originalImage
                   }

               } else if mediaType == kUTTypeMovie as String {
                   if let mediaURL = info[.mediaURL] as? URL {
                       generateThumbnail(for: mediaURL) { [weak self] thumbnail in
                           DispatchQueue.main.async {
                               self?.selectedImageView?.image = thumbnail
                               if self?.selectedImageView == self?.imageView1 {
                                   self?.selectedVideoURL1 = mediaURL
                               } else {
                                   self?.selectedVideoURL2 = mediaURL
                               }
                           }
                       }
                   }
               }
           }

           picker.dismiss(animated: true)
       }

       func generateThumbnail(for url: URL, completion: @escaping (UIImage?) -> Void) {
           DispatchQueue.global().async {
               let asset = AVAsset(url: url)
               let assetImgGenerate = AVAssetImageGenerator(asset: asset)
               assetImgGenerate.appliesPreferredTrackTransform = true

               let time = CMTimeMake(value: 1, timescale: 2)
               do {
                   let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                   let thumbnail = UIImage(cgImage: img)
                   completion(thumbnail)
               } catch {
                   print("Error generating thumbnail: \(error)")
                   completion(nil)
               }
           }
       }

       // MARK: - Reset Image Actions
       @objc func resetImage1() {
           imageView1.image = UIImage(named: "uploadImgBack")
           selectedVideoURL1 = nil
       }

       @objc func resetImage2() {
           imageView2.image = UIImage(named: "uploadImgBack")
           selectedVideoURL2 = nil
       }
    
    
    @IBAction func saveData(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
                     let email = emailTextField.text, !email.isEmpty else {
                   showAlert(title: "Error", message: "Please enter name and email")
                   return
               }

               let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
               let newUser = UserData(context: context)
               newUser.name = name
               newUser.email = email

               if let imgData = imageView1.image?.jpegData(compressionQuality: 0.8), selectedVideoURL1 == nil {
                   newUser.image1 = imgData
               } else if let videoURL = selectedVideoURL1 {
                   newUser.video1 = try? Data(contentsOf: videoURL)
               }

               if let imgData = imageView2.image?.jpegData(compressionQuality: 0.8), selectedVideoURL2 == nil {
                   newUser.image2 = imgData
               } else if let videoURL = selectedVideoURL2 {
                   newUser.video2 = try? Data(contentsOf: videoURL)
               }

               do {
                   try context.save()
                   showAlert(title: "Success", message: "Data saved successfully!")
               } catch {
                   showAlert(title: "Error", message: "Failed to save data")
               }
    }
    
    
    @IBAction func viewDetails(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
           if let vc = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController {
               navigationController?.pushViewController(vc, animated: true)
           }
    }
    
    // MARK: - Alert Utility
       func showAlert(title: String, message: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
    
}




