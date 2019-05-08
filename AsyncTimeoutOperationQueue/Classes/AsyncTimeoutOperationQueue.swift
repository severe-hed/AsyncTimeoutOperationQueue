//
//  AsyncTimeoutOperationQueue.swift
//
//  Created by severehed on 7/18/18.
//  Copyright © 2018 severehed. All rights reserved.
//

import Foundation

public typealias AsyncOperationCompletionBlock = () -> ()
public typealias AsyncOperationTimeoutBlock = () -> ()

public typealias AsyncOperationBlock = (_ completion: AsyncOperationCompletionBlock?) -> ()

open class AsyncTimeoutOperationQueue: OperationQueue {
    
    open var defaultTimeout: TimeInterval?
    
    @discardableResult override open func addAsyncOperation(_ block: @escaping AsyncOperationBlock) -> AsyncTimeoutOperation {
        let operation = AsyncTimeoutOperation(block: block, timeout: defaultTimeout, onTimeout: nil)
        addOperation(operation)
        return operation
    }
}

public extension OperationQueue {
    @objc @discardableResult func addAsyncOperation(_ block: @escaping AsyncOperationBlock) -> AsyncTimeoutOperation {
        let operation = AsyncTimeoutOperation(block: block, timeout: nil, onTimeout: nil)
        addOperation(operation)
        return operation
    }
}

open class AsyncTimeoutOperation: Operation {
    
    private let block: AsyncOperationBlock
    
    private var _executing = false
    private var _finished = false
    private var _cancelled = false
    
    private var timeoutSeconds: TimeInterval?
    private var timeoutTimer: DispatchSourceTimer?
    private var timeoutBlock: AsyncOperationTimeoutBlock?
    
    deinit {
        timeoutTimer?.cancel()
        timeoutTimer = nil
    }
    
    public init(block: @escaping AsyncOperationBlock, timeout: TimeInterval? = nil, onTimeout: AsyncOperationTimeoutBlock? = nil) {
        self.block = block
        self.timeoutSeconds = timeout
        self.timeoutBlock = onTimeout
        super.init()
    }
    
    @discardableResult public func onTimeout(_ timeoutBlock: AsyncOperationTimeoutBlock?) -> Self {
        self.timeoutBlock = timeoutBlock
        return self
    }
    
    @discardableResult public func onCompletionOrTimeout(_ completionBlock: AsyncOperationCompletionBlock?) -> Self {
        self.completionBlock = completionBlock
        return self
    }
    
    @discardableResult public func timeout(_ timeout: TimeInterval?) -> Self {
        self.timeoutSeconds = timeout
        if isExecuting {
            configureTimeoutTimer()
        }
        return self
    }
    
    override open func start() {
        guard (self.isExecuting || self.isCancelled) == false else { return }
        self.isExecuting = true
        configureTimeoutTimer()
        self.block({
            [weak self] in
            guard let `self` = self else { return }
            self.finish()
        })
    }
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    override open var isExecuting: Bool {
        get { return _executing }
        set {
            let key = "isExecuting"
            willChangeValue(forKey: key)
            _executing = newValue
            didChangeValue(forKey: key)
        }
    }
    
    override open var isFinished: Bool {
        get { return _finished }
        set {
            let key = "isFinished"
            willChangeValue(forKey: key)
            _finished = newValue
            didChangeValue(forKey: key)
        }
    }
    
    override open var isCancelled: Bool {
        get { return _cancelled }
        set {
            let key = "isCancelled"
            willChangeValue(forKey: key)
            _cancelled = newValue
            didChangeValue(forKey: key)
        }
    }
    
    private func configureTimeoutTimer() {
        timeoutTimer?.cancel()
        timeoutTimer = nil
        if let timeoutSeconds = timeoutSeconds, timeoutTimer == nil {
            timeoutTimer = DispatchSource.makeTimerSource()
            timeoutTimer?.schedule(deadline: .now() + timeoutSeconds)
            timeoutTimer?.resume()
            timeoutTimer?.setEventHandler(handler: {
                [weak self] in
                guard let `self` = self else { return }
                self.timeout()
            })
        }
    }
    
    private func timeout() {
        if !self.isFinished && !self.isCancelled {
            self.isCancelled = true
            self.isExecuting = false
            self.isFinished = true
            timeoutBlock?()
        }
        timeoutTimer?.cancel()
        timeoutTimer = nil
    }
    
    private func finish() {
        if !self.isCancelled && self.isExecuting {
            self.isExecuting = false
            self.isFinished = true
        }
        timeoutTimer?.cancel()
        timeoutTimer = nil
    }
}
