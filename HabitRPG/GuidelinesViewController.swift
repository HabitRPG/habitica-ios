//
//  GuidelinesViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Down

class GuidelinesViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "https://s3.amazonaws.com/habitica-assets/mobileApp/endpoint/community-guidelines.md"
        guard let url = URL(string: urlString) else {
            return
        }
        if let text = try? String(contentsOf: url) {
            textView.attributedText = try? Down(markdownString: text).toHabiticaAttributedString()
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
