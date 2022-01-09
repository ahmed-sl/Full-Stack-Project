//
//  ChatVS.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 02/06/1443 AH.
//

import UIKit
import MessageKit
import InputBarAccessoryView


struct Message: MessageType {
  public var sender: SenderType
  public var messageId: String
  public var sentDate: Date
  public var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributd_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

class ChatVS: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public let otherUserEmail : String
    private let conversationsId : String?
    public var isNewConversation = true

    private var message = [Message]()
    
    private var selfSender: Sender?  {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
        
        let safeEmail = DatabaseManger.safeEmail(email: email)
        
        return Sender(photoURL: "",
                senderId: safeEmail,
                displayName: "me")
    }
    
    
    init(with email: String, id: String?) {
        self.conversationsId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        messageInputBar.inputTextView.becomeFirstResponder()
        
        if let conversationsId = conversationsId {
            listenForMessages(id: conversationsId, shuoldScroleToBottom: true)
        }
    }
    private func listenForMessages(id: String, shuoldScroleToBottom: Bool) {
        DatabaseManger.shared.getAllMessageForConverstion(with: id, completion: { [weak self] result in
            switch result {
            case .success(let message):
                guard !message.isEmpty else {
                    return
                }
                self?.message = message
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shuoldScroleToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
            case .failure(let error):
                print("faild to get messages :\(error)")
            }
            
        })
    }
}

extension ChatVS : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageId = createMessageId() else { return }
        
        
        print("Sending : \(text)")
        
        print("the messageId is : \(messageId)")

        // send message
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        if isNewConversation {
            // creat a new converstion
            
            DatabaseManger.shared.creatNewConverstions(with: otherUserEmail, name: self.title ?? "User" , firstMessage: message, completion: { [weak self] success in
                if success {
                    print("Message send")
                    self?.isNewConversation = false
                }else {
                    print("faild to Send Message !!")
                }
            })
        } else {
            // append to existiong converstion data
            guard let conversationsId = conversationsId, let name = self.title else {
                return
            }
            
            DatabaseManger.shared.sendMessage(to: conversationsId,otherUserEmail: "otherUserEmail", name: name, newMessage: message, completion: { succss in
                if succss {
                    print("message sent")
                } else {
                    print("faild to send")
                }
            })
        }
    }
    
    private func createMessageId() -> String? {
       
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
        
        let safeEmail = DatabaseManger.safeEmail(email: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeEmail)_\(dateString)"
        print("created message id :\(newIdentifier) ")
        return newIdentifier
    }
}

extension ChatVS : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil , email shuold be cathed !!")
        
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return message[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return message.count
    }
    
    
}
