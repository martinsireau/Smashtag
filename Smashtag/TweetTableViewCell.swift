//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Martin SIREAU on 2/2/17.
//  Copyright © 2017 Martin SIREAU. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    
    var tweet:Twitter.Tweet?{
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        if let tweet = self.tweet {
            
            let newText = NSMutableAttributedString(string: tweet.text)
            let pictureEmoji = NSMutableAttributedString(string: "📷")
            
            func changeColor(indexedKey: [Tweet.IndexedKeyword], colorValue: UIColor) {
                for eachValue in indexedKey {
                    newText.addAttribute(NSForegroundColorAttributeName, value: colorValue, range: eachValue.nsrange)
                }
            }
            
            changeColor(indexedKey: tweet.userMentions, colorValue: UIColor(red: 0.88, green: 0.14, blue: 0.37, alpha: 1))
            changeColor(indexedKey: tweet.urls, colorValue: UIColor(red:0.95, green:0.71, blue:0.38, alpha:1.0))
            changeColor(indexedKey: tweet.hashtags, colorValue: UIColor(red: 0.11, green: 0.63, blue: 0.95, alpha: 1))
            
            if !tweet.media.isEmpty {
                newText.append(pictureEmoji)
            }

            tweetTextLabel?.attributedText = newText
            
            tweetScreenNameLabel?.text = "\(tweet.user!)"
            
            if let profileImageURL = tweet.user.profileImageURL {
                let lastProfileImageURL = profileImageURL
                DispatchQueue.global(qos: .userInteractive).async {
                    if let imageData = NSData(contentsOf: profileImageURL as URL) {
                        DispatchQueue.main.async { [weak weakSelf = self] in
                            if profileImageURL == lastProfileImageURL {
                                weakSelf?.tweetProfileImageView?.image = UIImage(data: imageData as Data)
                            }
                        }
                    }
                }
            }
            
            let formatter = DateFormatter()
            if NSDate().timeIntervalSince(tweet.created as Date) > 24*60*60 {
                formatter.dateStyle = DateFormatter.Style.short
            } else {
                formatter.timeStyle = DateFormatter.Style.short
            }
            tweetCreatedLabel?.text = formatter.string(from: tweet.created as Date)
        }
    }
}

