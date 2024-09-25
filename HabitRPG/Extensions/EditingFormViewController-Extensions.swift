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
        let socialRepository = SocialRepository()
        let controller = EditingFormViewController()
        controller.autoDismiss = false
        controller.formTitle = title
        controller.saveButtonTitle = saveButtonTitle
        controller.fields.append(EditingTextField(key: "username", title: subtitle, type: .name, placeholder: L10n.username))
        controller.onSave = {values in
            controller.isLoading(true)
            if let username = values["username"] {
                socialRepository.retrieveMemberWithUsername(username).on(value: { _ in
                    controller.dismiss()
                    onSave(username)
                }).observeCompleted {
                    controller.isLoading(false)
                }
            }
        }
        let navController = UINavigationController(rootViewController: controller)
        return navController
    }
}
