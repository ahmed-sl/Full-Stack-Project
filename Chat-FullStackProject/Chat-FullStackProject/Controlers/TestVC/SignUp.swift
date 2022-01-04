//
//  SignUp.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 26/05/1443 AH.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class SignUp: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    
    @IBOutlet weak var btnGallery: UIButton!
    var pickerVC : UIImagePickerController?
    
    var imageSet = false
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    func createUser(name:String, age:String, email:String, pass:String, imageURL: String? = nil) {
            var user1:[String:Any] = ["name":name,"age":age,"email":email,"pass":pass]
            let userID = UUID().uuidString
        
        
            if let imageURL = imageURL {
                user1["Profile_Image"] = imageURL
            }
            //1. Create Database reference
            var ref: DatabaseReference!
            ref = Database.database().reference()
            //ref.child("users").setValue(userDict) // dont do this
            
            //2. Get the user object from firebase database
            ref.child("users").observeSingleEvent(of: .value) { snapshot in
                print("snapshot Value: \(snapshot.value!)")
                
                if var allUserDict = snapshot.value as? [String:Any] { // important
                    print("database has values, updating the user")
                    
                    
                    // 3. Update the user dictionary with new user object
                    allUserDict[userID] = user1
                    
                    //4. Send the dictionary to firebase
                    ref.child("users").updateChildValues([userID:user1])
                } else {
                    print("Empty databse, set the user")
                    let allUserDict = [userID:user1]
                    // Database is empty
                    ref.child("users").setValue(allUserDict)
                }
            }
        }

    @IBAction func register(_ sender: Any) {
        let name = nameTF.text
        let age = ageTF.text
        let email = emailTF.text
        let pass = passTF.text
        
        if let name = name, let age = age , let email = email , let pass = pass {
            if imageSet,
               let image = btnGallery.imageView?.image {
                sendImageToFireBaes(image: image)
            } else {
                createUser(name: name, age: age, email: email, pass: pass)
            }
        }
        let nav = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        nav.name = name
        nav.age = age
        nav.email = email
        nav.imgagPro = btnGallery.imageView?.image
        self.navigationController?.pushViewController(nav, animated: true)
        
        
        
        
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

extension SignUp : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.btnGallery.imageView?.contentMode = .scaleAspectFill
        self.btnGallery.setImage(image, for: .normal)
        imageSet = true
        
        
        dismiss(animated: true, completion: nil)
        print(image)
    }
    func sendImageToFireBaes(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        
        let ref = Storage.storage().reference(withPath: "/profil_picks/\(self.emailTF.text!).jpeg")
        let userID = UUID().uuidString
        
        
        let uploadImage = ref.putData(data, metadata: nil) { _ , error in
            if let error = error {
                print(error)
            } else {
                print("Image Uploaded ")
            }
            
            ref.downloadURL { imageURL, error in
                if let error = error {
                    print(error)
                } else {
                    print("Image URL: \(imageURL) ")
                    let name = self.nameTF.text
                    let age = self.ageTF.text
                    let email = self.emailTF.text
                    let pass = self.passTF.text
                    
                    if let name = name, let age = age , let email = email , let pass = pass {
                        self.createUser(name: name, age: age, email: email, pass: pass, imageURL: imageURL?.absoluteString)
                    }
                }
            }
        }
        uploadImage.resume()
    }
}
