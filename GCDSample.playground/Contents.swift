import UIKit

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

// The Grand Central Dispatch (GCD, or just Dispatch) framework is based on the underlying thread pool design pattern. This means that there are a fixed number of threads spawned by the system - based on some factors like CPU cores - they're always available waiting for tasks to be executed concurrently.

// In the past a processor had one single core, it could only deal with one task at a time. Later on time-slicing was introduced, so CPU's could execute threads concurrently using context switching. As time passed by processors gained more horse power and cores so they were capable of real multi-tasking using parallelism.

// On every dispatch queue, tasks will be executed in the same order as you add them to the queue - FIFO the first task in the line will be executed first - but you should note that the order of completion is not guaranteed. Tasks will be completed according to the code complexity. So if you add two tasks to the queue, a slow one first and a fast one later, the fast one can finish before the slower one.

// Clasification
// Serial and Concurrent queues
// Main, Global and Custom queues
// Main queue is Serial one
// Global queues are system provided concurrent queues
// It is recommended to use only custom serial queues, use global for concurrent

// Sync is just an async call with a semaphore (explained later) that waits for the return value.
// DEADLOCK WARNING: you should never call sync on the main queue, because it'll cause a deadlock and a crash.
// Don't call sync on a serial queue from the serial queue's thread!

// DispatchWorkItem encapsulates work that can be performed. A work item can be dispatched onto a DispatchQueue and within a DispatchGroup. A DispatchWorkItem can also be set as a DispatchSource event, registration, or cancel handler.




// Plan of demo application:
// Explain why we should use background threads and explain why it is so important to keep user notified about system state
// Show some application with hard operation without any spinners and lagging UI
// Than add GCD in different ways and show that it is good)













// First show that there is simple thread, but there is no sense in using it

func threadTest() {
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

// Then show how to create Queue

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

// Sync and async signature and logic difference

// Sync
func load() -> String { return "" }

// Async
func load(completion: (String) -> Void) { completion("") }

// Executing of sync / async threads

func serialTest() {
    let queue = DispatchQueue(label: "com.threadsDemo.serialQueue")
    //queue.async {
    queue.sync {
        for i in 0..<10 {
            print("🦊", i)
        }
    }
    
    for i in 100..<110 {
        print("🐰", i)
    }
}

// Showing difference between QoS

func prioritiesTest() {
    let queue1 = DispatchQueue(label: "com.threadsDemo.queue1", qos: DispatchQoS.background)
    let queue2 = DispatchQueue(label: "com.threadsDemo.queue2", qos: DispatchQoS.userInteractive)
    
    queue1.async {
        for i in 0..<10 {
            print("🦀", i)
        }
    }
    
    queue2.async {
        for i in 0..<10 {
            print("🐬", i)
        }
    }
    
    //    for i in 100..<110 {
    //        print("🐰", i)
    //    }
}

// Custom queues attributes

func concurrentTest() {
    let queue1 = DispatchQueue(label: "com.threadsDemo.queue2", qos: DispatchQoS.userInteractive)
    //    let queue1 = DispatchQueue(label: "com.threadsDemo.queue2", qos: DispatchQoS.userInteractive, attributes: .concurrent)
    //    let queue1 = DispatchQueue(label: "com.threadsDemo.queue2", qos: DispatchQoS.userInteractive, attributes: .initiallyInactive)
    
    
    queue1.async {
        for i in 0..<10 {
            print("🦀", i)
        }
    }
    
    queue1.async {
        for i in 100..<110 {
            print("🐬", i)
        }
    }
    
    queue1.async {
        for i in 200..<210 {
            print("🐰", i)
        }
    }
}

// Showing executing with delay

func delayTest() {
    let delayQueue = DispatchQueue(label: "com.threadsDemo.queue1", qos: DispatchQoS.userInteractive)
    print(Date())
    
    let additionalTime: DispatchTimeInterval = .seconds(3)
    delayQueue.asyncAfter(deadline: .now() + additionalTime) {
        print(Date())
    }
}


// Dispatch work item

func dispatchWorkItem() {
    var value = 10
    
    let workItem = DispatchWorkItem {
        value += 5
    }
    
    workItem.perform()
    
    let queue = DispatchQueue.global(qos: .utility)
    
    queue.async(execute: workItem)
    
    workItem.notify(queue: DispatchQueue.main) {
        print("value = ", value)
    }
}

// Dispatch group

func dispatchGroupTest() {
    let imageURLs = [
        "http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg",
        "http://adriatic-lines.com/wp-content/uploads/2015/04/canal-of-Venice.jpg",
        "http://bestkora.com/IosDeveloper/wp-content/uploads/2016/12/Screen-Shot-2017-01-17-at-9.33.52-PM.png",
        "http://www.picture-newsletter.com/arctic/arctic-12.jpg"
    ]
    var images = [UIImage?]()
    
    let imageGroup = DispatchGroup()
    for i in 0...3 {
        imageGroup.enter()
        DispatchQueue.global().async {
            guard let imageURL = URL(string: imageURLs[i]),
                let data = try? Data(contentsOf: imageURL) else {
                    imageGroup.leave()
                    return
            }
            
            DispatchQueue.main.async {
                images.append(UIImage(data: data))
                print(i)
                imageGroup.leave()
            }
        }
    }
    
    imageGroup.notify(queue: .main) {
        print("All work is done!")
    }
}

// Semaphore
// Signal decrements semaphore count and wait increases it
func semaphoreTest() {
    let semaphore = DispatchSemaphore(value: 0)
    DispatchQueue.global().async {
        // Do some stuff here
        semaphore.signal()
    }
    
    semaphore.wait(timeout: .now() + 5)
}

// Very simple alternative

func gcdAlternative() {
    //performSelector(inBackground: #selector(fetchJSON), with: nil)
    //performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
}


// DispatchSource
// Queue.async(flags: .barrier)

func raceConditionExample() {
    let mySerialQueue = DispatchQueue(label: "com.test.serialQueue")
    
    var value = "😘"
    
    func changeValue(variant: Int) {
        sleep(1)
        value = value + "🐯"
        print("\(value) - \(variant)")
    }
    
    //    mySerialQueue.sync {
    mySerialQueue.async {
        changeValue(variant: 1)
    }
    
    value
    
    value = "🐹"
    mySerialQueue.sync {
        changeValue(variant: 2)
    }
    
    value
}

func deadlock() {
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

func imageLoadTest() {
    PlaygroundPage.current.needsIndefiniteExecution = true
    
    var view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    var image = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    image.backgroundColor = UIColor.yellow
    image.contentMode = .scaleAspectFit
    view.addSubview(image)
    //: "Живой" UI
    PlaygroundPage.current.liveView = view
    func fetchImage() {
        
        let imageURL: URL = URL(string: "http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg")!
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
            if let data = try? Data(contentsOf: imageURL){
                DispatchQueue.main.async {
                    image.image = UIImage(data: data)
                    print("Show image data")
                }
                print("Did download  image data")
            }
        }
    }
    fetchImage()
    
    //PlaygroundPage.current.finishExecution()
}
