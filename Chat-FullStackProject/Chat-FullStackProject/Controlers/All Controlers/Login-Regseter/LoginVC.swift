//
//  LoginVC.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 01/06/1443 AH.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
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
        // firebase Log in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: pass, completion: { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            guard let result = authResult, error == nil else {
                print("Filed Log in with email: \(email)  !!")
                return
            }
            
            let user = result.user
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
