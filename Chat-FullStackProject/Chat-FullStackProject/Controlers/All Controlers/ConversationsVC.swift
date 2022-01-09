//
//  ConversationsVC.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 01/06/1443 AH.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct Converstion {
    let id: String
    let name:String
    let otherUserEmail: String
    let letesMessage: LatesMessage
}

struct LatesMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class ConversationsVC: UIViewController {
    
    private let spiner = JGProgressHUD(style: .dark)
    
    private var conversations = [Converstion]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConverstionTableViewCell.self,
                       forCellReuseIdentifier: ConverstionTableViewCell.identifier)
        return table
    }()
    
    private let noConverationsLabel : UILabel = {
        let label = UILabel()
        label.text = "No Converations !!"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let email = UserDefaults.standard.value(forKey: "email") as? String
        let emnail = UserDefaults.standard.value(forKey: "name") as? String
        
       

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTabComosButten))
        view.addSubview(tableView)
        view.addSubview(noConverationsLabel)
        setupTableView()
        fetchConverations()
        startListeningForConverstions()
       
    }
    
    private func startListeningForConverstions(){
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print("starting converstion fetching....")
        let safeEmail = DatabaseManger.safeEmail(email: email)
        DatabaseManger.shared.getAllConvertion(for: safeEmail, completion: {[weak self] result in
            
            switch result {
            case .success(let conversations):
                print("successfuly get the converstion models")
                print("the conversations : \(conversations)")
                
                guard !conversations.isEmpty else {
                    return
                }
                
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("falid to get all data \(error)")
            }
        })
    }
    
    @objc private func didTabComosButten() {
        let vc = NewConversationsVC()
        vc.completion = { [weak self ] result in
            print("\(result)")
            self?.creatNewConverstions(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func creatNewConverstions(result: [String:String]) {
        guard let name = result["name"], let email = result["email"] else {
            return
            
        }
        
        let vc = ChatVS(with: email, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
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
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConverations() {
        tableView.isHidden = false
    }
    
}

extension ConversationsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConverstionTableViewCell.identifier,
                                                 for: indexPath) as! ConverstionTableViewCell
        cell.configure(with: model)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        
        let vc = ChatVS(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
}
