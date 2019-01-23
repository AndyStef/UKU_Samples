/// Copyright (c) 2019 Razeware LLC


import UIKit

// This enum contains all the possible states a photo record can be in
enum PhotoRecordState {
    case new
    case downloaded
    case filtered
    case failed
}

class PhotoRecord {
    let name: String
    let url: URL
    var state = PhotoRecordState.new
    var image = UIImage(named: "Placeholder")
    
    init(name:String, url:URL) {
        self.name = name
        self.url = url
    }
}
