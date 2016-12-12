//
//  StaticTypeSegueSupport.swift
//  SwiftyStoryboard
//
//  Created by Sergey Gavrilyuk on 2016-07-24.
//

import Foundation
import UIKit

public protocol StaticTypeSegueSupport: class {}

let UnexpectedDestinationVCType = NSExceptionName("UnexpectedDestinationVCType")

private struct SwizzleKeys {
    static var SwizzledFlagKey = 0
    static var ConfigureFuncKey = 0
}

private final class Box<V> {
    let value: V
    init(_ value: V) { self.value = value }
}

public struct RuntimeTypeMismatchError: Error {
    var segueIdentifier: String
    var expectedViewControllerType: AnyClass
    var actualViewControllerType: AnyClass
    
    init(internalException: NSException) {
        let userInfo = internalException.userInfo!
        self.segueIdentifier = userInfo["segueIdentifier"] as! String
        self.expectedViewControllerType = userInfo["expectedType"] as! UIViewController.Type
        self.actualViewControllerType = userInfo["actualType"] as! UIViewController.Type
    }
}

extension StaticTypeSegueSupport {
    fileprivate var segueConfigureFunc: ((UIStoryboardSegue) -> ())? {
        get {
            let box = objc_getAssociatedObject(self, &SwizzleKeys.ConfigureFuncKey) as? Box<((UIStoryboardSegue) -> ())?>
            return box?.value
        }
        set {
            objc_setAssociatedObject(self, &SwizzleKeys.ConfigureFuncKey, Box(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension StaticTypeSegueSupport where Self: UIViewController {
    
    public func performSegue<U: UIViewController>(_ segueIdentifier: String, configure: @escaping (U)->()) throws {
        self.prepareForSegueConfigure(segueIdentifier, configure: configure)
        do {
            try TryCatch.try {
                self.performSegue(withIdentifier: segueIdentifier, sender: nil)
            }
        } catch (let error as NSError) {
            if let exception = error.userInfo["exception"] as? NSException ,
                exception.name == UnexpectedDestinationVCType {
                throw RuntimeTypeMismatchError(internalException: exception)
            } else {
                throw error
            }
        }
    }
    
    fileprivate func prepareForSegueConfigure<U: UIViewController>(_ segueIdentifier: String, configure: @escaping (U) -> ()) {
        swizzlePrepareforSegueIfNecessary()
        
        func unsafeConfigure(_ rawSegue: UIStoryboardSegue) {
            guard let destinationVC = rawSegue.destination as? U else {
                NSException(name: UnexpectedDestinationVCType,
                            reason: nil,
                            userInfo: [
                                "expectedType": U.self,
                                "actualType": type(of: rawSegue.destination),
                                "segueIdentifier": rawSegue.identifier!
                    ]).raise()
                fatalError()// never used, workaround for NSException.raise() not marked as @noescape
            }
            configure(destinationVC)
        }
        self.segueConfigureFunc = unsafeConfigure
    }
    
    fileprivate func swizzlePrepareforSegueIfNecessary() {
        guard objc_getAssociatedObject(self, &SwizzleKeys.SwizzledFlagKey) == nil else { return }
        
        typealias CastedFunc = @convention(c) (AnyObject, Selector, UIStoryboardSegue, AnyObject?) -> Void
        
        var originalPrepareForSegueImp: IMP! = nil
        let myBlock : @convention(block) (UIViewController, UIStoryboardSegue, AnyObject?) -> () = {
            (selfVC, segue, sender) in
            let typedSegueSupported = selfVC as? StaticTypeSegueSupport
			
            let originalPrepareForSegue = unsafeBitCast(originalPrepareForSegueImp!, to: CastedFunc.self)
            originalPrepareForSegue(selfVC, #selector(UIViewController.prepare(for:sender:)), segue, sender)
			
			typedSegueSupported?.segueConfigureFunc?(segue)
            typedSegueSupported?.segueConfigureFunc = nil
        }
        
        let newPrepareForSegueImp = imp_implementationWithBlock(unsafeBitCast(myBlock, to: AnyObject.self))
        let method = class_getInstanceMethod(type(of: self), #selector(UIViewController.prepare(for:sender:)))
        originalPrepareForSegueImp = method_setImplementation(method, newPrepareForSegueImp)
        
        objc_setAssociatedObject(self, &SwizzleKeys.SwizzledFlagKey, true, .OBJC_ASSOCIATION_COPY)
    }
    
}

extension StaticTypeSegueSupport where  Self:UIViewController,
                                        Self:StaticTypeSegueIdentifierSupport,
                                        Self.SegueIdentifier.RawValue == String {
    
    public func performSegue<U: UIViewController>(_ segue: SegueIdentifier, configure: @escaping (U) -> ()) throws {
    
        self.prepareForSegueConfigure(segue.rawValue, configure: configure)
        try self.performSegue(segue)
    }
}
