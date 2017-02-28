//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Martin SIREAU on 2/17/17.
//  Copyright © 2017 Martin SIREAU. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate{
    
    var imageURL: URL? {
        didSet {
            fetchImage()
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.5
            scrollView.maximumZoomScale = 2.0
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private var imageView = UIImageView()
    
    private var image: UIImage?{
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
        } get {
            return imageView.image
        }
    }

    private func fetchImage() {
        if let url = imageURL {
            let lastImageURL = url
            DispatchQueue.global(qos: .userInteractive).async {
                if url == lastImageURL {
                    if let imageData = NSData(contentsOf: url){
                        DispatchQueue.main.async { [weak weakSelf = self] in
                            weakSelf?.image = UIImage(data: imageData as Data)
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Zooming View"
        scrollView.addSubview(imageView)
        scrollView?.contentSize = imageView.frame.size
    }
}
