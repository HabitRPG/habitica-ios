//
//  IntroViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 31/12/2016.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

import UIKit
import EAIntroView

class IntroViewController: UIViewController, EAIntroDelegate {

    var intro: EAIntroView?
    
    override func viewDidLoad() {
        let titleposition = (self.view.frame.size.height / 2) - (self.view.frame.size.height / 16)
        
        let page1 = EAIntroPage()
        page1.title = "Welcome to Habitica".localized
        page1.titlePositionY = titleposition;
        page1.titleFont = UIFont.boldSystemFont(ofSize: 20.0)
        page1.desc = "Join over 900,000 people having fun while getting things done. Create an avatar and track your real-life tasks.".localized
        page1.descPositionY = titleposition - 24
        page1.descFont = UIFont.systemFont(ofSize: 14.0);
        page1.titleIconView = UIImageView(image: #imageLiteral(resourceName: "IntroPage1"))
        page1.titleIconPositionY = titleposition - 90
        
        weak var weakPage1 = page1
        page1.onPageDidLoad = {
            weakPage1?.titleIconView.alpha = 0
        }
        page1.onPageDidDisappear = {
            weakPage1?.titleIconView.alpha = 0
        }
        page1.onPageDidAppear = {
            UIView .animate(withDuration: 0.8, animations: { 
                weakPage1?.titleIconView.alpha = 1
            })
        };
        
        let page2 = EAIntroPage()
        page2.title = "Game Progress = Life Progress".localized
        page2.titlePositionY = titleposition;
        page2.titleFont = UIFont.boldSystemFont(ofSize: 20.0)
        page2.desc = "Unlock features in the game by checking off your real-life tasks. Earn armor, pets, and more to reward you for meeting your goals!".localized
        page2.descPositionY = titleposition - 24
        page2.descFont = UIFont.systemFont(ofSize: 14.0)
        page2.titleIconView = UIImageView(image: #imageLiteral(resourceName: "IntroPage2"))
        page2.titleIconPositionY = titleposition - 220
        weak var weakPage2 = page2
        page2.onPageDidLoad = {
            weakPage2?.titleIconView.alpha = 0
        }
        page2.onPageDidDisappear = {
            weakPage2?.titleIconView.alpha = 0
        }
        page2.onPageDidAppear = {
            UIView .animate(withDuration: 0.8, animations: {
                weakPage2?.titleIconView.alpha = 1
            })
        };
        let page3 = EAIntroPage();
        page3.titlePositionY = titleposition;
        page3.titleFont = UIFont.boldSystemFont(ofSize: 20.0)
        page3.title = "Get Social and Fight Monsters".localized
        page3.desc = "Keep your goals on track with help from your friends. Support each other in life and in battle as you improve together!".localized
        page3.descPositionY = titleposition - 24
        page3.descFont = UIFont.systemFont(ofSize: 14.0)
        page3.titleIconView = UIImageView(image: #imageLiteral(resourceName: "IntroPage3"))
        page3.titleIconPositionY = titleposition - 230
        
        weak var weakPage3 = page3
        page3.onPageDidLoad = {
            weakPage3?.titleIconView.alpha = 0
        }
        page3.onPageDidDisappear = {
            weakPage3?.titleIconView.alpha = 0
        }
        page3.onPageDidAppear = {
            UIView .animate(withDuration: 0.8, animations: {
                weakPage3?.titleIconView.alpha = 1
            })
        };
        
        
        self.intro = EAIntroView(frame: self.view.frame, andPages: [page1, page2, page3])
        self.intro?.bgImage = #imageLiteral(resourceName: "IntroBackground")
        self.intro?.delegate = self
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.intro?.show(in: self.view)
    }
    
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        self.performSegue(withIdentifier: "LoginSegue", sender: self)
    }
    
}
