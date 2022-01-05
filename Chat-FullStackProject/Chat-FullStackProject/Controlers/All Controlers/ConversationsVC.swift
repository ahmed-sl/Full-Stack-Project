//
//  ConversationsVC.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 01/06/1443 AH.
//

import UIKit
import FirebaseAuth

class ConversationsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
}
