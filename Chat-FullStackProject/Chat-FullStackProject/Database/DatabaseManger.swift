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

extension DatabaseManger {
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void){
        self.database.child("\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let vale = snapshot.value else {
                completion(.failure(DatabaseErrors.failedToFetched))
                return
            }
            completion(.success(vale))
        })
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
//  MARK: - Sending messages / converstion
extension DatabaseManger {
    
    public func creatNewConverstions(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void ){

        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
        let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        let safeEmail = DatabaseManger.safeEmail(email: currentEmail)
        print("safeEmail is :\(safeEmail)")
        
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { [weak self] snabshot in
            guard var userNode = snabshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let messgeDarta = firstMessage.sentDate
            let dateString = ChatVS.dateFormatter.string(from: messgeDarta)
            var message = ""

            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }

            let converstionID = "converstion_\(firstMessage.messageId)"
            let newConverstionData: [String:Any] = [
                "id": converstionID,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date":dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            let recipient_newConverstionData: [String:Any] = [
                "id": converstionID,
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date":dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            // uodate the recipient user
            
            self?.database.child("\(otherUserEmail)/converstions").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var converstions = snapshot.value as? [[String: Any]] {
                    // append
                    converstions.append(recipient_newConverstionData)
                    self?.database.child("\(otherUserEmail)/converstions").setValue([converstions])

                } else {
                    // create
                    self?.database.child("\(otherUserEmail)/converstions").setValue([recipient_newConverstionData])
                }
            })
            
            
            
            // update the current user
            if var converstions = userNode["converstions"] as? [[String: Any]] {
                // converstion exists
                converstions.append(userNode)
                userNode["converstions"] = converstions
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConverstions(name: name,
                                                     converstionsID: converstionID,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
                
            }else {
                // create arry for converstiond
                userNode["converstions"] = [
                    newConverstionData
                ]
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConverstions(name: name,
                                                     converstionsID: converstionID,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                  
                })
                
            }
        })
                
        }
    
    private func finishCreatingConverstions(name: String, converstionsID: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        
        
        let messgeDarta = firstMessage.sentDate
        let dateString = ChatVS.dateFormatter.string(from: messgeDarta)
        
        var message = ""

        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManger.safeEmail(email: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
                    "content": message,
                    "date": dateString,
                    "sender_email": currentUserEmail,
                    "is_read": false,
                    "name": name
              ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("\(converstionsID)").setValue(value, withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
                                       
    
    
    public func getAllConvertion(for email: String, completion: @escaping (Result<[Converstion], Error>) -> Void ){
        database.child("\(email)/converstions").observe(.value, with: {
                    snapshot in
                    guard let value = snapshot.value as? [[String: Any]] else {
                        completion(.failure(DatabaseErrors.failedToFetched))
                        return
                    }
                    
                    let conversations : [Converstion] = value.compactMap({
                        dictonary in
                        guard let id = dictonary["id"] as? String,
                              let otherEmail = dictonary["other_user_email"] as? String,
                              let latestMessage = dictonary["latest_message"] as? [String:Any],
                              let isRead = latestMessage["is_read"] as? Bool,
                              let date = latestMessage["date"] as? String,
                              let message = latestMessage["message"] as? String else {
                            return nil
                        }
                        
                        let messageObj = LatesMessage(date: date, text: message, isRead: isRead)
                        
                        return Converstion(id: id, otherUserEmail: otherEmail, letesMessage: messageObj)
                        //(id: id, name: name, otherUserEmail: otherEmail, letesMessage: messageObj)
                    })
                    
                    completion(.success(conversations))
                })
            }
    
    // let name = dictonary["name"] as? String,
    
    public func getAllMessageForConverstion(with id: String, completion: @escaping (Result<[Message], Error>) -> Void ){
        database.child("\(id)/messages").observe(.value, with: {
                    snapshot in
                    guard let value = snapshot.value as? [[String: Any]] else {
                        completion(.failure(DatabaseErrors.failedToFetched))
                        return
                    }
                    
                    let messages : [Message] = value.compactMap({
                        dictonary in
                        guard let name = dictonary["name"] as? String,
                        let isRead = dictonary["is_read"] as? Bool,
                        let messageId = dictonary["id"] as? String,
                        let content = dictonary["content"] as? String,
                        let senderEmail = dictonary["sender_email"] as? String,
                        let type = dictonary["type"] as? String,
                        let dateString = dictonary["date"] as? String,
                        let date = ChatVS.dateFormatter.date(from: dateString) else {
                            return nil
                            
                        }
                        let sender = Sender(photoURL: "",
                                            senderId: senderEmail,
                                            displayName: name)
                        
                        return Message(sender: sender,
                                       messageId: messageId,
                                       sentDate: date,
                                       kind: .text(content))
                    })
                    
            completion(.success(messages))
                })
            }
    
    public func sendMessage(to converstion: String,otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void ){
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let currentEmail = DatabaseManger.safeEmail(email: myEmail)
        
        database.child("\(converstion)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            let messgeDarta = newMessage.sentDate
            let dateString = ChatVS.dateFormatter.string(from: messgeDarta)
            
            var message = ""

            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManger.safeEmail(email: myEmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                        "content": message,
                        "date": dateString,
                        "sender_email": currentUserEmail,
                        "is_read": false,
                        "name": name
                  ]
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(converstion)/messages").setValue(currentMessages,
                                                                          withCompletionBlock: {error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                strongSelf.database.child("\(currentEmail)/converstions").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentUserConverstion = snapshot.value as? [[String:Any]] else {
                        completion(false)
                        return
                    }
                    
                    for converstions in currentUserConverstion {
                        if let currentId = converstions["id"] as? String, currentId == converstion {
                            
                        }
                    }
                })
                
                completion(true)
            })
        })
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



