//
//  MostRecentTableViewController.swift
//  Smashtag
//
//  Created by Martin SIREAU on 2/17/17.
//  Copyright © 2017 Martin SIREAU. All rights reserved.
//

import UIKit

class MostRecentTableViewController: UITableViewController {
    
    @IBAction func myTrash(_ sender: Any) {
        let myTweet = TweetTableViewController() //refacto
        myTweet.defaults.removeObject(forKey: "SavedArray")
        myPreviousSearch.removeAll()
        tableView.reloadData()
    }
    
    var myPreviousSearch = [String](){
        didSet{
            tableView.reloadData()
        }
    }
    
    var myCell = UITableViewCell()

    private struct Storyboard {
        static let RecentTweet = "recentTweet"
        static let MyMRTSegue = "myMRTSegue"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPreviousSearch.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.RecentTweet, for: indexPath)
        cell.textLabel?.text = self.myPreviousSearch[indexPath.row]
        myCell = cell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let myTweet = TweetTableViewController() //refacto
            self.myPreviousSearch.remove(at: indexPath.row)//refacto
            myTweet.previousSearch.remove(at: indexPath.row)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
            identifier == Storyboard.MyMRTSegue,
            let senderType = sender as? UITableViewCell,
            let senderText = senderType.textLabel?.text,
            let segueToMVC = segue.destination as? TweetTableViewController {
            segueToMVC.searchText = senderText
        }
    }
}
