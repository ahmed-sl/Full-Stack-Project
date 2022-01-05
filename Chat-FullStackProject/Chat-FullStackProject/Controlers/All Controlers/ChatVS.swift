//
//  ChatVS.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 02/06/1443 AH.
//

import UIKit
import MessageKit


struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

class ChatVS: MessagesViewController {

    private var message = [Message]()
    
    private let selfSender = Sender(photoURL: "",
                                    senderId: "1",
                                    displayName: "ahmed")
    override func viewDidLoad() {
        super.viewDidLoad()

        message.append(Message(sender: selfSender,
                               messageId: "1",
                               sentDate: Date(),
                               kind: .text("Hello world message")))
        
        message.append(Message(sender: selfSender,
                               messageId: "1",
                               sentDate: Date(),
                               kind: .text("Hello world message. Hello world message  Hello world messageHello world messageHello world message ")))
        
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
       
    }

}

extension ChatVS : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return message[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return message.count
    }
    
    
}
