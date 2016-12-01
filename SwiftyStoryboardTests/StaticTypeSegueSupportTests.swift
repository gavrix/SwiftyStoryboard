//
//  StaticTypeSegueSupportTests.swift
//  SwiftyStoryboard
//
//  Created by Sergii Gavryliuk on 2016-07-25.
//  Copyright © 2016 Sergey Gavrilyuk. All rights reserved.
//

import XCTest

class StaticTypeSegueSupportTests: XCTestCase {
    
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
        testStoryboard = UIStoryboard(name: "StaticTypeSegueIdentifier", bundle: Bundle(for: type(of: self)))
    }
    
    func testRawSegueConfigure() {
        let sourceVC = self.sourceViewController
        let segueIdentifier = "Segue1"
        let modelData = "123"
        do {
            try sourceVC.performSegue(segueIdentifier) { (destinationVC:DestinationViewController) in
               destinationVC.modelData = modelData
            }
            XCTAssertNotNil(sourceVC.destinationViewController)
            XCTAssert(sourceVC.destinationViewController is DestinationViewController)
            let destinationVC = sourceVC.destinationViewController as! DestinationViewController
            XCTAssertEqual(destinationVC.modelData, modelData)
        } catch (let error as NSError){
            XCTFail("Runtime exception while performing segue \(segueIdentifier): \(error.localizedDescription)")
        } catch {}
    }
    
    func testRawSegueFailConfigure() {
        let sourceVC = self.sourceViewController
        let segueIdentifier = "Segue1"
        do {
            try sourceVC.performSegue(segueIdentifier) { (destinationVC:NotUsedViewController) in }
        } catch (let error as RuntimeTypeMismatchError){
            XCTAssertEqual(error.segueIdentifier, segueIdentifier)
            XCTAssert(error.expectedViewControllerType == NotUsedViewController.self)
            XCTAssert(error.actualViewControllerType == DestinationViewController.self)
        }
        catch (let error as NSError){
            XCTFail("Unexpected runtime exception while performing segue \(segueIdentifier): \(error.localizedDescription)")
        } catch {}
    }
    
    
}
