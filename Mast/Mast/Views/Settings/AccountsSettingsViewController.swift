//
//  AccountsSettingsViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 08/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class AccountsSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.title = "Accounts".localized
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]
        
        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.addTapped), for: .touchUpInside)
        btn2.accessibilityLabel = "Add".localized
        let settingsButton = UIBarButtonItem(customView: btn2)
        self.navigationItem.setRightBarButton(settingsButton, animated: true)
        
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(AccountCell.self, forCellReuseIdentifier: "AccountCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = false
        self.view.addSubview(self.tableView)
        self.tableView.reloadData()
    }
    
    @objc func addTapped() {
        DispatchQueue.main.async {
            #if !targetEnvironment(macCatalyst)
//            if GlobalStruct.iapPurchased {
                let vc = UINavigationController(rootViewController: AddInstanceViewController())
                self.present(vc, animated: true, completion: {
                    
                })
//            } else {
//                let vc = IAPSettingsViewController()
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
            #elseif targetEnvironment(macCatalyst)
            let vc = UINavigationController(rootViewController: AddInstanceViewController())
            self.present(vc, animated: true, completion: {
                
            })
            #endif
        }
    }
    
    //MARK: TableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return Account.getAccounts().count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let instances = InstanceData.getAllInstances()
            if instances.isEmpty || Account.getAccounts().isEmpty {
                cell.accessoryType = .none
            } else {
                let curr = InstanceData.getCurrentInstance()
                if curr?.clientID == instances[indexPath.item].clientID {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
        } else {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
            cell.backgroundColor = GlobalStruct.baseDarkTint
            
            var instance: InstanceData? = nil
            if InstanceData.getAllInstances().count == 0 {} else {
                instance = InstanceData.getAllInstances()[indexPath.row]
            }
            let instanceAndAccount = "@\(instance?.returnedText ?? "")"
            
            let account = Account.getAccounts()[indexPath.item]
            cell.configure(account.displayName, op2: "@\(account.username)\(instanceAndAccount)", op3: account.avatar)
            
            let instances = InstanceData.getAllInstances()
            if instances.isEmpty || Account.getAccounts().isEmpty {
                cell.accessoryType = .none
            } else {
                let curr = InstanceData.getCurrentInstance()
                if curr?.clientID == instances[indexPath.item].clientID {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
            cell.textLabel?.text = "Clear Cache".localized
            cell.textLabel?.textColor = UIColor.systemRed
            cell.backgroundColor = GlobalStruct.baseDarkTint
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            DispatchQueue.main.async {
                
                let instances = InstanceData.getAllInstances()
                if instances.isEmpty || Account.getAccounts().isEmpty {
                    
                } else {
                    let curr = InstanceData.getCurrentInstance()
                    if curr?.clientID == instances[indexPath.item].clientID {
                        
                    } else {
                        InstanceData.setCurrentInstance(instance: instances[indexPath.item])
                        GlobalStruct.client = Client(
                            baseURL: "https://\(instances[indexPath.item].returnedText)",
                            accessToken: instances[indexPath.item].accessToken
                        )
                        self.tableView.reloadData()
                        FirstViewController().initialFetches()
                        
                        #if targetEnvironment(macCatalyst)
                        let rootController = ColumnViewController()
                        let nav0 = VerticalTabBarController()
                        let nav1 = ScrollMainViewController()
                        
                        let nav01 = UINavigationController(rootViewController: FirstViewController())
                        let nav02 = UINavigationController(rootViewController: SecondViewController())
                        let nav03 = UINavigationController(rootViewController: ThirdViewController())
                        let nav04 = UINavigationController(rootViewController: FourthViewController())
                        let nav05 = UINavigationController(rootViewController: FifthViewController())
                        nav1.viewControllers = [nav01, nav02, nav03, nav04, nav05]
                        
                        rootController.viewControllers = [nav0, nav1]
                        UIApplication.shared.keyWindow?.rootViewController = rootController
                        UIApplication.shared.keyWindow?.makeKeyAndVisible()
                        #elseif !targetEnvironment(macCatalyst)
                        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
                            let rootController = ColumnViewController()
                            let nav0 = VerticalTabBarController()
                            let nav1 = ScrollMainViewController()
                            
                            let nav01 = UINavigationController(rootViewController: FirstViewController())
                            let nav02 = UINavigationController(rootViewController: SecondViewController())
                            let nav03 = UINavigationController(rootViewController: ThirdViewController())
                            let nav04 = UINavigationController(rootViewController: FourthViewController())
                            let nav05 = UINavigationController(rootViewController: FifthViewController())
                            nav1.viewControllers = [nav01, nav02, nav03, nav04, nav05]
                            
                            rootController.viewControllers = [nav0, nav1]
                            UIApplication.shared.keyWindow?.rootViewController = rootController
                            UIApplication.shared.keyWindow?.makeKeyAndVisible()
                        } else {
                            UIApplication.shared.keyWindow?.rootViewController = ViewController()
                        }
                        #endif
                    }
                }
                
            }
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let op1 = UIAlertAction(title: "Clear Cache".localized, style: .destructive , handler:{ (UIAlertAction) in
                SDWebImageManager.shared.imageCache.clear(with: .all, completion: nil)
                SKCache.sharedCache.removeAllImages()
            })
            op1.setValue(UIImage(systemName: "xmark")!, forKey: "image")
            op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op1)
            alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                
            }))
            if let presenter = alert.popoverPresentationController {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) {
                    presenter.sourceView = cell
                    presenter.sourceRect = cell.bounds
                }
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { return nil }, actionProvider: { suggestedActions in
            let instances = InstanceData.getAllInstances()
            if instances.isEmpty || Account.getAccounts().isEmpty {
                return nil
            } else {
                let curr = InstanceData.getCurrentInstance()
                if curr?.clientID == instances[indexPath.item].clientID {
                    return nil
                } else {
                    return self.makeContextMenu([""], indexPath: indexPath)
                }
            }
        })
    }
    
    func makeContextMenu(_ status: [String], indexPath: IndexPath) -> UIMenu {
        let remove = UIAction(title: "Remove".localized, image: UIImage(systemName: "xmark"), identifier: nil) { action in
            var instance = InstanceData.getAllInstances()
            var account = Account.getAccounts()
            account.remove(at: indexPath.row)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(account), forKey:"allAccounts")
            instance.remove(at: indexPath.row)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(instance), forKey:"instances")
            self.tableView.reloadData()
        }
        remove.attributes = .destructive
        return UIMenu(title: "", image: nil, identifier: nil, children: [remove])
    }
}




