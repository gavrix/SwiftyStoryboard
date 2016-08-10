//
//  TypedSegueIdentifier.swift
//  SwiftyStoryboard
//
//  Created by Sergey Gavrilyuk on 2016-07-24.
//

import Foundation
import UIKit


public protocol StaticTypeSegueIdentifierSupport {
    associatedtype SegueIdentifier: RawRepresentable
}


public struct RuntimeSegueIdentifierError: ErrorType {

    var segueIdentifier: String
    var runtimeErrorDescription: String
    
    var description: String {
        return self.runtimeErrorDescription
    }
}

public struct UknownSegueIdentifierStringError: ErrorType {
    var segueIdentifierString: String
    
    var description: String {
        return "Unkown segueIdentifier \(segueIdentifierString) in storyboard."
    }
}

extension StaticTypeSegueIdentifierSupport where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    public func performSegue(segue: SegueIdentifier) throws {
        do {
            try TryCatch.tryBlock {
                self.performSegueWithIdentifier(segue.rawValue, sender: nil)
            }
            
        } catch (let error as NSError) {
            let exception = error.userInfo["exception"] as! NSException
            if exception.description.containsString("\(segue.rawValue)") {
                throw RuntimeSegueIdentifierError(segueIdentifier:segue.rawValue, runtimeErrorDescription: exception.description)
            } else {
                throw error
            }
            
        }
    }

    
    public func segueIdentifierFromSegue(segue: UIStoryboardSegue) throws -> SegueIdentifier {
        guard let segueIdentifier = SegueIdentifier(rawValue: segue.identifier!) else {
            throw UknownSegueIdentifierStringError(segueIdentifierString: segue.identifier!)
        }
        return segueIdentifier
    }
}
