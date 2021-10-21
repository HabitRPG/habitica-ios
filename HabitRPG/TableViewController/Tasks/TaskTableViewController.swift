//
//  TaskTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 6/21/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class TaskTableViewController: BaseTableViewController, UISearchBarDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    public var dataSource: TaskTableViewDataSource?
    public var filterType: Int = 0
    private let configRepository = ConfigRepository.shared
    @objc public var scrollToTaskAfterLoading: String?
    var readableName: String?
    var typeName: String?
    var extraCellSpacing: Int = 0
    var searchBar = UISearchBar()
    var scrollTimer: Timer?
    var autoScrollSpeed: CGFloat = 0.0
    var movedTask: TaskProtocol?
    var heightAtIndexPath = NSMutableDictionary()
    var editable: Bool = false
    var sourceIndexPath: IndexPath?
    var snapshot: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDataSource()
        dataSource?.tableView = tableView
        dataSource?.onOpenForm = {[weak self] indexPath in
            self?.handleOpenForm(at: indexPath)
        }
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "emptyCell")
        tableView.register(AdventureGuideTableViewCell.self, forCellReuseIdentifier: "adventureGuideCell")

        let nib = UINib(nibName: getCellNibName() ?? "", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
                
        #if !targetEnvironment(macCatalyst)
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl = refresher
        #endif
        
        searchBar.placeholder = L10n.search
        searchBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeFilter), name: NSNotification.Name(rawValue: "taskFilterChanged"), object: nil)
        didChangeFilter()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            extraCellSpacing = 8
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        
        navigationItem.leftBarButtonItem?.title = L10n.filter
    }
    
    func createDataSource() {
        
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        if theme.isDark {
            searchBar.barStyle = .black
            searchBar.isTranslucent = true
        } else {
            searchBar.barStyle = .default
            searchBar.isTranslucent = false
        }
        searchBar.backgroundColor = theme.contentBackgroundColor
        tableView.backgroundColor = theme.contentBackgroundColor
        tableView.separatorColor = theme.contentBackgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let searchString = HRPGSearchDataManager.shared().searchString, searchString.isEmpty == false {
            searchBar.text = searchString
        } else {
            searchBar.text = ""
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        if dataSource == nil {
            createDataSource()
        }
        dataSource?.tableView = tableView
        
        navigationItem.rightBarButtonItem?.accessibilityLabel = L10n.Tasks.addX(readableName ?? "")
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
        tableView.layoutMargins = UIEdgeInsets.zero
    }
    
    @objc
    func refresh() {
        dataSource?.retrieveData(completed: { [weak self] in
            self?.refreshControl?.endRefreshing()
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
        
        navigationItem.leftBarButtonItem?.image = HabiticaIcons.imageOfTaskFilterIcon(filter_active: filterCount > 0)
    }
    
    func configureTitle(_ title: String) {
        navigationItem.title = title
    }
    
    func getCellNibName() -> String? {
        return nil
    }
    
    func scrollToTask(with taskId: String) {
        if let index = dataSource?.tasks.indices.first(where: { dataSource?.tasks[$0].id == taskId }) {
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
                if selectedTags.isEmpty == false {
                    predicates.append(NSPredicate(format: "SUBQUERY(realmTags, $tag, $tag.id IN %@).@count = %d", selectedTags, selectedTags.count))
                }
            }
        }
        
        if let search = HRPGSearchDataManager.shared().searchString {
            predicates.append(NSPredicate(format: "(text CONTAINS[cd] %@) OR (notes CONTAINS[cd] %@)", search, search))
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        if searchBar.text?.isEmpty == true {
            hideSearchBar()
        }
    }
    
    @IBAction func unwindFilterChanged(segue: UIStoryboardSegue?) {
        if let tagVC = segue?.source as? FilterViewController {
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
    
    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height: NSNumber = heightAtIndexPath[indexPath] as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        #if targetEnvironment(simulator)
        if HabiticaAppDelegate.isRunningScreenshots() {
            let levelUpView = LevelUpOverlayView()
            levelUpView.show()
            return
        }
        #endif
        if dataSource?.showingAdventureGuide == true && indexPath.item == 0 && indexPath.section == 0 {
            perform(segue: StoryboardSegue.Main.showAdventureGuide)
        } else {
            handleOpenForm(at: indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func handleOpenForm(at indexPath: IndexPath) {
        dataSource?.selectRowAt(indexPath: indexPath)
        if configRepository.bool(variable: .showTaskDetailScreen) {
            perform(segue: StoryboardSegue.Main.detailSegue)
        } else {
            perform(segue: StoryboardSegue.Main.formSegue)
        }
    }
    
    // MARK: - Drop delegate
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        if let movedTask = movedTask, let destIndexPath = coordinator.destinationIndexPath {
            let order = movedTask.order
            let sourceIndexPath = IndexPath(row: order, section: 0)
            var newPosition = destIndexPath.item
            if true {
                if (newPosition + 1) == dataSource?.tableView(tableView, numberOfRowsInSection: 0) {
                    newPosition = dataSource?.item(at: IndexPath(row: newPosition - 1, section: 0))?.order ?? newPosition
                } else {
                    newPosition = (dataSource?.item(at: IndexPath(row: newPosition + 1, section: 0))?.order ?? newPosition) - 1
                }
            }
            dataSource?.fixTaskOrder(movedTask: movedTask, toPosition: newPosition)
            dataSource?.moveTask(task: movedTask, toPosition: newPosition, completion: {[weak self] in
                self?.dataSource?.userDrivenDataUpdate = false
            })
            if tableView.numberOfRows(inSection: 0) <= order && tableView.numberOfRows(inSection: 0) <= destIndexPath.item {
                tableView.moveRow(at: sourceIndexPath, to: destIndexPath)
            } else {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Drag delegate
    
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
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let movedTask = movedTask {
            dataSource?.moveTask(task: movedTask, toPosition: destinationIndexPath.item, completion: {[weak self] in
                self?.dataSource?.userDrivenDataUpdate = false
            })
        }
    }
    
    // MARK: - Search

    private func hideSearchBar() {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchBar.alpha = 0
        }, completion: { _ in
            self.searchBar.removeFromSuperview()
        })
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        HRPGSearchDataManager.shared().searchString = searchText
        
        if searchText.isEmpty {
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
        hideSearchBar()
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FormSegue" {
            if let destinationVC = segue.destination as? UINavigationController {
                guard let formController = destinationVC.topViewController as? TaskFormController else {
                    return
                }
                if let typeName = self.typeName, let type = TaskType(rawValue: typeName) {
                    formController.taskType = type
                }
                if let task = dataSource?.taskToEdit {
                    dataSource?.taskToEdit = nil
                    formController.editedTask = task
                } else {
                    formController.editedTask = nil
                }
            }
        } else if segue.identifier == "DetailSegue" {
            if let destinationVC = segue.destination as? UINavigationController {
                guard let detailController = destinationVC.topViewController as? TaskDetailViewController else {
                    return
                }
                if let task = dataSource?.repository.getEditableTask(id: dataSource?.taskToEdit?.id ?? "") {
                    dataSource?.taskToEdit = nil
                    detailController.task = task
                }
            }
        } else if segue.identifier == "FilterSegue" {
            if let tabVC = tabBarController as? MainTabBarController,
                let navVC = segue.destination as? UINavigationController,
                let filterVC = navVC.topViewController as? FilterViewController {
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections(in: tableView) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.tableView(tableView, numberOfRowsInSection: section) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dataSource?.tableView(tableView, cellForRowAt: indexPath) ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dataSource?.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        navigationController?.navigationBar.addSubview(searchBar)
        searchBar.frame = CGRect(x: 12, y: 0, width: tableView.bounds.size.width - 24, height: navigationController?.navigationBar.frame.size.height ?? 48)
        searchBar.becomeFirstResponder()
        searchBar.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.searchBar.alpha = 1
        }
    }
}
