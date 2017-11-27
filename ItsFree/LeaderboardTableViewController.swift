//
//  LeaderboardTableViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-27.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit



class LeaderboardTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    
    
    
    
    @IBOutlet weak var leaderboardTableView: UITableView!
    
    
    @IBAction func dismissLeaderboard(_ sender: UIBarButtonItem) {
    
        self.dismiss(animated: true, completion: nil)
        }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppData.sharedInstance.onlineUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardTableViewCell", for: indexPath)
        
        cell.textLabel?.text = AppData.sharedInstance.onlineUsers[indexPath.row].name
        
        return cell
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReadFirebaseData.readUsers()
        
        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self

        // Do any additional setup after loading the view.
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
