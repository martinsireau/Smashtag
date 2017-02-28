//
//  imageTableViewCell.swift
//  Smashtag
//
//  Created by Martin SIREAU on 2/15/17.
//  Copyright © 2017 Martin SIREAU. All rights reserved.
//

import UIKit
import Twitter

class ListingTableViewCell: UITableViewCell {

    @IBOutlet weak var imageEmplacement: UIImageView!
    
    var myData: AnyObject?{
        didSet{
            updateUI()
        }
    }
    
    var isMediaItem = false
    var aspectRatio : CGFloat = 0
    
    private func updateUI(){
        
        self.textLabel?.text = nil
        self.imageView?.image = nil
        imageEmplacement?.image = nil
        
        if let myData = self.myData {
            if let myStringData = myData as? String{
                isMediaItem = false
                self.textLabel?.text = myStringData
            } else if let myImageData = myData as? MediaItem{
                isMediaItem = true
                aspectRatio = CGFloat(myImageData.aspectRatio)
                let lastImageDataURL = myImageData.url
                DispatchQueue.global(qos: .userInteractive).async {
                    if let imageData = NSData(contentsOf: myImageData.url as URL) {
                        DispatchQueue.main.async { [weak weakSelf = self] in
                            if myImageData.url == lastImageDataURL {
                                weakSelf?.imageEmplacement?.image = UIImage(data: imageData as Data)
                            }
                        }
                    }
                }
            }
        }
    }
}
