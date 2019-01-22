//
//  Threading.swift
//  NetworkDemo
//
//  Created by Andriy Stefanchuk on 1/18/19.
//  Copyright © 2019 AS. All rights reserved.
//

import UIKit

// https://medium.com/@abhimuralidharan/understanding-threads-in-ios-5b8d7ab16f09
// https://www.hackingwithswift.com/read/9/2/why-is-locking-the-ui-bad
// https://theswiftdev.com/2018/07/10/ultimate-grand-central-dispatch-tutorial-in-swift/
// https://medium.com/@nimjea/grand-central-dispatch-in-swift-fdfdd8b22d52
// https://github.com/AndyStef/SwiftTips/blob/master/Threads/GCD.swift


// https://habr.com/ru/post/320152/
// https://www.appcoda.com/grand-central-dispatch/

// https://www.raywenderlich.com/5293-operation-and-operationqueue-tutorial-in-swift
// https://www.raywenderlich.com/5370-grand-central-dispatch-tutorial-for-swift-4-part-1-2
// https://www.swiftbysundell.com/posts/a-deep-dive-into-grand-central-dispatch-in-swift

// https://blackpixel.com/writing/2013/11/performselectoronmainthread-vs-dispatch-async.html
// https://www.objc.io/issues/2-concurrency/thread-safe-class-design/

class ThreadingViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    private var petitions: Petitions!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Happens on main thread and blocks everything
        doSomeTimeConsumingTask() // takes 5 seconds to run
        tableView.reloadData()

        // Calling of time consuming task in background thread
        DispatchQueue.global(qos: .userInteractive).async {
            self.doSomeTimeConsumingTask()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // .userInteractive - highest - work is virtually instantaneous
    // Work that is interacting with the user, such as operating on the main thread, refreshing the user interface, or performing animations. If the work doesn't happen quickly, the user interface may appear frozen. Focuses on responsiveness and performance
    // UI updates -> Serial main queue

    // .userInitiated - work is nearly instantaneous, such as a few seconds or less
    // Work that the user has initiated and requires immediate results, such as opening a saved documents or performing an action when the user clicks something in the user interface. The work is required in order to continue user interaction. Focuses on responsiveness and performance
    // async UI related tasks -> high priority global queue

    // .utility - work takes a few seconds to a few minutes
    // Work that may take some time to complete and doesn't require an immediate result, such as download or importing data. Utility tasks typically have a progress bar that is visible to the user. Focuses on providing a balance between responsiveness, performance, and energy efficiency.
    // low priority global queue

    // .background - lowest - work takes significant time, such as minutes or hours
    // Work that operates in the background and isn't visible to the user, such as indexing, synchronizing, and backups. Focuses on energy efficiency

    // .default
    // .unspecified

    // How you call async() informs the system where you want the code to run. GCD works with a system of queues, which are much like a real-world queue: they are First In, First Out (FIFO) blocks of code. What this means is that your GCD calls don't create threads to run in, they just get assigned to one of the existing threads for GCD to manage.

    // GCD creates for you a number of queues, and places tasks in those queues depending on how important you say they are. All are FIFO, meaning that each block of code will be taken off the queue in the order they were put in, but more than one code block can be executed at the same time so the finish order isn't guaranteed.

    // Can talk about [weak self] [unowned self] diff things)

    private func doSomeTimeConsumingTask() {

    }

    private func downloadData(at url: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            guard let data = try? Data(contentsOf: url) else {
                self.showError()
                return
            }

            self.parseData(data)
        }
    }

    private func parseData(_ data: Data) {
        // Do some parsing shit using decodable
    }

    @objc private func showError() {
        DispatchQueue.main.async { [unowned self] in
            let alertController = UIAlertController(
                title: "Loading error",
                message: "There was a problem loading the feed; please check your connection and try again.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }

    private func gcdAlternative() {
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }

    @objc private func fetchJSON() {
        let urlString: String

        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }

        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(data)
                return
            }
        }

        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }

    private func parse(_ json: Data) {
        let decoder = JSONDecoder()

        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }

    private class Petitions: Decodable {
        // Some dummy object
    }

    // The Grand Central Dispatch (GCD, or just Dispatch) framework is based on the underlying thread pool design pattern. This means that there are a fixed number of threads spawned by the system - based on some factors like CPU cores - they're always available waiting for tasks to be executed concurrently.

    // In the past a processor had one single core, it could only deal with one task at a time. Later on time-slicing was introduced, so CPU's could execute threads concurrently using context switching. As time passed by processors gained more horse power and cores so they were capable of real multi-tasking using parallelism.

    // Sync
    func load() -> String { return "" }

    // Async
    func load(completion: (String) -> Void) { completion("") }

    // On every dispatch queue, tasks will be executed in the same order as you add them to the queue - FIFO the first task in the line will be executed first - but you should note that the order of completion is not guaranteed. Tasks will be completed according to the code complexity. So if you add two tasks to the queue, a slow one first and a fast one later, the fast one can finish before the slower one.

    // Clasification
    // Serial and Concurrent queues
    // Main, Global and Custom queues
    // Main queue is Serial one
    // Global queues are system provided concurrent queues
    // It is recommended to use only custom serial queues, use global for concurrent

    func threadsExamples() {
        let _ = DispatchQueue.main
        let _ = DispatchQueue.global(qos: .background)
        let _ = DispatchQueue.global(qos: .default)
        let _ = DispatchQueue.global(qos: .unspecified)
        let _ = DispatchQueue.global(qos: .userInitiated)
        let _ = DispatchQueue.global(qos: .userInteractive)
        let _ = DispatchQueue.global(qos: .utility)
        let _ = DispatchQueue(label: "com.test.queues.serial")
        let _ = DispatchQueue(label: "com.test.queues.concurrent",
                              qos: .userInteractive, attributes: .concurrent)
        let _ = Thread.isMainThread
        let _ = Thread.current
        let _ = Thread.isMultiThreaded()
        Thread.sleep(forTimeInterval: 300)
        Thread.sleep(until: Date())

        // Delay execution
        DispatchQueue.main.asyncAfter(deadline: .now() + 300, execute: {})

        // Concurrent loop
        DispatchQueue.concurrentPerform(iterations: 5, execute: { _ in })
    }

    // Sync is just an async call with a semaphore (explained later) that waits for the return value.
    // DEADLOCK WARNING: you should never call sync on the main queue, because it'll cause a deadlock and a crash.
    // Don't call sync on a serial queue from the serial queue's thread!

    // DispatchWorkItem encapsulates work that can be performed. A work item can be dispatched onto a DispatchQueue and within a DispatchGroup. A DispatchWorkItem can also be set as a DispatchSource event, registration, or cancel handler.

    private func dispatchWorkItemExample() {
        var workItem: DispatchWorkItem?
        workItem = DispatchWorkItem {
            for i in 1..<6 {
                guard let item = workItem, !item.isCancelled else {
                    print("cancelled")
                    break
                }
                sleep(1)
                print(String(i))
            }
        }

        workItem?.notify(queue: .main) {
            print("done")
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
            workItem?.cancel()
        }
        DispatchQueue.main.async(execute: workItem!)
        workItem?.perform()
        // you can use perform to run on the current queue instead of queue.async(execute:)
        //workItem?.perform()
    }

    private func dispatchGroupExample() {
        func load(delay: UInt32, completion: () -> Void) {
            sleep(delay)
            completion()
        }

        let group = DispatchGroup()

        group.enter()
        load(delay: 1) {
            print("1")
            group.leave()
        }

        group.enter()
        load(delay: 2) {
            print("2")
            group.leave()
        }

        group.enter()
        load(delay: 3) {
            print("3")
            group.leave()
        }

        group.notify(queue: .main) {
            print("done")
        }
    }

    private func semaphoreExample() {
        let semaphore = DispatchSemaphore(value: 0)
        semaphore.signal()
        let _ = semaphore.wait(timeout: .now() + 5)
    }

    private func threadTest() {
        let t = Thread {
            print(Thread.current.name ?? "")
            let timer = Timer(timeInterval: 1, repeats: true) { t in
                print("tick")
            }
            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)

            RunLoop.current.run()
            RunLoop.current.run(mode: RunLoop.Mode.common, before: Date.distantPast)
        }
        t.name = "my-thread"
        t.start()
    }

    // Use async barriers for writes, sync blocks for reads. 😎

    private func deadlock() {
        let queue = DispatchQueue(label: "com.theswiftdev.queues.serial")
        queue.sync {
            // do some sync work
            queue.sync {
                // this won't be executed -> deadlock!
            }
        }

        //What you are trying to do here is to launch the main thread synchronously from a background thread before it exits. This is a logical error.
        //https://stackoverflow.com/questions/49258413/dispatchqueue-crashing-with-main-sync-in-swift?rq=1
        DispatchQueue.global(qos: .utility).sync {
            // do some background task
            DispatchQueue.main.sync {
                // app will crash
            }
        }
    }

    // Plan of demo application:
    // Explain why we should use background threads and explain why it is so important to keep user notified about system state
    // Show some application with hard operation without any spinners and lagging UI
    // Than add GCD in different ways and show that it is good)

    private func pictureExample() {
        let imageURL: URL = URL(string: "http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg")!
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
            if let data = try? Data(contentsOf: imageURL){
                DispatchQueue.main.async {
                    //image.image = UIImage(data: data)
                    print("Show image data")
                }
                print("Did download  image data")
            }
        }
    }
}
