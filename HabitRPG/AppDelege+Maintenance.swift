//
//  AppDelege+Maintenance.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.10.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//

import UIKit

// Maintenance
extension HabiticaAppDelegate {
    func handleMaintenanceScreen() -> Bool {
        let maintenanceData = configRepository.dictionary(variable: .maintenanceData)
        if let title = maintenanceData["title"] as? String, let descriptionString = maintenanceData["description"] as? String {
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
