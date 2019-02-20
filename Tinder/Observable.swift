//
//  Observable.swift
//  KVO_ObservablePattern
//
//  Created by Chung Han Hsin on 2019/1/13.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import Foundation
public class Observable<Type>{
    //MARK: -CallBack
    fileprivate class CallBack{
        fileprivate weak var observer: AnyObject?
        fileprivate let options: [ObservableOptions]
        fileprivate let closure: (Type?, ObservableOptions) -> Void
        
        init(observer: AnyObject, options: [ObservableOptions], closure: @escaping (Type?, ObservableOptions) -> Void) {
            self.observer = observer
            self.options = options
            self.closure = closure
        }
    }
    
    public var value: Type?{
        didSet{
            //prevent calling a closure related to a observer that's already been released from memory
            removeNilObserverCallBacks()
            
            //
            notifyCallbacks(value: oldValue, option: .old)
            notifyCallbacks(value: value, option: .new)
        }
    }
    
    private func removeNilObserverCallBacks(){
        callbacks = callbacks.filter({$0.observer != nil})
    }
    
    private func notifyCallbacks(value: Type?, option: ObservableOptions){
        let callbacksToNotify = callbacks.filter({$0.options.contains(option)})
        callbacksToNotify.forEach({$0.closure(value, option)})
    }
    
    
//    public init(value: Type){
//        self.value = value
//    }
    
    private var callbacks: [CallBack] = []
    
    //to register an observer for the given options and closure
    public func addObserver(observer: AnyObject, removeIfExist: Bool = true, options: [ObservableOptions] = [.new], closure: @escaping (Type?, ObservableOptions) -> Void){
        
        //remove the existed callBack
        if removeIfExist{
            removeObserver(observer: observer)
        }
        
        //create a new callBack and add it into the observers
        let callBack = CallBack(observer: observer, options: options, closure: closure)
        callbacks.append(callBack)
        
        //if options include initial, call the callBack closure
        if options.contains(.initial){
            closure(value, .initial)
        }
        
    }
    
    public func removeObserver(observer: AnyObject){
        callbacks = callbacks.filter({$0.observer !== observer})
    }
}


public struct ObservableOptions: OptionSet{
    public var rawValue: Int
    public static let initial = ObservableOptions(rawValue: 1 << 0)
    public static let old = ObservableOptions(rawValue: 1 << 1)
    public static let new = ObservableOptions(rawValue: 1 << 2)
    
    public init(rawValue: Int) {
        
        self.rawValue = rawValue
    }
    
}
