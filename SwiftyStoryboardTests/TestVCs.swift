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
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        super.performSegue(withIdentifier: identifier, sender: sender)
        self.performSegueWithIdentifierCalled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        self.destinationViewController = segue.destination
    }
}


class DestinationViewController: UIViewController {
    var modelData: String!
}

class NotUsedViewController: UIViewController {}
