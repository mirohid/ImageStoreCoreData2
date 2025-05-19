//
//  ViewController.swift
//  ImageStoreCoreData2
//
//  Created by MacMini6 on 19/05/25.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var resetImage1Button: UIImageView!
    @IBOutlet weak var resetImage2Button: UIImageView!
    
    
    var selectedImageView: UIImageView?

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
           openImagePicker()
       }

       @objc func image2Tapped() {
           selectedImageView = imageView2
           openImagePicker()
       }
    
    
    func openImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true

        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                self.present(picker, animated: true)
            } else {
                let cameraAlert = UIAlertController(title: "Camera Not Available", message: "This device does not have a camera.", preferredStyle: .alert)
                cameraAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(cameraAlert, animated: true)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }

    
    // MARK: - UIImagePicker Delegate
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let editedImage = info[.editedImage] as? UIImage {
               selectedImageView?.image = editedImage
           } else if let originalImage = info[.originalImage] as? UIImage {
               selectedImageView?.image = originalImage
           }
           picker.dismiss(animated: true)
       }

    // MARK: - Reset Image Actions
    @objc func resetImage1() {
        imageView1.image = UIImage(named: "uploadImgBack")
    }

    @objc func resetImage2() {
        imageView2.image = UIImage(named: "uploadImgBack")
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
               newUser.image1 = imageView1.image?.jpegData(compressionQuality: 0.8)
               newUser.image2 = imageView2.image?.jpegData(compressionQuality: 0.8)

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




