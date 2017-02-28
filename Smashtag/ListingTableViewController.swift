//
//  ListingTableViewController.swift
//  Smashtag
//
//  Created by Martin SIREAU on 2/6/17.
//  Copyright © 2017 Martin SIREAU. All rights reserved.
//

import UIKit
import Twitter

class ListingTableViewController: UITableViewController {
    
    var myTweet : Tweet?{
        didSet {
            var newTab = [AnyObject]()
            for item in (myTweet?.media)! {
                newTab.append(item as AnyObject)
            }
            fillSectionAndRows(indexedKey: (myTweet?.hashtags)!, sectionId: "Hashtags")
            fillSectionAndRows(indexedKey: (myTweet?.userMentions)!, sectionId: "Users")
            fillSectionAndRows(indexedKey: (myTweet?.urls)!, sectionId: "Urls")
            if !newTab.isEmpty {
                sections.insert("Images", at: 0)
                items.insert(newTab, at: 0)
            }
        }
    }
    
    var sections = [String]()
    var items = [[AnyObject]]()
    var isMediaItem = false
    var newHeight : CGFloat = 0
    
    private func fillSectionAndRows(indexedKey: [Tweet.IndexedKeyword], sectionId: String) {
        var myArray = [AnyObject]()
        for item in indexedKey {
            myArray.append(item.keyword as AnyObject)
        }
        if !myArray.isEmpty {
            items.append(myArray)
            sections.append(sectionId)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isMediaItem
        {
            return newHeight
        }
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].count
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.tableView.reloadData()
    }
    
    private struct Storyboard {
        static let MyTableCell = "myTableCell"
        static let BackToSearch = "backToSearch"
        static let ShowImage = "showImage"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.MyTableCell, for: indexPath)
        let myData = self.items[indexPath.section][indexPath.row]
        if let myDataCell = cell as? ListingTableViewCell {
            myDataCell.myData = myData
            isMediaItem = myDataCell.isMediaItem
            newHeight = cell.frame.size.width/myDataCell.aspectRatio
        }
        return cell
    }
    
    override func viewDidLoad() {
        self.title = myTweet?.user.name;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let myStringData = self.items[indexPath.section][indexPath.row] as? String,
            myStringData.characters.first == "h"{
            let url = URL(string: myStringData)
            UIApplication.shared.open(url!)
        } else if let myString = self.items[indexPath.section][indexPath.row] as? String {
            self.performSegue(withIdentifier: Storyboard.BackToSearch, sender: myString)
        } else if let myImage = self.items[indexPath.section][indexPath.row] as? MediaItem{
            self.performSegue(withIdentifier: Storyboard.ShowImage, sender: myImage)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
            identifier == Storyboard.BackToSearch,
            let myString = sender as? String,
            let segueToMVC = segue.destination as? TweetTableViewController {
            segueToMVC.searchText = myString
        } else if let identifier = segue.identifier,
            identifier == Storyboard.ShowImage,
            let myImage = sender as? MediaItem,
            let segueToMVC = segue.destination as? ImageViewController {
            segueToMVC.imageURL = myImage.url as URL?
        }
    }
}
