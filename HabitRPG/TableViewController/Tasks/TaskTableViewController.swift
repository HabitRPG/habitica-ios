//
//  TaskTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 6/21/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class TaskTableViewController: HRPGBaseViewController, UISearchBarDelegate, UITableViewDragDelegate, UITableViewDropDelegate, DataSourceEmptyDelegate {
    public var dataSource: TaskTableViewDataSourceProtocol?
    public var filterType: Int = 0
    @objc public var scrollToTaskAfterLoading: String?
    var readableName: String?
    var typeName: String?
    var extraCellSpacing: Int = 0
    var searchBar: UISearchBar?
    var scrollTimer: Timer?
    var autoScrollSpeed: CGFloat = 0.0
    var movedTask: TaskProtocol?
    var heightAtIndexPath = NSMutableDictionary()
    var editable: Bool = false
    var sourceIndexPath: IndexPath?
    var snapshot: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource?.tableView = tableView
        dataSource?.emptyDelegate = self
        
        let nib = UINib(nibName: getCellNibName() ?? "", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        coachMarks = ["addTask", "editTask", "filterTask", "reorderTask"]
        
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl = refresher
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 48))
        searchBar?.placeholder = NSLocalizedString("Search", comment: "")
        searchBar?.delegate = self
        searchBar?.backgroundImage = UIImage()
        tableView.tableHeaderView = searchBar
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeFilter), name: NSNotification.Name(rawValue: "taskFilterChanged"), object: nil)
        didChangeFilter()
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            extraCellSpacing = 8
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView()
        
        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
            tableView.dragInteractionEnabled = true
        } else {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognized))
            tableView.addGestureRecognizer(longPress)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let searchString = HRPGSearchDataManager.shared().searchString, searchString != "" {
            searchBar?.text = searchString
        } else {
            searchBar?.text = ""
            searchBar?.setShowsCancelButton(false, animated: true)
        }
        
        tableView.reloadData()
        
        navigationItem.rightBarButtonItem?.accessibilityLabel = String(format: NSLocalizedString("Add %@", comment: ""), readableName ?? "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let taskId = scrollToTaskAfterLoading {
            scrollToTask(with: taskId)
            scrollToTaskAfterLoading = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
    }
    
    @objc
    func refresh() {
        weak var weakSelf = self
        dataSource?.retrieveData(completed: {
            weakSelf?.refreshControl?.endRefreshing()
        })
    }
    
    @objc
    func didChangeFilter() {
        let defaults = UserDefaults.standard
        filterType = defaults.integer(forKey: "\(typeName ?? "")Filter")
        
        dataSource?.predicate = getPredicate()
        if typeName == "todo" && filterType == 1 {
            dataSource?.sortKey = "duedate"
        } else {
            dataSource?.sortKey = "order"
        }
        tableView.reloadData()
        
        var filterCount = 0
        if filterType != 0 {
            filterCount += 1
        }
        
        if let tabBarController = tabBarController as? MainTabBarController {
            filterCount += tabBarController.selectedTags.count
        }
        
        if filterCount == 0 {
            navigationItem.leftBarButtonItem?.title = NSLocalizedString("Filter", comment: "")
        } else if filterCount == 1 {
            navigationItem.leftBarButtonItem?.title = NSLocalizedString("1 Filter", comment: "")
        } else {
            navigationItem.leftBarButtonItem?.title = String(format: NSLocalizedString("%ld Filters", comment: "more than one filter"), filterCount)
        }
    }
    
    @objc
    @IBAction
    func longPressRecognized(sender: Any?) {
        if let longPress = sender as? UILongPressGestureRecognizer {
            let location = longPress.location(in: tableView)
            guard let indexPath = tableView.indexPathForRow(at: location) else {
                return
            }
            
            switch longPress.state {
            case .began:
                sourceIndexPath = indexPath
                
                if let cell = tableView.cellForRow(at: indexPath) {
                    
                    if let snapshot = customSnapshotFromView(inputView: cell) {
                        self.snapshot = snapshot
                        snapshot.alpha = 0
                        
                        var center = cell.center
                        snapshot.center = center
                        tableView.addSubview(snapshot)
                        
                        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.75, options: UIViewAnimationOptions.init(rawValue: 0), animations: {
                            center.y = location.y
                            snapshot.center = center
                            snapshot.transform = CGAffineTransform(scaleX: 1.075, y: 1.075)
                            snapshot.alpha = 0.98
                            cell.alpha = 0.0
                        }) { _ in
                            cell.isHidden = true
                        }
                    }
                }
            case .changed:
                if let sourcePath = sourceIndexPath, indexPath != sourcePath {
                    dataSource?.userDrivenDataUpdate = true
                    if let sourceTask = dataSource?.task(at: sourcePath), let task = dataSource?.task(at: indexPath) {
                        let sourceOrder = sourceTask.order
                        sourceTask.order = task.order
                        task.order = sourceOrder
                    }
                    
                    tableView.moveRow(at: sourcePath, to: indexPath)
                    sourceIndexPath = indexPath
                    dataSource?.userDrivenDataUpdate = false
                }
                
                if var center = snapshot?.center {
                    center.y = location.y
                    snapshot?.center = center
                    
                    let positionInTableView = view.convert(center, from: snapshot?.superview).y - tableView.contentOffset.y
                    let bottomThreshold = tableView.frame.size.height - 120
                    let topThreshold = tableView.frame.origin.y + 120
                    if positionInTableView > bottomThreshold {
                        if autoScrollSpeed == 0 {
                            startAutoScrolling()
                        }
                        autoScrollSpeed = (positionInTableView - bottomThreshold) / 12
                    } else if positionInTableView < topThreshold {
                        if autoScrollSpeed == 0 {
                            startAutoScrolling()
                        }
                        autoScrollSpeed = (positionInTableView - topThreshold) / 12
                    } else {
                        autoScrollSpeed = 0
                    }
                }
            default:
                if let sourceIndexPath = sourceIndexPath, let task = dataSource?.task(at: sourceIndexPath) {
                    dataSource?.moveTask(task: task, toPosition: task.order, completion: {})
                    let cell = tableView.cellForRow(at: sourceIndexPath)
                    cell?.alpha = 0.0
                    UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: UIViewAnimationOptions(rawValue: 0), animations: {
                        self.snapshot?.transform = CGAffineTransform.identity
                    }, completion: nil)
                }
            }
        }
    }
    
    func getCellNibName() -> String? {
        return nil
    }
    
    func scrollToTask(with taskId: String) {
        if let index = dataSource?.tasks.indices.filter({ dataSource?.tasks[$0].id == taskId }).first {
            let indexPath = IndexPath(item: index, section: 0)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    func getPredicate() -> NSPredicate {
        var predicates = [NSPredicate]()
        
        if let tabBarController = tabBarController as? MainTabBarController {
            if let dataSource = dataSource {
                predicates.append(contentsOf: dataSource.predicates(filterType: filterType))
                
                let selectedTags = tabBarController.selectedTags
                if selectedTags.count > 0 {
                    predicates.append(NSPredicate(format: "SUBQUERY(realmTags, $tag, $tag.id IN %@).@count = %d", selectedTags, selectedTags.count))
                }
            }
        }
        
        if let search = HRPGSearchDataManager.shared().searchString {
            predicates.append(NSPredicate(format: "(text CONTAINS[cd] %@) OR (notes CONTAINS[cd] %@)", search, search))
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    override func getFrameForCoachmark(_ coachMarkIdentifier: String!) -> CGRect {
        let provider = HRPGCoachmarkFrameProvider()
        provider.view = self.view
        provider.tableView = self.tableView
        provider.navigationItem = self.navigationItem
        provider.parentViewController = self.parent
        return provider.getFrameForCoachmark(coachMarkIdentifier)
    }
    
    override func getDefinitonForTutorial(_ tutorialIdentifier: String!) -> [AnyHashable: Any]! {
        return HRPGCoachmarkFrameProvider().getDefinitonForTutorial(tutorialIdentifier)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar?.resignFirstResponder()
        searchBar?.setShowsCancelButton(false, animated: true)
    }
    
    @IBAction func unwindFilterChanged(segue: UIStoryboardSegue?) {
        if let tagVC = segue?.source as? HRPGFilterViewController {
            if let tabVC = tabBarController as? MainTabBarController {
                tabVC.selectedTags = tagVC.selectedTags
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "taskFilterChanged"), object: nil)
            }
        }
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath, animated: Bool) {
        // NO OP: override me!
    }
    
    func viewWithIcon(image: UIImage) -> UIView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        return imageView
    }
    
    func customSnapshotFromView(inputView: UIView) -> UIView? {
        // Make an image from the input view.
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            inputView.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Create an image view.
        let snapshot: UIView = UIImageView(image: image)
        snapshot.layer.masksToBounds = true
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        
        return snapshot
    }
    
    // MARK: - Empty delegate
    
    func dataSourceHasItems() {
        tableView.dataSource = dataSource as? UITableViewDataSource
        tableView.reloadData()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = true
    }
    
    func dataSourceIsEmpty() {
        // NO OP: override me!
    }
    
    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height: NSNumber = heightAtIndexPath[indexPath] as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSource?.selectRowAt(indexPath: indexPath)
        performSegue(withIdentifier: "FormSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Drop delegate
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        if let movedTask = movedTask, let destIndexPath = coordinator.destinationIndexPath {
            let order = movedTask.order
            let sourceIndexPath = IndexPath(row: order, section: 0)
            dataSource?.fixTaskOrder(movedTask: movedTask, toPosition: destIndexPath.item)
            dataSource?.moveTask(task: movedTask, toPosition: destIndexPath.item, completion: {
                self.dataSource?.userDrivenDataUpdate = false
            })
            if tableView.numberOfRows(inSection: 0) <= order && tableView.numberOfRows(inSection: 0) <= destIndexPath.item {
                tableView.moveRow(at: sourceIndexPath, to: destIndexPath)
            } else {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Drag delegate
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        movedTask = dataSource?.task(at: indexPath)
        sourceIndexPath = indexPath
        let itemProvider = NSItemProvider()
        if let taskName = movedTask?.text {
            let data = taskName.data(using: .utf16)
            
            itemProvider.registerDataRepresentation(forTypeIdentifier: String(kUTTypeUTF16PlainText), visibility: .ownProcess, loadHandler: { (completionHandler) -> Progress? in
                completionHandler(data, nil)
                return nil
            })
            dataSource?.userDrivenDataUpdate = true
        }
        return [UIDragItem(itemProvider: itemProvider)]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let movedTask = movedTask {
            dataSource?.moveTask(task: movedTask, toPosition: destinationIndexPath.item, completion: {
                self.dataSource?.userDrivenDataUpdate = false
            })
        }
    }
    
    // MARK: - Search
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        HRPGSearchDataManager.shared().searchString = searchText
        
        if searchText == "" {
            HRPGSearchDataManager.shared().searchString = nil
        }
        
        dataSource?.predicate = getPredicate()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        
        HRPGSearchDataManager.shared().searchString = nil
        
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FormSegue" {
            if let destinationVC = segue.destination as? TaskFormVisualEffectsModalViewController {
                if let typeName = self.typeName {
                    destinationVC.setTaskTypeString(type: typeName)
                }
                if let task = dataSource?.taskToEdit {
                    dataSource?.taskToEdit = nil
                    destinationVC.taskId = task.id
                    destinationVC.isCreating = false
                } else {
                    destinationVC.isCreating = true
                }
            }
        } else if segue.identifier == "FilterSegue" {
            if let tabVC = tabBarController as? MainTabBarController,
                let navVC = segue.destination as? HRPGNavigationController,
                let filterVC = navVC.topViewController as? HRPGFilterViewController {
                navVC.sourceViewController = self
                filterVC.selectedTags = tabVC.selectedTags
                filterVC.taskType = typeName
            }
        }
    }
    
    func startAutoScrolling() {
        if scrollTimer == nil {
            scrollTimer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(autoscrollTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc
    func autoscrollTimer() {
        if autoScrollSpeed == 0 {
            scrollTimer?.invalidate()
            scrollTimer = nil
        } else {
            let scrollPoint = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + autoScrollSpeed)
            if scrollPoint.y > -tableView.contentInset.top && scrollPoint.y < (tableView.contentSize.height - tableView.frame.size.height) {
                tableView.setContentOffset(scrollPoint, animated: false)
            }
        }
    }
}
