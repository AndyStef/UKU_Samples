import UIKit
import PlaygroundSupport

func raceConditionExample() {
    let mySerialQueue = DispatchQueue(label: "com.test.serialQueue")

    var value = "😘"

    func changeValue(variant: Int) {
        sleep(1)
        value = value + "🤬"
        print("\(value) - \(variant)")
    }

    changeValue(variant: 1)

    mySerialQueue.async {
        changeValue(variant: 2)
        value
    }

    mySerialQueue.async {
        changeValue(variant: 3)
        value
    }

    value

    mySerialQueue.sync {
        changeValue(variant: 4)
        value
    }

    value
}

func raceConditionExample2() {
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

PlaygroundPage.current.finishExecution()
