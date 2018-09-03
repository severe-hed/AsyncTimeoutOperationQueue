# AsyncTimeoutOperationQueue

[![CI Status](https://img.shields.io/travis/severehed/AsyncTimeoutOperationQueue.svg?style=flat)](https://travis-ci.org/severehed/AsyncTimeoutOperationQueue)
[![Version](https://img.shields.io/cocoapods/v/AsyncTimeoutOperationQueue.svg?style=flat)](https://cocoapods.org/pods/AsyncTimeoutOperationQueue)
[![License](https://img.shields.io/cocoapods/l/AsyncTimeoutOperationQueue.svg?style=flat)](https://cocoapods.org/pods/AsyncTimeoutOperationQueue)
[![Platform](https://img.shields.io/cocoapods/p/AsyncTimeoutOperationQueue.svg?style=flat)](https://cocoapods.org/pods/AsyncTimeoutOperationQueue)

## Usage

Use as extension to regular queue

```swift
import AsyncTimeoutOperationQueue

let queue = OperationQueue()

  queue
      .addAsyncOperation { (completion) in
        //some async work here
        //don't forget to call completion when it's done!
        completion?()
      }
      .timeout(5)
      .onTimeout {
          //called only if operation cancelled by timeout
      }
      .onCompletionOrTimeout {
          //called in both cases: timeout or success finish
      }
```
If you want to set default timeout for all operations in this queue, simply create AsyncTimeoutOperationQueue
```swift
import AsyncTimeoutOperationQueue

let queue = AsyncTimeoutOperationQueue()
queue.defaultTimeout = 10

  queue
      .addAsyncOperation { (completion) in
        //some async work here
        //don't forget to call completion when it's done!
        completion?()
      }
      .timeout(5) //you still able to override default timeout
      .onTimeout {
          //called only if operation cancelled by timeout
      }
      .onCompletionOrTimeout {
          //called in both cases: timeout or success finish
      }
```

Also you can create AsyncBlockOperation itself or inherit it
```swift
import AsyncTimeoutOperationQueue

let operation =
            AsyncBlockOperation(block: { (completion) in
                completion?()
            },
            timeout: 30,
            onTimeout: {
                                    
            })
```

## Requirements
Xcode 9+, swift 4.0,
No other special requirements 🍺

## Installation

AsyncTimeoutOperationQueue is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AsyncTimeoutOperationQueue'
```

## Author

severehed

## License

AsyncTimeoutOperationQueue is available under the MIT license. See the LICENSE file for more info.

## Support on Beerpay
Hey dude! Help me out for a couple of :beers:!

[![Beerpay](https://beerpay.io/severehed/AsyncTimeoutOperationQueue/badge.svg?style=beer-square)](https://beerpay.io/severehed/AsyncTimeoutOperationQueue)  [![Beerpay](https://beerpay.io/severehed/AsyncTimeoutOperationQueue/make-wish.svg?style=flat-square)](https://beerpay.io/severehed/AsyncTimeoutOperationQueue?focus=wish)