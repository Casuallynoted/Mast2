//
//  BlockedViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 06/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class BlockedViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    public var isSplitOrSlideOver: Bool {
        let windows = UIApplication.shared.windows
        for x in windows {
            if let z = self.view.window {
                if x == z {
                    if x.frame.width == x.screen.bounds.width || x.frame.width == x.screen.bounds.height {
                        return false
                    } else {
                        return true
                    }
                }
            }
        }
        return false
    }
    var tableView = UITableView()
    var loginBG = UIView()
    var refreshControl = UIRefreshControl()
    let top1 = UIButton()
    let btn2 = UIButton(type: .custom)
    var userId = GlobalStruct.currentUser.id
    var statusesBlocked: [Account] = []
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let tab0 = (self.navigationController?.navigationBar.bounds.height ?? 0) + 10
        let startHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + tab0
        self.top1.frame = CGRect(x: Int(self.view.bounds.width) - 48, y: Int(startHeight + 6), width: 38, height: 38)
        
        // Table
        let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0)
        self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
    }
    
    @objc func updatePosted() {
        print("toot toot")
    }
    
    @objc func scrollTop1() {
        if self.tableView.alpha == 1 && self.tableView.hasRowAtIndexPath(indexPath: IndexPath(row: 0, section: 0) as NSIndexPath) {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        GlobalStruct.currentTab = 999
        
        self.view.backgroundColor = GlobalStruct.baseDarkTint
    }
    
    @objc func refreshTable1() {
        self.tableView.reloadData()
    }
    
    @objc func notifChangeTint() {
        self.tableView.reloadData()
        
        self.tableView.reloadInputViews()
    }
    
    @objc func notifChangeBG() {
        GlobalStruct.baseDarkTint = (UserDefaults.standard.value(forKey: "sync-startDarkTint") == nil || UserDefaults.standard.value(forKey: "sync-startDarkTint") as? Int == 0) ? UIColor(named: "baseWhite")! : UIColor(named: "baseWhite2")!
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.barTintColor = GlobalStruct.baseDarkTint
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.title = "Blocked".localized
//        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop1), name: NSNotification.Name(rawValue: "scrollTop1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable1), name: NSNotification.Name(rawValue: "refreshTable1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)

        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.addTapped), for: .touchUpInside)
        btn1.accessibilityLabel = "Create".localized
        let addButton = UIBarButtonItem(customView: btn1)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {} else {
            self.navigationItem.setRightBarButton(addButton, animated: true)
        }
        
        // Table
        self.tableView.register(MuteBlockCell.self, forCellReuseIdentifier: "MuteBlockCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor(named: "baseBlack")?.withAlphaComponent(0.24)
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        
        self.refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        self.statusesBlocked = []
        self.initialFetches()
        
        // Top buttons
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        
        self.top1.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.top1.backgroundColor = UIColor.clear
        self.top1.layer.cornerRadius = 30
        self.top1.alpha = 0
        self.top1.addTarget(self, action: #selector(self.didTouchTop1), for: .touchUpInside)
        self.top1.accessibilityLabel = "Top".localized
        self.view.addSubview(self.top1)
    }
    
    @objc func didTouchTop1() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top1.alpha = 0
            self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    func initialFetches() {
        let request = Blocks.all()
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    if stat.isEmpty {
                        self.createEmptyState()
                    }
                    self.statusesBlocked = stat
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func createEmptyState() {
        let emptyView = UIView()
        emptyView.backgroundColor = .clear
        emptyView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        emptyView.center = self.view.center
        self.view.addSubview(emptyView)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let emptyImage = UIImageView()
        emptyImage.image = UIImage(systemName: "wind", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.14), renderingMode: .alwaysOriginal)
        emptyImage.frame = CGRect(x: 30, y: 10, width: 140, height: 140)
        emptyView.addSubview(emptyImage)
        
        let emptyText = UILabel()
        emptyText.text = "Nothing to see here".localized
        emptyText.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.14)
        emptyText.textAlignment = .center
        emptyText.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        emptyText.frame = CGRect(x: 0, y: 150, width: 200, height: 50)
        emptyView.addSubview(emptyText)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        let request = Blocks.all(range: .since(id: self.statusesBlocked.first?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                            self.top1.alpha = 1
                            self.top1.transform = CGAffineTransform(scaleX: 1, y: 1)
                        }) { (completed: Bool) in
                        }
                        let indexPaths = (0..<stat.count).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.statusesBlocked = stat + self.statusesBlocked
                        self.tableView.beginUpdates()
                        UIView.setAnimationsEnabled(false)
                        var heights: CGFloat = 0
                        let _ = indexPaths.map {
                            if let cell = self.tableView.cellForRow(at: $0) as? TootCell {
                                heights += cell.bounds.height
                            }
                            if let cell = self.tableView.cellForRow(at: $0) as? TootImageCell {
                                heights += cell.bounds.height
                            }
                        }
                        self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableView.setContentOffset(CGPoint(x: 0, y: heights), animated: false)
                        self.tableView.endUpdates()
                        UIView.setAnimationsEnabled(true)
                    }
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top1.alpha = 0
            self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statusesBlocked.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MuteBlockCell", for: indexPath) as! MuteBlockCell
        if self.statusesBlocked.isEmpty {} else {
            cell.configure(self.statusesBlocked[indexPath.row])
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
            cell.profile.tag = indexPath.row
            cell.profile.addGestureRecognizer(tap)
            if indexPath.row == self.statusesBlocked.count - 10 {
                self.fetchMoreHome()
            }
        }
        cell.backgroundColor = GlobalStruct.baseDarkTint
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if GlobalStruct.currentUser.id == (self.statusesBlocked[gesture.view!.tag].id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.statusesBlocked[gesture.view!.tag]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchMoreHome() {
        let request = Blocks.all(range: .max(id: self.statusesBlocked.last?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {} else {
                    DispatchQueue.main.async {
                        let indexPaths = ((self.statusesBlocked.count)..<(self.statusesBlocked.count + stat.count)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.statusesBlocked.append(contentsOf: stat)
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableView.endUpdates()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { return nil }, actionProvider: { suggestedActions in
            return self.makeContextMenu([self.statusesBlocked[indexPath.row]], indexPath: indexPath)
        })
    }
    
    func makeContextMenu(_ status: [Account], indexPath: IndexPath) -> UIMenu {
        let remove = UIAction(title: "Unblock".localized, image: UIImage(systemName: "xmark"), identifier: nil) { action in
            let request = Accounts.unblock(id: status.first?.id ?? "")
            GlobalStruct.client.run(request) { (statuses) in
                DispatchQueue.main.async {
                    self.statusesBlocked.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            }
        }
        remove.attributes = .destructive
        return UIMenu(title: "", image: nil, identifier: nil, children: [remove])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = self.statusesBlocked[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TootCell {
            cell.highlightCell()
        }
    }
    
    @objc func addTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addTapped"), object: self)
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
}




