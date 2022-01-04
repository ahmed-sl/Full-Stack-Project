//
//  RegisterVC.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 01/06/1443 AH.
//

import UIKit
import FirebaseAuth

class RegisterVC: UIViewController {

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var agelTF: UITextField!
    @IBOutlet weak var emailRegTF: UITextField!
    @IBOutlet weak var passRegTF: UITextField!
    
    @IBOutlet weak var btnGallery: UIButton!
    var pickerVC : UIImagePickerController?
    var imageSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

     title = "Register"
    }
    
    @IBAction func regsterBtn(_ sender: UIButton) {
        guard let fname = firstNameTF.text, let lname = lastNameTF.text,
              let age = agelTF.text,let email = emailRegTF.text , let pass = passRegTF.text ,
              !fname.isEmpty, !lname.isEmpty, !age.isEmpty,
              !email.isEmpty, !pass.isEmpty, pass.count >= 6 else{
                  alertUserLoginError()
                  return
              }
        
        // firebase Register account
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: pass, completion: { authResult, error in
            guard let result = authResult, error == nil else {
                print("Error creating User !!")
                return
            }
            
            let user = result.user
            
            print("Created User : \(user)")
        })
    }
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Error", message: "Please Enter all information to creat account", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    @IBAction func openGallery(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) ||
            UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            pickerVC = UIImagePickerController()
            pickerVC?.sourceType = .savedPhotosAlbum
            pickerVC?.delegate = self
            self.present(pickerVC!, animated: true, completion: nil)
            
            
        }
    }
    

}
extension RegisterVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.btnGallery.imageView?.contentMode = .scaleAspectFill
        self.btnGallery.setImage(image, for: .normal)
        imageSet = true
        
        
        dismiss(animated: true, completion: nil)
        print(image)
    }
//    func sendImageToFireBaes(image: UIImage) {
//        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
//
//        let ref = Storage.storage().reference(withPath: "/profil_picks/\(self.emailTF.text!).jpeg")
//        let userID = UUID().uuidString
//
//
//        let uploadImage = ref.putData(data, metadata: nil) { _ , error in
//            if let error = error {
//                print(error)
//            } else {
//                print("Image Uploaded ")
//            }
//
//            ref.downloadURL { imageURL, error in
//                if let error = error {
//                    print(error)
//                } else {
//                    print("Image URL: \(imageURL) ")
//                    let name = self.nameTF.text
//                    let age = self.ageTF.text
//                    let email = self.emailTF.text
//                    let pass = self.passTF.text
//
//                    if let name = name, let age = age , let email = email , let pass = pass {
//                        self.createUser(name: name, age: age, email: email, pass: pass, imageURL: imageURL?.absoluteString)
//                    }
//                }
//            }
//        }
//        uploadImage.resume()
//    }
}
