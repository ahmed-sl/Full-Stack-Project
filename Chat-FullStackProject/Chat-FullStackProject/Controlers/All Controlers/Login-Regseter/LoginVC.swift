//
//  LoginVC.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 01/06/1443 AH.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginVC: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Log in"

    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        guard let email = emailTF.text, let pass = passTF.text,
              !email.isEmpty, !pass.isEmpty, pass.count >= 6 else {
                 alertUserLoginError()
                  return
              }
        
        spinner.show(in: view)
        
        // firebase Log in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: pass, completion: { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Filed Log in with email: \(email)  !!")
                return
            }
            
            let user = result.user
            
            let safeEmail = DatabaseManger.safeEmail(email: email)
            
            DatabaseManger.shared.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                    let firsName = userData["first_name"] as? String,
                    let lastName = userData["last_name"] as? String else {
                        return
                    }
                    UserDefaults.standard.set("\(firsName) \(lastName)", forKey: "name")
                case .failure(let error):
                    print("failed to reed data with error : \(error)")
                }
            })
            
            UserDefaults.standard.setValue(email, forKey: "email")
           
            
            print("Logged in User : \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
       
    }
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Error", message: "Please Enter all information to Log in", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    @IBAction func regsterBarBtn(_ sender: UIBarButtonItem) {
        print("hi")
        let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        print(vc)
        navigationController?.pushViewController(vc, animated: true)
        
        
        
       
    }
}
