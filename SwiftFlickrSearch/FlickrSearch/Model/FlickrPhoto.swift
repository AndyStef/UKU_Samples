//
//  SearchResult.swift
//  FlickrSearch
//
//  Created by Andy Stef on 12/09/18.
//  Copyright (c) 2018 Andy Stef. All rights reserved.
//

import Foundation
import UIKit

struct FlickrPhoto {
    let photoId: String
    let farm: Int
    let secret: String
    let server: String
    let title: String
    
    var photoUrl: NSURL {
        return NSURL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret)_m.jpg")!
    }
}
