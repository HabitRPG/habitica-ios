//
//  GuidelinesViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down
import SwiftUIX

class GuidelinesViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    let activityIndicator = UIHostingView(rootView: HabiticaProgressView())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(activityIndicator)
        
        navigationItem.title = L10n.Titles.guidelines
        
        let urlString = "https://s3.amazonaws.com/habitica-assets/mobileApp/endpoint/community-guidelines.md"
        guard let url = URL(string: urlString) else {
            return
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let text = try? String(contentsOf: url) {
                let attributed = try? Down(markdownString: text).toHabiticaAttributedString()
                DispatchQueue.main.async {
                    self?.textView.attributedText = attributed
                    self?.textView.isHidden = false
                    self?.activityIndicator.isHidden = true
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicator.pin.center().size(44)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
