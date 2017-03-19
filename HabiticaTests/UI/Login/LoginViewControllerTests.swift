//
//  LoginViewControllerTests.swift
//  Habitica
//
//  Created by Phillip Thelen on 29/12/2016.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

@testable import Habitica

class LoginViewControllerTests: HabiticaTests {

    var navigationController: UINavigationController?
    var loginViewController: LoginTableViewController?
    
    override func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
        
        self.navigationController = (UIStoryboard(name: "Main", bundle: Bundle(identifier: Bundle.main.bundleIdentifier!))
            .instantiateViewController(withIdentifier: "LoginNavigationController") as? UINavigationController)!
        
        self.loginViewController = self.navigationController!.topViewController as? LoginTableViewController
        //need this to properly initialize view
        let _ = self.loginViewController?.view
        self.loginViewController?.bindViewModel()
        self.isDeviceAgnostic = true
        self.recordMode = true
    }
    
    override func tearDown() {
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }
    
    func testLoginView_Login() {
        TraitController.defaultTraitConfigs.forEach { (device, orientation) in
            let (sparent, _) = traitControllers(device: device, orientation: orientation, child: self.navigationController!)
            FBSnapshotVerifyView(sparent.view, identifier: "\(device)_\(orientation)")
        }
    }
    
    func testLoginScreen_Register() {
        self.loginViewController!.authTypeButtonTapped()
        TraitController.defaultTraitConfigs.forEach { (device, orientation) in
            let (sparent, _) = traitControllers(device: device, orientation: orientation, child: self.navigationController!)
            FBSnapshotVerifyView(sparent.view, identifier: "\(device)_\(orientation)")
        }
    }
    
}
