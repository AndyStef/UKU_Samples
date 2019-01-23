import UIKit
import PlaygroundSupport

// Lifecycle of operation ->
// Pending -> Ready -> Executing -> Finished
// Every state can go directly to Canceled

// Sample of creating operation

func createOperation() {
    let operation = {
        print("Operation is started")
        print("Operation is finished")
    }
    
    let operationQueue = OperationQueue()
    operationQueue.addOperation(operation)
    
    var result: String?
    let concatenationOperation = BlockOperation {
        result = "This is" + " operations"
    }
    
    concatenationOperation.start()
    print(result)
}

// Custom Operation

class FilterOperation: Operation {
    var inputImage: UIImage?
    var outputImage: UIImage?
    
    override func main() {
        outputImage = applySepiaFilter(inputImage!)
    }
    
    func applySepiaFilter(_ image: UIImage) -> UIImage? {
        guard let data = image.pngData() else { return nil }
        let inputImage = CIImage(data: data)
        
        if isCancelled {
            return nil
        }
        
        let context = CIContext(options: nil)
        
        guard let filter = CIFilter(name: "CISepiaTone") else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(0.8, forKey: "inputIntensity")
        
        if isCancelled {
            return nil
        }
        
        guard
            let outputImage = filter.outputImage,
            let outImage = context.createCGImage(outputImage, from: outputImage.extent)
            else {
                return nil
        }
        
        return UIImage(cgImage: outImage)
    }
}

func executeFilter() {
    let filterOp = FilterOperation()
    filterOp.inputImage = UIImage()
    
//    filterOp.cancel()
//    filterOp.isCancelled
//    filterOp.isReady
//    filterOp.isFinished
//    filterOp.isExecuting
//    filterOp.isConcurrent
//    filterOp.isAsynchronous
//    filterOp.dependencies
//    filterOp.addDependency(anotherOp)
//    filterOp.removeDependency(anotherOp)
    filterOp.qualityOfService
    filterOp.queuePriority
    filterOp.completionBlock
    
    // will be executed sync on currebt thread
    filterOp.start()
}

//let opQueue = OperationQueue()
//opQueue.addOperation(FilterOperation())
//opQueue.cancelAllOperations()
//opQueue.isSuspended
//opQueue.maxConcurrentOperationCount
//opQueue.name
//opQueue.operationCount
//opQueue.operations
//opQueue.qualityOfService
//opQueue.waitUntilAllOperationsAreFinished()


// Creating of operation queue

func printerQueue() {
    let printerQueue = OperationQueue()
    printerQueue.maxConcurrentOperationCount = 2
    
    printerQueue.addOperation { print("🐶"); sleep(2) }
    printerQueue.addOperation { print("🐱"); sleep(2) }
    printerQueue.addOperation { print("🐭"); sleep(2) }
    printerQueue.addOperation { print("🐹"); sleep(2) }
    printerQueue.addOperation { print("🦊"); sleep(2) }
    printerQueue.addOperation { print("🐻"); sleep(2) }
    printerQueue.addOperation { print("🐼"); sleep(2) }
    
    printerQueue.waitUntilAllOperationsAreFinished()
    print("Finished")
}

func printerQueueQoS() {
    let printerQueue = OperationQueue()
//    printerQueue.maxConcurrentOperationCount = 2
    printerQueue.maxConcurrentOperationCount = 1
    
    let concatenationOperation = BlockOperation {
        print("Concatentation - 🌈 + ☀️")
        sleep(2)
    }
    concatenationOperation.qualityOfService = .userInitiated
    
    printerQueue.addOperation { print("🐶"); sleep(2) }
    printerQueue.addOperation { print("🐱"); sleep(2) }
    printerQueue.addOperation { print("🐭"); sleep(2) }
    printerQueue.addOperation { print("🐹"); sleep(2) }
    printerQueue.addOperation { print("🦊"); sleep(2) }
    printerQueue.addOperation { print("🐻"); sleep(2) }
    printerQueue.addOperation { print("🐼"); sleep(2) }
    printerQueue.addOperation(concatenationOperation)
    
    printerQueue.waitUntilAllOperationsAreFinished()
    print("Finished")
}

printerQueueQoS()

// Some real world filtering operation

func realWorldFilter() {
    let images: [UIImage] = [UIImage(), UIImage(), UIImage(), UIImage()]
    var filteredImages = [UIImage]()
    
    let filterQueue = OperationQueue()
    
    let appendQueue = OperationQueue()
    appendQueue.maxConcurrentOperationCount = 1
    
    for image in images {
        let filterOp = FilterOperation()
        filterOp.inputImage = image
        filterOp.completionBlock = {
            guard let output = filterOp.outputImage else { return }
            appendQueue.addOperation {
                filteredImages.append(output)
            }
        }
        filterQueue.addOperation(filterOp)
    }
}


// Async operation

class AsyncOperation: Operation {
    
    enum State: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
}

extension AsyncOperation {
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        main()
        state = .executing
    }
    
    override func cancel() {
        state = .finished
    }
}

func asyncImageLoad(imageURL: URL, completion: @escaping ((UIImage?) -> ())) {
    let task = URLSession.shared.dataTask(with: imageURL) { (data, responce, error) in
        if let data = data {
            completion(UIImage(data: data))
        }
    }
    task.resume()
}

class ImageLoadOperation: AsyncOperation {
    var url: URL?
    var outputImage: UIImage?
    
    init(url: URL?) {
        self.url = url
        super.init()
    }
    
    override func main() {
        if let imageURL = url {
            asyncImageLoad(imageURL: imageURL) { [unowned self]  image in
                self.outputImage = image
                self.state = .finished
            }
        }
    }
}

func loadImageSample() {
    PlaygroundPage.current.needsIndefiniteExecution = true

    var view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    var eiffelImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    eiffelImage.backgroundColor = UIColor.yellow
    eiffelImage.contentMode = .scaleAspectFit
    view.addSubview(eiffelImage)
    
    PlaygroundPage.current.liveView = view
    
    let imageURL = URL(string:"http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg")
    
    let operationLoad = ImageLoadOperation(url: imageURL)
    
    operationLoad.completionBlock = {
        OperationQueue.main.addOperation {
            eiffelImage.image = operationLoad.outputImage
        }
    }
    
    let loadQueue = OperationQueue()
    loadQueue.addOperation(operationLoad)
    loadQueue.waitUntilAllOperationsAreFinished()
    sleep(5)
    operationLoad.outputImage
    
}

//loadImageSample()

// Adding dependencies

func dependenciesExample() {
    let imageURL = URL(string:"http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg")
    
    let imageLoad = ImageLoadOperation(url: imageURL)
    let filter = FilterOperation()
    filter.inputImage = imageLoad.outputImage
    filter.addDependency(imageLoad)
    
    let queue = OperationQueue()
    queue.addOperations([imageLoad, filter], waitUntilFinished: true)
    imageLoad.outputImage
    filter.outputImage
}

dependenciesExample()

// Cancelling operations
