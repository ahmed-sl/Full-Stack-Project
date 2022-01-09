//
//  RegisterVC.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 01/06/1443 AH.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterVC: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
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
        
        spinner.show(in: view)
        // firebase Register account
        DatabaseManger.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                // user already exists
                strongSelf.alertUserLoginError(message: "Look like a user account for thet E-Mail already exists.")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: pass, completion: { authResult, error in
                
                guard  authResult != nil , error == nil else {
                    print("Error creating User !!")
                    strongSelf.alertUserLoginError(message: "Look like a user account for thet E-Mail already exists.")
                    return
                }
                
                let chatUser = ChatAppUser(firstName: fname,
                                          lastName: lname,
                                          email: email,
                                         age: age)
                
                
                UserDefaults.standard.setValue("\(fname) \(lname)", forKey: "name")
                DatabaseManger.shared.insertUser(with: chatUser,completion: {success in
                    if success {
                        // upload image
                        guard let image = strongSelf.btnGallery.imageView?.image,
                              let data = image.pngData() else {
                            return
                        }
                        let fileName = chatUser.profilePictureFileName
                        StrogeManger.sheard.uploadProfilePicture(with: data, fileName: fileName, completion: {result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(email, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storge Maneger error: \(error)")
                            }
                        })
                    }
                })
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
            
        })
        
        
    }
    func alertUserLoginError(message: String = "Please Enter all information to creat account"){
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
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

}
