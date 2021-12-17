//
//  EditingFormViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 06.12.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import UIKit

extension EditingFormViewController {
    static func buildWithUsernameField(title: String, subtitle: String, onSave: @escaping (String) -> Void, saveButtonTitle: String? = nil) -> UINavigationController {
        let controller = EditingFormViewController()
        controller.formTitle = title
        controller.saveButtonTitle = saveButtonTitle
        controller.fields.append(EditingTextField(key: "username", title: subtitle, type: .name, placeholder: L10n.username))
        controller.onSave = {values in
            if let username = values["username"] {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    onSave(username)
                })
            }
        }
        let navController = UINavigationController(rootViewController: controller)
        return navController
    }
}
