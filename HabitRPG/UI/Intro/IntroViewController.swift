//
//  IntroViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 31/12/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import UIKit

struct IntroPage<TitleView: View, SubtitleView: View>: View {
    let startColor: Color
    let endColor: Color
    let title: TitleView
    let subtitle: SubtitleView
    let image: Image
    
    var body: some View {
        VStack(spacing: 24) {
            title.font(.title).foregroundColor(.white).multilineTextAlignment(.center)
            image
            subtitle.font(.subheadline).foregroundColor(.white).multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .top, endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all))
    }
}

private struct Indicator: View {
    var currentPage: Int
    var pageCount: Int
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                ForEach(0..<pageCount) { _ in
                    Image(Asset.indicatorDiamondUnselected.name)
                }
            }
            Image(Asset.indicatorDiamondSelected.name)
                .rotationEffect(.degrees(Double(360 * currentPage)))
                .padding(.leading, 24 * CGFloat(currentPage))
                .animation(.interactiveSpring())
        }
    }
}

struct IntroView: View {
    var finishIntro: (() -> Void)?
    
    var pages: [AnyView] = [
        AnyView(IntroPage(startColor: Color(.purple400), endColor: Color(.purple100), title: VStack(spacing: 4) {
            Text(L10n.Intro.Card1.title)
            Image(Asset.introTitle.name)
        }, subtitle: Text(L10n.Intro.Card1.text), image: Image(Asset.introPage1.name))),
        AnyView(IntroPage(startColor: Color(.blue100), endColor: Color(.blue1), title: Text(L10n.Intro.Card2.title), subtitle: Text(L10n.Intro.Card2.text), image: Image(Asset.introPage2.name))),
        AnyView(IntroPage(startColor: Color(.red100), endColor: Color(.red1), title: Text(L10n.Intro.Card3.title), subtitle: Text(L10n.Intro.Card3.text), image: Image(Asset.introPage3.name)))
    ]
    @State private var currentPage = 0
    @State private var scrollOffset: CGFloat = 0
    
    var isLastPage: Bool {
        return currentPage + 1 == pages.count
    }
    
    private var indicatorAlignment: Alignment {
        if currentPage == 0 {
            return .leading
        } else if currentPage == 1 {
            return .center
        } else {
            return .trailing
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
ZStack(alignment: .bottom) {
    PageViewController(pages: pages, currentPage: $currentPage, scrollOffset: $scrollOffset)
            VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        Button(action: {
                            if let action = finishIntro {
                                action()
                            }
                        }, label: {
                            Text(L10n.skip)
                        }).foregroundColor(.white)
                        .padding()
                        .opacity(isLastPage ? 0 : 1)
                        .animation(.spring())
                    }.padding(.top, geometry.safeAreaInsets.top)
                Spacer()
                Indicator(currentPage: currentPage, pageCount: pages.count)
                Button(action: {
                    withAnimation {
                        if isLastPage {
                            if let action = finishIntro {
                                action()
                            }
                        } else {
                            currentPage += 1
                        }
                    }
                }, label: {
                    Text(isLastPage ? L10n.getStarted : L10n.next).padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                })
            }
            .padding(.bottom, geometry.safeAreaInsets.bottom + 12)
            .padding(.horizontal, 20)
            .edgesIgnoringSafeArea(.bottom)
        }
        .edgesIgnoringSafeArea(.all)
        }
    }
}

class IntroViewController: UIHostingController<IntroView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: IntroView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        rootView.finishIntro = {[weak self] in
            self?.perform(segue: StoryboardSegue.Intro.loginSegue)
        }
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginSegue" {
                if let loginViewController = segue.destination as? LoginTableViewController {
                    loginViewController.isRootViewController = true
                }
        }
    }
}

struct IntroViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            IntroView {
                
            }
        }
    }
}

struct PageViewController<Page: View>: UIViewControllerRepresentable {
    var pages: [Page]
    @Binding var currentPage: Int
    @Binding var scrollOffset: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        for subview in pageViewController.view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.delegate = context.coordinator
                break
            }
        }
        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers(
            [context.coordinator.controllers[currentPage]], direction: .forward, animated: true)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
        var parent: PageViewController
        var controllers = [UIViewController]()

        init(_ pageViewController: PageViewController) {
            parent = pageViewController
            controllers = parent.pages.map { UIHostingController(rootView: $0) }
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return nil
            }
            return controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == controllers.count {
                return nil
            }
            return controllers[index + 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool) {
            if completed,
               let visibleViewController = pageViewController.viewControllers?.first,
               let index = controllers.firstIndex(of: visibleViewController) {
                parent.currentPage = index
            }
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if parent.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width {
                scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
            } else if parent.currentPage == parent.pages.count - 1 && scrollView.contentOffset.x > (scrollView.bounds.size.width + 2) && scrollView.isTracking {
                scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
            }
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            if parent.currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width {
                targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0)
            } else if parent.currentPage == parent.pages.count - 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width {
                targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0)
            }
        }
    }
}

/*class IntroViewController: UIViewController, UIScrollViewDelegate {

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
*/
