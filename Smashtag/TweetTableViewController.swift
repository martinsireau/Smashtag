 //
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Martin SIREAU on 2/2/17.
//  Copyright © 2017 Martin SIREAU. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var tweets = [Array<Twitter.Tweet>](){
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBAction func rewindToRoot(_ sender: Any) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    var previousSearch : [String] {
        get {
            return defaults.object(forKey: "SavedArray") as? [String] ?? []
        } set {
            if newValue.count > 100 {
                self.previousSearch.removeLast()
            }
            mrtvc.myPreviousSearch = newValue
            defaults.set(newValue, forKey: "SavedArray")
        }
    }
    
    var defaults = UserDefaults.standard
    private var mrtvc = MostRecentTableViewController()
    
    var searchText : String? {
        didSet {
            tweets.removeAll()
            searchForTweets()
            title = searchText
            previousSearch.insert(searchText!, at: 0)
        }
    }

    private var twitterRequest: Twitter.TwitterRequest? {
        if let query = searchText, !query.isEmpty{
            return Twitter.TwitterRequest(search: query + " -filter:retweets", count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.TwitterRequest?
    
    private func searchForTweets() {
        if let request = twitterRequest {
            let lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                DispatchQueue.main.async {
                    if request === lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, at: 0)
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let nc = self.tabBarController?.viewControllers?[1] as? UINavigationController,
            let secondTab = nc.topViewController as? MostRecentTableViewController {
            mrtvc = secondTab
            mrtvc.myPreviousSearch = previousSearch
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        if title == nil {
            title = "Enter a tag to search"
        }
        if let vc = self.navigationController?.viewControllers[0], vc == self {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func refresh(refreshControl: UIRefreshControl){
        searchForTweets()
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
        // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }
    
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
        static let ShowListOfKeywords = "showListOfKeywords"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetCellIdentifier, for: indexPath)
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell{
            tweetCell.tweet = tweet
        }
        return cell
    }
   
    @IBOutlet weak var searchTextField: UITextField!{
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
            identifier == Storyboard.ShowListOfKeywords,
            let cell = sender as? TweetTableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let segueToMVC = segue.destination as? ListingTableViewController {
            segueToMVC.myTweet = tweets[indexPath.section][indexPath.row]
        }
    }
}
