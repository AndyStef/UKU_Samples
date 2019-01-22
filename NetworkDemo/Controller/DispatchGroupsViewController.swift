//
//  DispatchGroupsViewController.swift
//  NetworkDemo
//
//  Created by Andriy Stefanchuk on 1/22/19.
//  Copyright © 2019 AS. All rights reserved.
//

import UIKit

class DispatchGroupsViewController: UIViewController {
    
    @IBOutlet private weak var firstImageView: UIImageView!
    @IBOutlet private weak var secondImageView: UIImageView!
    @IBOutlet private weak var thirdImageView: UIImageView!
    @IBOutlet private weak var fourthImageView: UIImageView!
    @IBOutlet private var imageViews: [UIImageView]!
    
    private let imageURLs = [
        "http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg",
        "http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg",
        "http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg",
        "http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg",
        
        "http://adriatic-lines.com/wp-content/uploads/2015/04/canal-of-Venice.jpg",
        "http://bestkora.com/IosDeveloper/wp-content/uploads/2016/12/Screen-Shot-2017-01-17-at-9.33.52-PM.png",
        "http://www.picture-newsletter.com/arctic/arctic-12.jpg"
    ]
    
    @IBAction func download(_ sender: Any) {
        imageViews.forEach { $0.image = nil }
//        loadUsingDispatchGroup()
//        loadUsingDispatchGroup1()
//        withoutBackground()
//        differentQoS()
        syncQueue()
    }
    
    // Data(contestOf: URL)
    private func loadUsingDispatchGroup() {
        let imageGroup = DispatchGroup()
        
        for i in 0...3 {
            let start = Date()
            imageGroup.enter()
            DispatchQueue.global().async {
                guard let imageURL = URL(string: self.imageURLs[i]),
                    let data = try? Data(contentsOf: imageURL) else {
                        imageGroup.leave()
                        return
                }
                
                DispatchQueue.main.async {
                    self.imageViews[i].image = UIImage(data: data)
                    let finish = Date()
                    let timeNeeded = finish.timeIntervalSince(start)
                    print("Time needed \(timeNeeded)")
                    imageGroup.leave()
                }
            }
        }
        
        imageGroup.notify(queue: .main) {
            print("All work is done!")
        }
    }
    
    // URLSession.dataTask
    private func loadUsingDispatchGroup1() {
        let imageGroup = DispatchGroup()
        
        for i in 0...3 {
            let start = Date()
            imageGroup.enter()
            guard let imageURL = URL(string: self.imageURLs[i]) else {
                imageGroup.leave()
                return
            }
            
            let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
                DispatchQueue.main.async {
                    self.imageViews[i].image = UIImage(data: data!)
                    let finish = Date()
                    let timeNeeded = finish.timeIntervalSince(start)
                    print("Time needed \(timeNeeded)")
                    imageGroup.leave()
                }
            }
            task.resume()
            
            imageGroup.notify(queue: .main) {
                print("All work is done!")
            }
        }
    }
    
    private func withoutBackground() {
        for i in 0...3 {
            guard let imageURL = URL(string: self.imageURLs[i]),
                let data = try? Data(contentsOf: imageURL) else {
                    return
            }
            
            self.imageViews[i].image = UIImage(data: data)
        }
    }
    
    private func differentQoS() {
        for i in 0...1 {
            DispatchQueue.global(qos: .background).async {
                guard let imageURL = URL(string: self.imageURLs[i]),
                    let data = try? Data(contentsOf: imageURL) else {
                        return
                }
                
                DispatchQueue.main.async {
                    self.imageViews[i].image = UIImage(data: data)
                }
            }
        }
        
        for i in 2...3 {
            DispatchQueue.global(qos: .userInitiated).async {
                guard let imageURL = URL(string: self.imageURLs[i]),
                    let data = try? Data(contentsOf: imageURL) else {
                        return
                }
                
                DispatchQueue.main.async {
                    self.imageViews[i].image = UIImage(data: data)
                }
            }
        }
    }
    
    // One by one
    private func syncQueue() {
//        let queue = DispatchQueue(label: "test")
        let queue = DispatchQueue(label: "test", qos: .userInitiated, attributes: .concurrent)
        
        for i in 0...1 {
            queue.async {
                guard let imageURL = URL(string: self.imageURLs[i]),
                    let data = try? Data(contentsOf: imageURL) else {
                        return
                }
                
                DispatchQueue.main.async {
                    self.imageViews[i].image = UIImage(data: data)
                }
            }
        }
        
        for i in 2...3 {
            queue.async {
                guard let imageURL = URL(string: self.imageURLs[i]),
                    let data = try? Data(contentsOf: imageURL) else {
                        return
                }
                
                DispatchQueue.main.async {
                    self.imageViews[i].image = UIImage(data: data)
                }
            }
        }
    }
}
