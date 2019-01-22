//
//  FlickrAPI.swift
//  FlickrSearch
//
//  Created by Andy Stef on 12/09/18.
//  Copyright (c) 2018 Andy Stef. All rights reserved.
//

import Foundation

class FlickrProvider {
    
    typealias FlickrResponse = (NSError?, [FlickrPhoto]?) -> Void
    
    private struct Keys {
        static let flickrKey = "edfbda1311ced294eafbfb8960b97bf4"
    }
    
     struct Errors {
        static let invalidAccessErrorCode = 100
    }
    
    class func fetchPhotosForSearchText(searchText: String, completion: @escaping FlickrResponse) -> Void {
        guard let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters:.urlHostAllowed)  else {
            // here should completion with custom error
            return
        }
        
        let urlString: String = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Keys.flickrKey)&tags=\(escapedSearchText)&per_page=25&format=json&nojsoncallback=1"
        
        guard let url = URL(string: urlString) else {
            // here should completion with custom error
            return
        }
        
        let urlSession = URLSession.shared
        let searchTask = urlSession.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                print("Error fetching photos: \(error)")
                completion(error as NSError?, nil)
                return
            }
            
            do {
                let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                guard let results = resultsDictionary else { return }
                
                if let statusCode = results["code"] as? Int {
                    if statusCode == Errors.invalidAccessErrorCode {
                        let invalidAccessError = NSError(domain: "com.flickr.api", code: statusCode, userInfo: nil)
                        completion(invalidAccessError, nil)
                        return
                    }
                }
                
                guard let photosContainer = resultsDictionary!["photos"] as? NSDictionary else { return }
                guard let photosArray = photosContainer["photo"] as? [NSDictionary] else { return }
                
                let flickrPhotos: [FlickrPhoto] = photosArray.map { photoDictionary in
                    
                    let photoId = photoDictionary["id"] as? String ?? ""
                    let farm = photoDictionary["farm"] as? Int ?? 0
                    let secret = photoDictionary["secret"] as? String ?? ""
                    let server = photoDictionary["server"] as? String ?? ""
                    let title = photoDictionary["title"] as? String ?? ""
                    
                    let flickrPhoto = FlickrPhoto(photoId: photoId, farm: farm, secret: secret, server: server, title: title)
                    return flickrPhoto
                }
                
                completion(nil, flickrPhotos)
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                completion(error, nil)
                return
            }
        })
        searchTask.resume()
    }
}
