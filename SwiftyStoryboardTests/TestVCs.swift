//
//  TestVCs.swift
//  SwiftyStoryboard
//
//  Created by Sergii Gavryliuk on 2016-07-24.
//  Copyright © 2016 Sergey Gavrilyuk. All rights reserved.
//

import Foundation
import UIKit

class SourceViewController: UIViewController, StaticTypeSegueIdentifierSupport, StaticTypeSegueSupport  {
    enum SegueIdentifier: String {
        case Segue1
        case Segue2
    }
    
    var performSegueWithIdentifierCalled: Bool = false
    var destinationViewController: UIViewController!
    
    override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
        super.performSegueWithIdentifier(identifier, sender: sender)
        self.performSegueWithIdentifierCalled = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        self.destinationViewController = segue.destinationViewController
    }
}


class DestinationViewController: UIViewController {
    var modelData: String!
}

class NotUsedViewController: UIViewController {}
