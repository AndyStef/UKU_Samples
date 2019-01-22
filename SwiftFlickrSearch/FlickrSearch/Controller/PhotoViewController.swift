//
//  PhotoViewController.swift
//  FlickrSearch
//
//  Created by Andy Stef on 12/09/18.
//  Copyright (c) 2018 Andy Stef. All rights reserved.
//

import Foundation

class PhotoViewController: UIViewController {
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    var flickrPhoto: FlickrPhoto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImage()
    }
    
    private func setupImage() {
        guard let url = flickrPhoto?.photoUrl as URL? else {
            return
        }
        
        photoImageView.sd_setImage(with: url)
    }
}
