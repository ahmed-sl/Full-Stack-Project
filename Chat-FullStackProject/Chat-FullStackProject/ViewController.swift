//
//  ViewController.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 25/05/1443 AH.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
            createUser(name: "Ashish", age: 30)
            createUser(name: "Ahmed", age: 27)
            createUser(name: "Pulkit", age: 30)
        
        
    }
    func createUser(name:String, age:Int) {
            var user1:[String:Any] = ["name":name]
            let userID = UUID().uuidString
            user1["age"] = age
            
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


    }





