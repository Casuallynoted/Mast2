//
//  ComposeCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 29/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class ComposeCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var textView = UITextView()
    var collectionView1: UICollectionView!
    var player = AVPlayer()
    let playerViewController = AVPlayerViewController()
    var images: [UIImage] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        let normalFont = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        self.textView.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        self.textView.textStorage.setAttributes([NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!], range: NSRange(location: 0, length: self.textView.text.count))
        self.textView.backgroundColor = UIColor.clear
        self.textView.showsVerticalScrollIndicator = false
        self.textView.showsHorizontalScrollIndicator = false
        self.textView.adjustsFontForContentSizeCategory = true
        self.textView.isSelectable = true
        self.textView.alwaysBounceVertical = true
        self.textView.isUserInteractionEnabled = true
        self.textView.isScrollEnabled = true
        self.textView.textContainerInset = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        if UserDefaults.standard.value(forKey: "sync-chosenKeyboard") as? Int == 0 {
            self.textView.keyboardType = .default
        } else {
            self.textView.keyboardType = .twitter
        }
        contentView.addSubview(self.textView)
        
        let layout = ColumnFlowLayout3(
            cellsPerRow: 4,
            minimumInteritemSpacing: 15,
            minimumLineSpacing: 15,
            sectionInset: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        )
        layout.scrollDirection = .horizontal
        collectionView1 = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(138)), collectionViewLayout: layout)
        collectionView1.translatesAutoresizingMaskIntoConstraints = false
        collectionView1.backgroundColor = UIColor.clear
        collectionView1.delegate = self
        collectionView1.dataSource = self
        collectionView1.showsHorizontalScrollIndicator = false
        collectionView1.register(ComposeImageCell.self, forCellWithReuseIdentifier: "ComposeImageCell")
        contentView.addSubview(collectionView1)
        
        let viewsDict = [
            "textView" : textView,
            "collectionView" : collectionView1,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[textView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[textView]-5-[collectionView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var heightConstraint = NSLayoutConstraint()
    var isVideo: Bool = false
    var videoURLs: [URL] = []
    func configure(_ images: [UIImage], isVideo: Bool, videoURLs: [URL]? = []) {
        self.images = images
        self.isVideo = isVideo
        self.videoURLs = videoURLs ?? []
        self.collectionView1.reloadData()
        
        self.collectionView1.removeConstraint(heightConstraint)
        heightConstraint = NSLayoutConstraint(item: self.collectionView1!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(105))
        self.collectionView1.addConstraint(heightConstraint)
        contentView.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComposeImageCell", for: indexPath) as! ComposeImageCell
        if self.images.isEmpty {} else {
            cell.configure()
            cell.image.contentMode = .scaleAspectFill
            cell.image.image = images[indexPath.row]
            if self.isVideo {
                cell.videoOverlay.alpha = 1
            } else {
                cell.videoOverlay.alpha = 0
            }
            cell.image.layer.masksToBounds = true
            cell.image.backgroundColor = GlobalStruct.baseDarkTint
            cell.image.layer.cornerRadius = 5
            cell.image.layer.masksToBounds = true
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isVideo {
            let ur = videoURLs[indexPath.row]
            self.player = AVPlayer(url: ur)
            self.playerViewController.player = self.player
            getTopMostViewController()?.present(playerViewController, animated: true) {
                self.playerViewController.player!.play()
            }
        } else {
            let imageInfo = GSImageInfo(image: self.images[indexPath.item], imageMode: .aspectFit, imageHD: nil, imageText: "", imageText2: 0, imageText3: 0, imageText4: "")
            let transitionInfo = GSTransitionInfo(fromView: (collectionView.cellForItem(at: indexPath) as! ComposeImageCell).image)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            getTopMostViewController()?.present(imageViewer, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            let vc = ImagePreviewViewController()
            vc.image = self.images[indexPath.item]
            return vc
        }, actionProvider: { suggestedActions in
            return self.makeContextMenu(indexPath)
        })
    }
    
    var txt = ""
    func makeContextMenu(_ indexPath: IndexPath) -> UIMenu {
        let caption = UIAction(title: "Add Caption".localized, image: UIImage(systemName: "captions.bubble"), identifier: nil) { action in
            if GlobalStruct.mediaIDs.count == self.images.count {
                
                
                let alert = UIAlertController(style: .actionSheet, title: nil)
                let config: TextField1.Config = { textField in
                    textField.becomeFirstResponder()
                    textField.textColor = UIColor(named: "baseBlack")!
                    textField.placeholder = "\("Add Caption".localized)..."
                    textField.layer.borderWidth = 0
                    textField.layer.cornerRadius = 8
                    textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
                    textField.backgroundColor = nil
                    textField.keyboardAppearance = .default
                    textField.keyboardType = .default
                    textField.isSecureTextEntry = false
                    textField.returnKeyType = .default
                    textField.action { textField in
                        self.txt = textField.text ?? ""
                    }
                }
                alert.addOneTextField(configuration: config)
                alert.addAction(title: "Add".localized, style: .default) { action in
                    let request = Media.updateDescription(description: self.txt, id: GlobalStruct.mediaIDs[indexPath.row])
                    GlobalStruct.client.run(request) { (statuses) in
                        DispatchQueue.main.async {
                            
                        }
                    }
                }
                alert.addAction(title: "Dismiss".localized, style: .cancel) { action in
                    
                }
                if let presenter = alert.popoverPresentationController {
                    presenter.sourceView = self.imageView
                    presenter.sourceRect = self.imageView?.bounds ?? self.bounds
                }
                self.getTopMostViewController()?.present(alert, animated: true, completion: nil)
                
                
            } else {
                let alert = UIAlertController(title: "Please wait for all media to finish uploading".localized, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                    
                }))
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = NSTextAlignment.left
                let messageText = NSMutableAttributedString(
                    string: "Please wait for all media to finish uploading".localized,
                    attributes: [
                        NSAttributedString.Key.paragraphStyle: paragraphStyle,
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                    ]
                )
                alert.setValue(messageText, forKey: "attributedTitle")
                if let presenter = alert.popoverPresentationController {
                    presenter.sourceView = self.imageView
                    presenter.sourceRect = self.imageView?.bounds ?? self.bounds
                }
                self.getTopMostViewController()?.present(alert, animated: true, completion: nil)
            }
        }
        let remove = UIAction(title: "Remove".localized, image: UIImage(systemName: "xmark"), identifier: nil) { action in
            if GlobalStruct.mediaIDs.count == self.images.count {
                GlobalStruct.mediaIDs.remove(at: indexPath.row)
            }
            self.images.remove(at: indexPath.row)
            if self.isVideo {
                self.videoURLs.remove(at: indexPath.row)
                GlobalStruct.gifVidDataToAttachArray.remove(at: indexPath.row)
                GlobalStruct.gifVidDataToAttachArrayImage.remove(at: indexPath.row)
            } else {
                GlobalStruct.photoToAttachArray.remove(at: indexPath.row)
                GlobalStruct.photoToAttachArrayImage.remove(at: indexPath.row)
            }
            self.collectionView1.reloadData()
        }
        remove.attributes = .destructive
        return UIMenu(title: "", image: nil, identifier: nil, children: [caption, remove])
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
}
