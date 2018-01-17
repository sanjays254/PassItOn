//
//  LeaderboardTableViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-27.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import FirebaseStorage



class LeaderboardTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    let myDowloadCompletedNotificationKey = "myDownloadNotificationKey"
    
    
    
    @IBOutlet weak var leaderboardTableView: UITableView!
    
    
    @IBAction func dismissLeaderboard(_ sender: UIBarButtonItem) {
    
        self.dismiss(animated: true, completion: nil)
        }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppData.sharedInstance.onlineUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sortedUsers = AppData.sharedInstance.onlineUsers.sorted(by: { $0.rating > $1.rating })
        
        
        let storageRef = Storage.storage().reference()
        let photoRef: String = sortedUsers[indexPath.row].profileImage
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardTableViewCell", for: indexPath) as! LeaderboardTableViewCell
        
        
        if(sortedUsers[indexPath.row].UID == AppData.sharedInstance.currentUser?.UID){
            cell.nameLabel.text = "You"
            cell.layer.borderWidth = 3.0
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.cornerRadius = 5.0
            
        }
        else {
            cell.nameLabel.text = sortedUsers[indexPath.row].name
        }
        
        if(indexPath.row == 0){
            let crownImageView = UIImageView(image: #imageLiteral(resourceName: "crown"))
            crownImageView.frame = CGRect(x: -8, y: -12, width: 30, height: 20)
            cell.positionLabel.addSubview(crownImageView)
            cell.positionLabel.text = ""
        }
        else { cell.positionLabel.text = String(indexPath.row+1) }
        
        cell.profileImageView.sd_setImage(with: storageRef.child(photoRef), placeholderImage: UIImage.init(named: "userImage"))
        //print("Storage Location: \(storageRef.child(previewPhotoRef))")
        //cell.profileImageView.image = sortedUsers[indexPath.row].profileImage
        cell.ratingLabel.text = String(sortedUsers[indexPath.row].rating)
        
        return cell
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReadFirebaseData.readUsers()

       NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: myDowloadCompletedNotificationKey), object: nil)
        
        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
        leaderboardTableView.rowHeight = 80

        
        // Do any additional setup after loading the view.
    }
    
    @objc func reload(){
        leaderboardTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
