//
//  IntroViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 31/12/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var indicatorStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cardOneTitle: UILabel!
    @IBOutlet weak var cardOneText: UILabel!
    @IBOutlet weak var cardTwoTitle: UILabel!
    @IBOutlet weak var cardTwoSubtitle: UILabel!
    @IBOutlet weak var cardTwoText: UILabel!
    @IBOutlet weak var cardThreeTitle: UILabel!
    @IBOutlet weak var cardThreeSubtitle: UILabel!
    @IBOutlet weak var cardThreeText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        populateText()
        
        endButton.isHidden = true
    }
    
    func populateText() {
        endButton.setTitle(L10n.Intro.letsGo, for: .normal)
        skipButton.setTitle(L10n.skip, for: .normal)
        cardOneTitle.text = L10n.Intro.Card1.title
        cardOneText.text = L10n.Intro.Card1.text
        cardTwoTitle.text = L10n.Intro.Card2.title
        cardTwoSubtitle.text = L10n.Intro.Card2.subtitle
        cardTwoText.text = L10n.Intro.Card2.text
        cardThreeTitle.text = L10n.Intro.Card3.title
        cardThreeSubtitle.text = L10n.Intro.Card3.subtitle
        cardThreeText.text = L10n.Intro.Card3.text
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
