//
//  ScheduleImageCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import AVKit
import AVFoundation
import ActiveLabel

class ScheduleImageCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var containerView = UIView()
    var profile = UIImageView()
    var username = UILabel()
    var content = ActiveLabel()
    var collectionView1: UICollectionView!
    let playerViewController = AVPlayerViewController()
    var player = AVPlayer()
    var countOverlay = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = GlobalStruct.baseTint
        containerView.layer.cornerRadius = 0
        containerView.alpha = 0
        contentView.addSubview(containerView)
        
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.layer.cornerRadius = 20
        profile.backgroundColor = GlobalStruct.baseDarkTint
        profile.isUserInteractionEnabled = true
        contentView.addSubview(profile)
        
        username.translatesAutoresizingMaskIntoConstraints = false
        username.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
        username.textAlignment = .natural
        username.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        username.isUserInteractionEnabled = false
        username.adjustsFontForContentSizeCategory = true
        username.numberOfLines = 1
        username.lineBreakMode = .byTruncatingTail
        contentView.addSubview(username)
        
        content.translatesAutoresizingMaskIntoConstraints = false
        content.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.85)
        content.textAlignment = .natural
        content.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        content.isUserInteractionEnabled = true
        content.adjustsFontForContentSizeCategory = true
        content.numberOfLines = 0
        content.enabledTypes = [.mention, .hashtag, .url]
        content.mentionColor = GlobalStruct.baseTint
        content.hashtagColor = GlobalStruct.baseTint
        content.URLColor = GlobalStruct.baseTint
        contentView.addSubview(content)
        
        let layout = ColumnFlowLayout(
            cellsPerRow: 4,
            minimumInteritemSpacing: 0,
            minimumLineSpacing: 0,
            sectionInset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        )
        layout.scrollDirection = .horizontal
        if UIDevice.current.userInterfaceIdiom == .pad {
            collectionView1 = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(360), height: CGFloat(260)), collectionViewLayout: layout)
        } else {
            collectionView1 = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(260)), collectionViewLayout: layout)
        }
        collectionView1.translatesAutoresizingMaskIntoConstraints = false
        collectionView1.backgroundColor = UIColor.clear
        collectionView1.delegate = self
        collectionView1.dataSource = self
        collectionView1.showsHorizontalScrollIndicator = false
        collectionView1.isPagingEnabled = true
        collectionView1.register(CollectionImageCell.self, forCellWithReuseIdentifier: "CollectionImageCell")
        contentView.addSubview(collectionView1)
        
        self.countOverlay.frame = CGRect(x: 10, y: 10, width: 26, height: 26)
        self.countOverlay.backgroundColor = GlobalStruct.baseTint
        self.countOverlay.setTitle("0", for: .normal)
        self.countOverlay.setTitleColor(UIColor.white, for: .normal)
        self.countOverlay.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.countOverlay.layer.cornerRadius = 5
        self.countOverlay.isUserInteractionEnabled = false
        self.countOverlay.alpha = 0
        collectionView1.addSubview(self.countOverlay)
        
        let viewsDict = [
            "containerView" : containerView,
            "profile" : profile,
            "username" : username,
            "content" : content,
            "collectionView" : collectionView1,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[profile(40)]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[username]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[content]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[profile(40)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[username]-2-[content]-5-[collectionView(260)]-0-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentStat: ScheduledStatus!
    func configure(_ stat: ScheduledStatus) {
        self.currentStat = stat
        self.images = stat.mediaAttachments
        self.collectionView1.reloadData()
        
        containerView.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.09)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let updatedAt = dateFormatter.date(from: stat.scheduledAt)
        self.username.text = updatedAt?.toString(dateStyle: .medium, timeStyle: .medium) ?? ""
        self.content.text = stat.params.text.stripHTML()
        self.profile.image = UIImage()
        guard let imageURL = URL(string: GlobalStruct.currentUser.avatar) else { return }
        self.profile.sd_setImage(with: imageURL, completed: nil)
        self.profile.layer.masksToBounds = true
        
        let _ = self.images.map {_ in
            self.images2.append(UIImageView())
            self.images3.append("")
        }
    }
    
    var images: [Attachment] = []
    var images2: [UIImageView] = []
    var images3: [String] = []
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionImageCell", for: indexPath) as! CollectionImageCell
        if self.images.isEmpty {} else {
            
            let z2 = self.images[indexPath.item].remoteURL ?? self.images[indexPath.item].url
            self.images3[indexPath.row] = z2
            
            cell.configure()
            let z = self.images[indexPath.item].previewURL
            cell.image.contentMode = .scaleAspectFill
            if let imageURL = URL(string: z) {
                cell.image.sd_setImage(with: imageURL, completed: nil)
                if self.images[indexPath.row].type == .video || self.images[indexPath.row].type == .audio {
                    cell.videoOverlay.alpha = 1
                } else {
                    cell.videoOverlay.alpha = 0
                }
                cell.image.layer.masksToBounds = true
                self.images2[indexPath.row].sd_setImage(with: imageURL, completed: nil)
                cell.image.backgroundColor = GlobalStruct.baseDarkTint
                cell.image.layer.cornerRadius = 0
                cell.image.layer.masksToBounds = true
                cell.image.layer.borderColor = UIColor.black.cgColor
//                cell.image.frame.size.width = UIScreen.main.bounds.width
                cell.image.frame.size.height = 260
                cell.bgImage.layer.masksToBounds = false
                
                if self.images.count > 1 {
                    self.countOverlay.alpha = 1
                    self.countOverlay.setTitle("\(self.images.count)", for: .normal)
                } else {
                    self.countOverlay.alpha = 0
                }
            }
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.images3[indexPath.row] == "" {} else {
        if images[indexPath.row].type == .video || images[indexPath.row].type == .audio {
            if let ur = URL(string: images[indexPath.row].url) {
                self.player = AVPlayer(url: ur)
                self.playerViewController.player = self.player
                getTopMostViewController()?.present(playerViewController, animated: true) {
                    self.playerViewController.player!.play()
                }
            }
        } else {
            let imageInfo = GSImageInfo(image: self.images2[indexPath.item].image ?? UIImage(), imageMode: .aspectFit, imageHD: URL(string: self.images3[indexPath.item]), imageText: "@\(GlobalStruct.currentUser.username): \(self.currentStat.params.text.stripHTML())", imageText2: 0, imageText3: 0, imageText4: self.currentStat.id)
            let transitionInfo = GSTransitionInfo(fromView: (collectionView.cellForItem(at: indexPath) as! CollectionImageCell).image)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            getTopMostViewController()?.present(imageViewer, animated: true, completion: nil)
        }
        }
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
    
    func highlightCell() {
        springWithDelay(duration: 0.3, delay: 0, animations: {
            self.containerView.alpha = 1
        })
    }
    
    func unhighlightCell() {
        springWithDelay(duration: 0.3, delay: 0, animations: {
            self.containerView.alpha = 0
        })
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            let vc = ImagePreviewViewController()
            vc.image = self.images2[indexPath.item].image ?? UIImage()
            return vc
        }, actionProvider: { suggestedActions in
            return self.makeContextMenu(indexPath)
        })
    }
    
    func makeContextMenu(_ indexPath: IndexPath) -> UIMenu {
        let share = UIAction(title: "Share".localized, image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { action in
            let imToShare = [self.images2[indexPath.item].image ?? UIImage()]
            let activityViewController = UIActivityViewController(activityItems: imToShare,  applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.contentView
            activityViewController.popoverPresentationController?.sourceRect = self.contentView.bounds
            self.getTopMostViewController()?.present(activityViewController, animated: true, completion: nil)
        }
        let save = UIAction(title: "Save".localized, image: UIImage(systemName: "square.and.arrow.down"), identifier: nil) { action in
            UIImageWriteToSavedPhotosAlbum(self.images2[indexPath.item].image ?? UIImage(), nil, nil, nil)
        }
        return UIMenu(title: self.images[indexPath.item].description ?? "", image: nil, identifier: nil, children: [share, save])
    }
}

