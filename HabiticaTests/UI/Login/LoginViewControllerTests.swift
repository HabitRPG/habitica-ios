//
//  LoginViewControllerTests.swift
//  Habitica
//
//  Created by Phillip Thelen on 29/12/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
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
        self.recordMode = false
    }
    
    override func tearDown() {
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }
    
}
