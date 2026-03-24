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
            title.font(.title).foregroundStyle(.white).multilineTextAlignment(.center)
            image
            subtitle.font(.subheadline).foregroundStyle(.white).multilineTextAlignment(.center)
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
                    Image(Asset.indicatorDiamondSelected.name).opacity(0.4)
                }
            }
            Image(uiImage: Asset.indicatorDiamondSelected.image.withRenderingMode(.alwaysTemplate))
                .padding(.leading, 24 * CGFloat(currentPage))
                .foregroundStyle(.white)
                .animation(.bouncy(), value: currentPage)
        }
    }
}

struct IntroView: View {
    var finishIntro: (() -> Void)?
    
    var pages: [AnyView] = [
        AnyView(IntroPage(startColor: Color(.purple400), endColor: Color(.purple300), title: VStack(spacing: 4) {
            Text(L10n.Intro.Card1.title)
            Image(Asset.introTitle.name)
        }, subtitle: Text(L10n.Intro.Card1.text), image: Image(Asset.introPage1.name))),
        AnyView(IntroPage(startColor: Color(.blue100), endColor: Color(.blue50), title: Text(L10n.Intro.Card2.title), subtitle: Text(L10n.Intro.Card2.text), image: Image(Asset.introPage2.name))),
        AnyView(IntroPage(startColor: Color(.red100), endColor: Color(.red50), title: Text(L10n.Intro.Card3.title), subtitle: Text(L10n.Intro.Card3.text), image: Image(Asset.introPage3.name)))
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
                                .padding()
                        }).foregroundStyle(.white)
                        .opacity(isLastPage ? 0 : 1)
                        .animation(.bouncy(), value: isLastPage)
                    }.padding(.top, geometry.safeAreaInsets.top)
                Spacer()
                Indicator(currentPage: currentPage, pageCount: pages.count)
                let button = Button(action: {
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
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                })
                
                if #available(iOS 26.0, *) {
                    button
                        .buttonStyle(.glass(.clear))
                } else {
                    button
                        .background(Color.black.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(UIConstants.largeCornerRadius)
                }
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
