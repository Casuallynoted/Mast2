//
//  NotificationsImageCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 22/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import GSImageViewerController
import SDWebImage

class NotificationsImageCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var containerView = UIView()
    var typeOf = UIImageView()
    var profile = UIImageView()
    var profile2 = UIImageView()
    var title = UILabel()
    var username = UILabel()
    var usertag = UILabel()
    var timestamp = UILabel()
    var content = UILabel()
    var collectionView1: UICollectionView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = GlobalStruct.baseTint
        containerView.layer.cornerRadius = 0
        containerView.alpha = 0
        contentView.addSubview(containerView)
        
        typeOf.translatesAutoresizingMaskIntoConstraints = false
        typeOf.backgroundColor = UIColor.clear
        typeOf.contentMode = .scaleAspectFit
        contentView.addSubview(typeOf)
        
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.layer.cornerRadius = 20
        profile.backgroundColor = UIColor(named: "baseWhite")
        profile.isUserInteractionEnabled = true
        contentView.addSubview(profile)
        
        profile2.translatesAutoresizingMaskIntoConstraints = false
        profile2.layer.cornerRadius = 14
        profile2.backgroundColor = UIColor(named: "baseWhite")
        profile2.isUserInteractionEnabled = true
        profile2.layer.borderWidth = 1.6
        contentView.addSubview(profile2)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = UIColor(named: "baseBlack")
        title.textAlignment = .natural
        title.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
        title.isUserInteractionEnabled = false
        title.adjustsFontForContentSizeCategory = true
        title.numberOfLines = 0
        title.lineBreakMode = .byTruncatingTail
        contentView.addSubview(title)
        
        username.translatesAutoresizingMaskIntoConstraints = false
        username.textColor = UIColor(named: "baseBlack")
        username.textAlignment = .natural
        username.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        username.isUserInteractionEnabled = false
        username.adjustsFontForContentSizeCategory = true
        username.numberOfLines = 1
        username.lineBreakMode = .byTruncatingTail
        contentView.addSubview(username)
        
        usertag.translatesAutoresizingMaskIntoConstraints = false
        usertag.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
        usertag.textAlignment = .natural
        usertag.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        usertag.isUserInteractionEnabled = false
        usertag.adjustsFontForContentSizeCategory = true
        usertag.numberOfLines = 1
        usertag.lineBreakMode = .byTruncatingTail
        contentView.addSubview(usertag)
        
        timestamp.translatesAutoresizingMaskIntoConstraints = false
        timestamp.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
        timestamp.textAlignment = .natural
        timestamp.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize)
        timestamp.isUserInteractionEnabled = false
        timestamp.adjustsFontForContentSizeCategory = true
        timestamp.numberOfLines = 1
        timestamp.lineBreakMode = .byTruncatingTail
        contentView.addSubview(timestamp)
        
        content.translatesAutoresizingMaskIntoConstraints = false
        content.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.85)
        content.textAlignment = .natural
        content.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        content.isUserInteractionEnabled = false
        content.adjustsFontForContentSizeCategory = true
        content.numberOfLines = 0
        contentView.addSubview(content)
        
        username.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        usertag.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timestamp.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        let layout = ColumnFlowLayout(
            cellsPerRow: 4,
            minimumInteritemSpacing: 15,
            minimumLineSpacing: 15,
            sectionInset: UIEdgeInsets(top: 0, left: 98, bottom: 0, right: 20)
        )
        layout.scrollDirection = .horizontal
        collectionView1 = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(-10), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(178)), collectionViewLayout: layout)
        collectionView1.translatesAutoresizingMaskIntoConstraints = false
        collectionView1.backgroundColor = UIColor.clear
        collectionView1.delegate = self
        collectionView1.dataSource = self
        collectionView1.showsHorizontalScrollIndicator = false
        collectionView1.register(CollectionImageCell.self, forCellWithReuseIdentifier: "CollectionImageCell")
        contentView.addSubview(collectionView1)
        
        let viewsDict = [
            "containerView" : containerView,
            "typeOf" : typeOf,
            "profile" : profile,
            "profile2" : profile2,
            "title" : title,
            "username" : username,
            "usertag" : usertag,
            "timestamp" : timestamp,
            "content" : content,
            "collectionView" : collectionView1,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[typeOf(20)]-10-[profile(40)]-10-[username]-5-[usertag]-(>=5)-[timestamp]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-66-[profile2(28)]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-98-[content]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-98-[title]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[typeOf(20)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[profile(40)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-33-[profile2(28)]-(>=5)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[title]-4-[username]-2-[content]-5-[collectionView(140)]-12-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[title]-4-[usertag]-2-[content]-5-[collectionView(140)]-12-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[title]-4-[timestamp]-2-[content]-5-[collectionView(140)]-12-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ noti: Notificationt) {
        self.images = noti.status?.mediaAttachments ?? []
        self.collectionView1.reloadData()
        
        containerView.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.09)
        self.timestamp.text = timeAgoSince(noti.createdAt)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        if noti.type == .mention {
            self.typeOf.image = UIImage(systemName: "arrowshape.turn.up.left.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemBlue, renderingMode: .alwaysOriginal)
        } else if noti.type == .favourite {
            self.typeOf.image = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemPink, renderingMode: .alwaysOriginal)
        } else if noti.type == .reblog {
            self.typeOf.image = UIImage(systemName: "arrow.2.circlepath", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemGreen, renderingMode: .alwaysOriginal)
        } else if noti.type == .direct {
            self.typeOf.image = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.black, renderingMode: .alwaysOriginal)
        } else if noti.type == .poll {
            self.typeOf.image = UIImage(systemName: "chart.bar.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemTeal, renderingMode: .alwaysOriginal)
        } else if noti.type == .follow {
            self.typeOf.image = UIImage(systemName: "person.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemPurple, renderingMode: .alwaysOriginal)
        }
        if noti.type == .follow {
            self.title.text = "New follower".localized
            self.username.text = noti.account.displayName
            self.usertag.text = "@\(noti.account.username)"
            self.content.text = "\(noti.account.followersCount) \("followers".localized), \(noti.account.followingCount) \("following".localized)"
            self.profile.image = UIImage()
            guard let imageURL = URL(string: noti.account.avatar) else { return }
            self.profile.sd_setImage(with: imageURL, completed: nil)
            self.profile.layer.masksToBounds = true
            self.profile2.alpha = 0
        } else {
            if noti.type == .mention {
                self.title.text = "\(noti.account.displayName) \("mentioned you".localized)"
            } else if noti.type == .favourite {
                self.title.text = "\(noti.account.displayName) \("liked your toot".localized)"
            } else if noti.type == .reblog {
                self.title.text = "\(noti.account.displayName) \("boosted your toot".localized)"
            } else if noti.type == .direct {
                self.title.text = "\(noti.account.displayName) \("direct messaged you".localized)"
            } else if noti.type == .poll {
                self.title.text = "\(noti.account.displayName) \("voted on your poll".localized)"
            }
            self.username.text = noti.status?.account.displayName ?? ""
            self.usertag.text = "@\(noti.status?.account.username ?? "")"
            self.content.text = noti.status?.content.stripHTML() ?? ""
            self.profile.image = UIImage()
            guard let imageURL = URL(string: noti.status?.account.avatar ?? "") else { return }
            self.profile.sd_setImage(with: imageURL, completed: nil)
            self.profile.layer.masksToBounds = true
            if noti.type == .mention {
                self.profile2.alpha = 0
            } else {
                self.profile2.image = UIImage()
                guard let imageURL2 = URL(string: noti.account.avatar) else { return }
                self.profile2.sd_setImage(with: imageURL2, completed: nil)
                self.profile2.layer.masksToBounds = true
                self.profile2.alpha = 1
                self.profile2.layer.borderColor = UIColor(named: "baseWhite")!.cgColor
            }
        }
        
        let _ = self.images.map {_ in
            self.images2.append(UIImageView())
        }
    }
    
    var images: [Attachment] = []
    var images2: [UIImageView] = []
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionImageCell", for: indexPath) as! CollectionImageCell
        if self.images.isEmpty {} else {
            cell.configure()
            let z = self.images[indexPath.item].previewURL
            cell.image.contentMode = .scaleAspectFill
            if let imageURL = URL(string: z) {
                cell.image.sd_setImage(with: imageURL, completed: nil)
                cell.image.layer.masksToBounds = true
                self.images2[indexPath.row].sd_setImage(with: imageURL, completed: nil)
                cell.image.backgroundColor = UIColor(named: "baseWhite")
                cell.image.layer.cornerRadius = 5
                cell.image.layer.masksToBounds = true
                cell.image.layer.borderColor = UIColor.black.cgColor
                cell.image.frame.size.width = 160
                cell.image.frame.size.height = 120
                cell.bgImage.layer.masksToBounds = false
            }
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageInfo = GSImageInfo(image: self.images2[indexPath.item].image ?? UIImage(), imageMode: .aspectFit, imageHD: nil)
        let transitionInfo = GSTransitionInfo(fromView: (collectionView.cellForItem(at: indexPath) as! CollectionImageCell).image)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        let win = UIApplication.shared.keyWindow?.rootViewController
        win?.present(imageViewer, animated: true, completion: nil)
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
}

