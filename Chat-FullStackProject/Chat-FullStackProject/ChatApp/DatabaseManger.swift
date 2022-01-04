//
//  DatabaseManger.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 01/06/1443 AH.
//

import Foundation
import FirebaseDatabase

final class DatabaseManger {
    
    static let shared = DatabaseManger()
    
    private let database = Database.database().reference()
    
    
}
// MARK: - Account Mangment
extension DatabaseManger {
    
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
            
        })
        
        
    }
    
    /// inserts new user to database
    public func insertUser(with user: ChatAppUser){
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
            "age" : user.age
            
        ])
    }
    
}

struct ChatAppUser {
    let firstName : String
    let lastName : String
    let email : String
    let age : String
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
//    let profilePicturUrl : String
}

