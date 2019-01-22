//
//  SearchResultCell.swift
//  FlickrSearch
//
//  Created by Andy Stef on 12/09/18.
//  Copyright (c) 2018 Andy Stef. All rights reserved.
//

import Foundation
import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet private weak var resultTitleLabel: UILabel!
    @IBOutlet private weak var resultImageView: UIImageView!
    
    func setupWithPhoto(flickrPhoto: FlickrPhoto) {
        resultTitleLabel.text = flickrPhoto.title
        guard let url = flickrPhoto.photoUrl as URL? else {
            return
        }
        
        resultImageView.sd_setImage(with: url)
    }
}
