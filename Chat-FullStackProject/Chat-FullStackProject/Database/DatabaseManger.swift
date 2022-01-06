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
    
    static func safeEmail(email: String) -> String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
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
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
            "age" : user.age
            
        ],withCompletionBlock: { error, _ in
            guard error == nil else {
                print("faild to write to the database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                if var usersCollision = snapshot.value as? [[String: String]] {
                    //append to users dic
                    let newElemnt = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                      ]
                    usersCollision.append(newElemnt)
                    self.database.child("users").setValue(usersCollision, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                } else {
                 //   creat that array
                    let newCollection : [[String: String]] = [
                    [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                      ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseErrors.failedToFetched))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseErrors: Error {
        case failedToFetched
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
    
    var profilePictureFileName : String {
        return "\(safeEmail)_profile_picture.png"
    }
}

