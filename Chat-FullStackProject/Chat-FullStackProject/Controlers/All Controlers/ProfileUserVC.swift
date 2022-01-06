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
        tableView.tableHeaderView = creatTableViewHeader()

    }
    
    func creatTableViewHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
    
        let safeEmail = DatabaseManger.safeEmail(email: email)
        let fileName = "\(safeEmail)_profile_picture.png"
        let path = "images/"+fileName
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width , height: 300))
        
        headerView.backgroundColor = .link
        
        let imageview = UIImageView(frame: CGRect(x: (view.width-150) / 2 ,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        
        imageview.contentMode = .scaleAspectFill
        imageview.backgroundColor = .white
        imageview.layer.backgroundColor = UIColor.white.cgColor
        imageview.layer.borderWidth = 3
        imageview.layer.masksToBounds = true
        headerView.addSubview(imageview)
        
        
        
        StrogeManger.sheard.downlodURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: imageview, url: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        
        return headerView
    }
    func downloadImage(imageView: UIImageView, url: URL){
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }

        }).resume()
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
