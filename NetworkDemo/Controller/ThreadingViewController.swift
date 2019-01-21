//
//  ThreadingViewController.swift
//  NetworkDemo
//
//  Created by Andriy Stefanchuk on 1/21/19.
//  Copyright © 2019 AS. All rights reserved.
//

import UIKit

class ThreadingTestViewController: UIViewController {

    // https://www.planetware.com/photos-large/SEY/best-islands-maldives.jpg
    // https://images.pexels.com/photos/302769/pexels-photo-302769.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var secondImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTestImage()
        loadSecondTestImage()
    }

    private func loadTestImage() {
        guard let imageURL = URL(string: "http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg") else {
            return
        }

        let urlSession = URLSession.shared
        let dataTask = urlSession.dataTask(with: imageURL) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            if let data = data {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }
        dataTask.resume()
    }

    private func loadSecondTestImage() {
        guard let imageURL = URL(string: "https://www.planetware.com/photos-large/SEY/best-islands-maldives.jpg") else {
            return
        }

        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            if let data = try? Data(contentsOf: imageURL) {
                DispatchQueue.main.async {
                    self.secondImageView.image = UIImage(data: data)
                }
            }
        }
    }
}
