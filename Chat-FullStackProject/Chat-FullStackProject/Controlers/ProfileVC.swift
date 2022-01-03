//
//  ProfileVC.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 30/05/1443 AH.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var nameProfile: UILabel!
    @IBOutlet weak var ageProfile: UILabel!
    @IBOutlet weak var emailProfile: UILabel!
    
    var name: String?
    var age: String?
    var email: String?
    var imgagPro: UIImage?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let name = name, let age = age, let email = email, let imgagPro = imgagPro {
            nameProfile.text = "Name: \(name)"
            ageProfile.text = "Age: \(age)"
            emailProfile.text = "E-Mail: \(email)"
            imageProfile.image = imgagPro
        }
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
