//
//  ListMembersViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 07/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ListMembersViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
    var statusesMembers: [Account] = []
    var listID: String = ""
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Table
        let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0)
        self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
    }
    
    @objc func updatePosted() {
        print("toot toot")
    }
    
    @objc func scrollTop1() {
        if self.tableView.alpha == 1 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        GlobalStruct.currentTab = 999
    }
    
    @objc func refreshTable1() {
        self.tableView.reloadData()
    }
    
    @objc func notifChangeTint() {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "baseWhite")
        self.title = "Members".localized
//        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop1), name: NSNotification.Name(rawValue: "scrollTop1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable1), name: NSNotification.Name(rawValue: "refreshTable1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)

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
        self.tableView.register(FollowersCell.self, forCellReuseIdentifier: "FollowersCell")
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
        
        self.statusesMembers = []
        self.initialFetches()
        
        // Top buttons
        let tab0 = (self.navigationController?.navigationBar.bounds.height ?? 0) + 10
        let startHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + tab0
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        
        self.top1.frame = CGRect(x: Int(self.view.bounds.width) - 48, y: Int(startHeight + 6), width: 38, height: 38)
        self.top1.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.top1.backgroundColor = UIColor(named: "baseWhite")
        self.top1.layer.cornerRadius = 19
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
        let request = Lists.accounts(id: self.listID)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.statusesMembers = stat
                    self.tableView.reloadData()
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
        return self.statusesMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersCell", for: indexPath) as! FollowersCell
        if self.statusesMembers.isEmpty {} else {
            cell.configure(self.statusesMembers[indexPath.row])
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
            cell.profile.tag = indexPath.row
            cell.profile.addGestureRecognizer(tap)
        }

        cell.content.handleHashtagTap { (string) in
            let vc = HashtagViewController()
            vc.theHashtag = string
            self.navigationController?.pushViewController(vc, animated: true)
        }
        cell.content.handleURLTap { (string) in
            GlobalStruct.tappedURL = string
            ViewController().openLink()
        }
        
        cell.backgroundColor = UIColor(named: "baseWhite")
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = self.statusesMembers[gesture.view!.tag]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { return nil }, actionProvider: { suggestedActions in
            return self.makeContextMenu([self.statusesMembers[indexPath.row]], indexPath: indexPath)
        })
    }
    
    func makeContextMenu(_ status: [Account], indexPath: IndexPath) -> UIMenu {
        let remove = UIAction(title: "Remove".localized, image: UIImage(systemName: "xmark"), identifier: nil) { action in
            let request = Lists.remove(accountIDs: [self.statusesMembers[indexPath.row].id], fromList: self.listID)
            GlobalStruct.client.run(request) { (statuses) in
                DispatchQueue.main.async {
                    self.statusesMembers.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            }
        }
        remove.attributes = .destructive
        return UIMenu(__title: "", image: nil, identifier: nil, children: [remove])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = self.statusesMembers[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TootCell {
            cell.highlightCell()
        }
    }
    
    @objc func addTapped() {
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


