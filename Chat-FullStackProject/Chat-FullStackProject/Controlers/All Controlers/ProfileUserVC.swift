//
//  ProfileUserVC.swift
//  Chat-FullStackProject
//
//  Created by Ahmed.sl on 01/06/1443 AH.
//

import UIKit
import FirebaseAuth

class ProfileUserVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let data = ["Log Out"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self

       
    }
}

extension ProfileUserVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheat = UIAlertController(title: "Are you sure you want to Log Out",
                                            message: "",
                                            preferredStyle: .actionSheet)
        actionSheat.addAction(UIAlertAction(title: "Log Out", style: .destructive,
                                            handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: false)
            }catch {
                print("Faild to Log out !!")
            }
            
        }))
        actionSheat.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheat, animated: true)
        
       
    }
}
