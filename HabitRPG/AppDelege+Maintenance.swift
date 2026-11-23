//
//  AppDelege+Maintenance.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.10.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

// Maintenance
extension HabiticaAppDelegate {
    func handleMaintenanceScreen() -> Bool {
        let maintenanceData = configRepository.value(for: .maintenanceData)
        if let title = maintenanceData["title"]?.stringValue, let descriptionString = maintenanceData["description"]?.stringValue {
            displayMaintenanceScreen(title: title, descriptionString: descriptionString)
            return true
        } else {
            hideMaintenanceScreen()
        }
        return false
    }
    
    func displayMaintenanceScreen(title: String, descriptionString: String) {
        if findMaintenanceScreen() == nil {
            let maintenanceController = MaintenanceViewController()
            maintenanceController.configure(title: title, descriptionString: descriptionString, showAppstoreButton: false)
            maintenanceController.modalPresentationStyle = .fullScreen
            maintenanceController.modalTransitionStyle = .crossDissolve
            UIApplication.topViewController()?.present(maintenanceController, animated: true, completion: nil)
        }
    }
    
    func hideMaintenanceScreen() {
        findMaintenanceScreen()?.dismiss(animated: true, completion: nil)
    }
    
    private func findMaintenanceScreen() -> MaintenanceViewController? {
        return UIWindow.findViewController()
    }
}
