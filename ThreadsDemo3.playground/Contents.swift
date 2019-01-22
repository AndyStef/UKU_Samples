import UIKit
import PlaygroundSupport

// 1. Sync vs Async
// 2. QoS
// 3. Concurrent custom queues
// 4. Delay
// 5. Load image / accessing main / global thread
// 6. Race condition
// 7. Dispatch work item
// 8. Dispatch group

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

func delayTest() {
    let delayQueue = DispatchQueue(label: "com.threadsDemo.queue1", qos: DispatchQoS.userInteractive)
    print(Date())

    let additionalTime: DispatchTimeInterval = .seconds(3)
    delayQueue.asyncAfter(deadline: .now() + additionalTime) {
        print(Date())
    }
}

func dispatchWorkItemTest() {

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

// Signal decrements semaphore count and wait increases it
func semaphoreTest() {
    let semaphore = DispatchSemaphore(value: 0)
    DispatchQueue.global().async {
        // Do some stuff here
        semaphore.signal()
    }

    semaphore.wait(timeout: .now() + 5)
}

func gcdAlternative() {
    //performSelector(inBackground: #selector(fetchJSON), with: nil)
    //performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
}

// Sync
func load() -> String { return "" }

// Async
func load(completion: (String) -> Void) { completion("") }

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
