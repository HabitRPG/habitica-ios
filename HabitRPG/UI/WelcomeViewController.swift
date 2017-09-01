//
//  WelcomeViewController.swift
//  Habitica
//
//  Created by Phillip on 08.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

class WelcomeViewController: UIViewController, TypingTextViewController {
    
    @IBOutlet weak var speechbubbleView: SpeechbubbleView!
    
    func startTyping() {
        speechbubbleView.animateTextView()
    }
    
}
