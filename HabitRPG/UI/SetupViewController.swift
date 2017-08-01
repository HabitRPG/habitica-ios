//
//  SetupViewController.swift
//  Habitica
//
//  Created by Phillip on 28.07.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var pageIndicatorContainer: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nextButtonView: UIStackView!
    @IBOutlet weak var nextButtonTextView: UILabel!
    @IBOutlet weak var nextButtonImageView: UIImageView!
    
    @IBOutlet weak var previousButtonView: UIStackView!
    @IBOutlet weak var previousButtonTextView: UILabel!
    @IBOutlet weak var previousButtonImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nextGesture = UITapGestureRecognizer(target: self, action: #selector(scrollToNextPage))
        nextButtonView.addGestureRecognizer(nextGesture)
        let previousGesture = UITapGestureRecognizer(target: self, action: #selector(scrollToPreviousPage))
        previousButtonView.addGestureRecognizer(previousGesture)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = getCurrentPage()
        updateIndicator(currentPage)
    }
    
    func updateIndicator(_ currentPage: Int) {
        for (index, element) in pageIndicatorContainer.arrangedSubviews.enumerated() {
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
    
    func scrollToNextPage() {
        if getCurrentPage() >= 2 {
            return
        }
        scrollToPage(getCurrentPage()+1)
    }
    
    func scrollToPreviousPage() {
        if getCurrentPage() <= 0 {
            return
        }
        scrollToPage(getCurrentPage()-1)
    }
    
    func scrollToPage(_ page: Int) {
        let floatPage = CGFloat(page)
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.size.width*floatPage, y: 0), animated: true)
        updateIndicator(page)
        
        if page <= 0 {
            previousButtonTextView.text = nil
            previousButtonImageView.tintColor = UIColor.purple100()
        } else {
            previousButtonTextView.text = NSLocalizedString("Previous", comment: "")
            previousButtonImageView.tintColor = UIColor.white
        }
        if page >= 2 {
            nextButtonTextView.text = NSLocalizedString("Finish", comment: "")
        } else {
            nextButtonTextView.text = NSLocalizedString("Next", comment: "")
        }
    }
}
