//
//  GuidelinesViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Alamofire
import Down

class GuidelinesViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request("https://s3.amazonaws.com/habitica-assets/mobileApp/endpoint/community-guidelines.md").responseString {[weak self] response in
            
            if let text = response.result.value {
                self?.textView.attributedText = try? Down(markdownString: text).toHabiticaAttributedString()
            }
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
