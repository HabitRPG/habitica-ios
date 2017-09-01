//
//  IntroViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 31/12/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import EAIntroView

class IntroViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var indicatorStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        endButton.isHidden = true
    }

    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        self.performSegue(withIdentifier: "LoginSegue", sender: self)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = getCurrentPage()
        updateIndicator(currentPage)

        if currentPage == 2 {
            skipButton.isHidden = true
            endButton.isHidden = false
        } else {
            skipButton.isHidden = false
            endButton.isHidden = true
            
        }
    }

    func updateIndicator(_ currentPage: Int) {
        for (index, element) in indicatorStackView.arrangedSubviews.enumerated() {
            if let indicatorView = element as? UIImageView {
                if index == currentPage {
                    indicatorView.image = #imageLiteral(resourceName: "indicatorDiamondSelected")
                } else {
                    indicatorView.image = #imageLiteral(resourceName: "indicatorDiamondUnselected")
                }
            }
        }
    }

    func getCurrentPage() -> Int {
        return Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginSegue" {
                if let loginViewController = segue.destination as? LoginTableViewController {
                    loginViewController.isRootViewController = true
                }
        }
    }
}
