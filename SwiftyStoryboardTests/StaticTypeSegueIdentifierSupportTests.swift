//
//  SwiftyStoryboardTests.swift
//  SwiftyStoryboardTests
//
//  Created by Sergii Gavryliuk on 2016-07-24.
//  Copyright © 2016 Sergey Gavrilyuk. All rights reserved.
//

import XCTest
@testable import SwiftyStoryboard

class StaticTypeSegueIdentifierSupportTests: XCTestCase {
    
    var testStoryboard: UIStoryboard!
    var sourceViewController: SourceViewController {
        guard let sourceVC = testStoryboard.instantiateInitialViewController() as? SourceViewController  else {
            XCTFail("Initial view controller in storyboard is expected to be of type SourceViewController")
            fatalError()
        }
        return sourceVC
    }

    override func setUp() {
        super.setUp()
        testStoryboard = UIStoryboard(name: "StaticTypeSegueIdentifier", bundle: NSBundle(forClass: self.dynamicType))
    }
        
    func testTypedSegueIdentifier() {
        let sourceVC = self.sourceViewController
        let segueIdentifier = SourceViewController.SegueIdentifier.Segue1
        do {
            try sourceVC.performSegue(segueIdentifier)
            XCTAssert(sourceVC.performSegueWithIdentifierCalled)
        } catch (let error){
            XCTFail("Unexpected Runtime exception while performing segue \(segueIdentifier): \(error)")
        }
        
    }
    
    func testNonExistingSegueIdentifier() {
        let sourceVC = self.sourceViewController
        let segueIdentifier = SourceViewController.SegueIdentifier.Segue2
        XCTAssertThrowsError(try sourceVC.performSegue(segueIdentifier),
        "\(segueIdentifier) is expected to be not present on the scene and exception at runtime expected")
        { error in
            XCTAssert(error is RuntimeSegueIdentifierError, "Eexpected to throw error of type \(RuntimeSegueIdentifierError.self)")
        }
    }
    
    func testNonExistingSegueIdentifierString() {
        let sourceVC = self.sourceViewController
        let segueIdentifier = SourceViewController.SegueIdentifier.Segue2
        let mockSegue = UIStoryboardSegue(identifier: "NonExistingSegueIdentifier", source: sourceVC, destination: sourceVC)
        XCTAssertThrowsError(try sourceVC.segueIdentifierFromSegue(mockSegue),
                             "\(segueIdentifier) is expected to throw UknownSegueIdentifierStringError error")
        { error in
            XCTAssert(error is UknownSegueIdentifierStringError, "Eexpected to throw error of type \(UknownSegueIdentifierStringError.self)")
        }
    }
    
}
