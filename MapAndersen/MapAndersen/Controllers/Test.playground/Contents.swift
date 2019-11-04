import UIKit

var str = "Hello, playground"

import Foundation

let operation1 = BlockOperation()
let operation2 = BlockOperation()
let queue = OperationQueue()
operation1.addExecutionBlock { () -> Void in
    repeat {
        usleep(10000)
        print("1", terminator: "")
    } while !operation1.isCancelled
}
operation2.addExecutionBlock { () -> Void in
    repeat {
        usleep(15000)
        print("-", terminator: "")
    } while !operation2.isCancelled
}
queue.addOperation(operation1)
queue.addOperation(operation2)
sleep(1)
queue.cancelAllOperations()

