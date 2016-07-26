//
//  TypedSegueIdentifier.swift
//  SwiftyStoryboard
//
//  Created by Sergey Gavrilyuk on 2016-07-24.
//

import Foundation
import UIKit


protocol StaticTypeSegueIdentifierSupport {
    associatedtype SegueIdentifier: RawRepresentable
}


struct RuntimeSegueIdentifierError: ErrorType {

    var segueIdentifier: String
    var runtimeErrorDescription: String
    
    var description: String {
        return self.runtimeErrorDescription
    }
}

extension StaticTypeSegueIdentifierSupport where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    func performSegue(segue: SegueIdentifier) throws {
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

    
    func segueIdentifierFromSegue(segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let segueIdentifier = SegueIdentifier(rawValue: segue.identifier!) else {
            fatalError("Unknown segue identifier: \(segue.identifier)")
        }
        return segueIdentifier
    }
}
