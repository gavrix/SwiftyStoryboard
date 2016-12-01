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


public struct RuntimeSegueIdentifierError: Error {

    var segueIdentifier: String
    var runtimeErrorDescription: String
    
    var description: String {
        return self.runtimeErrorDescription
    }
}

public struct UknownSegueIdentifierStringError: Error {
    var segueIdentifierString: String
    
    var description: String {
        return "Unkown segueIdentifier \(segueIdentifierString) in storyboard."
    }
}

extension StaticTypeSegueIdentifierSupport where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    public func performSegue(_ segue: SegueIdentifier) throws {
        do {
            try TryCatch.try {
                self.performSegue(withIdentifier: segue.rawValue, sender: nil)
            }
            
        } catch (let error as NSError) {
            let exception = error.userInfo["exception"] as! NSException
            if exception.description.contains("\(segue.rawValue)") {
                throw RuntimeSegueIdentifierError(segueIdentifier:segue.rawValue, runtimeErrorDescription: exception.description)
            } else {
                throw error
            }
            
        }
    }

    
    public func segueIdentifierFromSegue(_ segue: UIStoryboardSegue) throws -> SegueIdentifier {
        guard let segueIdentifier = SegueIdentifier(rawValue: segue.identifier!) else {
            throw UknownSegueIdentifierStringError(segueIdentifierString: segue.identifier!)
        }
        return segueIdentifier
    }
}
