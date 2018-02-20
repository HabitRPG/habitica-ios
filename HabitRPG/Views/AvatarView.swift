//
//  AvatarView.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import YYWebImage
import SnapKit

@objc
@IBDesignable
class AvatarView: UIView {

    @objc var avatar: Avatar? {
        didSet {
            if let dict = avatar?.getFilenameDictionary() {
                nameDictionary = dict
            }
            updateView()
        }
    }
    
    @IBInspectable @objc var showBackground: Bool = true
    @IBInspectable @objc var showMount: Bool = true
    @IBInspectable @objc var showPet: Bool = true
    @IBInspectable @objc var isFainted: Bool = false
    
    public var onRenderingFinished: (() -> Void)?
    
    private var nameDictionary: [String: String?] = [:]
    
    private let formatDictionary = [
        "head_special_0": "gif",
        "head_special_1": "gif",
        "shield_special_0": "gif",
        "weapon_special_0": "gif",
        "slim_armor_special_0": "gif",
        "slim_armor_special_1": "gif",
        "broad_armor_special_0": "gif",
        "broad_armor_special_1": "gif",
        "weapon_special_critical": "gif",
        "Pet-Wolf-Cerberus": "gif"
    ]
    
    private let viewOrder = [
        "background",
        "mount-body",
        "chair",
        "back",
        "skin",
        "shirt",
        "armor",
        "body",
        "head_0",
        "hair-bangs",
        "hair-base",
        "hair-mustache",
        "hair-beard",
        "eyewear",
        "head",
        "head-accessory",
        "hair-flower",
        "shield",
        "weapon",
        "visual-buff",
        "mount-head",
        "zzz",
        "knockout",
        "pet"
    ]
    
    lazy private var constraintsDictionary = [
        "background": backgroundConstraints,
        "mount-body": mountConstraints,
        "chair": characterConstraints,
        "back": characterConstraints,
        "skin": characterConstraints,
        "shirt": characterConstraints,
        "armor": characterConstraints,
        "body": characterConstraints,
        "head_0": characterConstraints,
        "hair-base": characterConstraints,
        "hair-bangs": characterConstraints,
        "hair-mustache": characterConstraints,
        "hair-beard": characterConstraints,
        "eyewear": characterConstraints,
        "head": characterConstraints,
        "head-accessory": characterConstraints,
        "hair-flower": characterConstraints,
        "shield": characterConstraints,
        "weapon": characterConstraints,
        "visual-buff": characterConstraints,
        "mount-head": mountConstraints,
        "zzz": characterConstraints,
        "knockout": characterConstraints,
        "pet": petConstraints
    ]
    
    let keepRatioConstraints: ((AvatarView, YYAnimatedImageView, UIImage?, CGSize) -> Void) = { superview, view, image, size in
        view.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(view.snp.width).multipliedBy((image?.size.height ?? 1) / (image?.size.width ?? 1))
            make.width.equalTo(superview.snp.width).multipliedBy((image?.size.width ?? 1) / size.width)
        }
    }
    
    let backgroundConstraints: ((AvatarView, YYAnimatedImageView, CGSize) -> Void) = { superview, view, size in
        view.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
    }
    
    let characterConstraints: ((AvatarView, YYAnimatedImageView, CGSize) -> Void) = { superview, view, size in
        view.snp.makeConstraints { (make) -> Void in
            if size.width <= 90 {
                make.leading.equalTo(superview)
            } else {
                make.leading.equalTo(superview.snp.trailing).multipliedBy(25 / size.width)
            }
            make.top.equalTo(superview).offset(0)
        }
    }
    
    let mountConstraints: ((AvatarView, YYAnimatedImageView, CGSize) -> Void) = { superview, view, size in
        view.snp.makeConstraints { (make) -> Void in
            make.leading.equalTo(superview.snp.trailing).multipliedBy(25/size.width)
            make.top.equalTo(superview.snp.bottom).multipliedBy(18/size.width)
        }
    }
    
    let petConstraints: ((AvatarView, YYAnimatedImageView, CGSize) -> Void) = { superview, view, size in
        view.snp.makeConstraints { (make) -> Void in
            make.leading.equalTo(superview)
            make.bottom.equalTo(superview)
        }
    }
    
    let weaponSpecialConstraint: ((AvatarView, YYAnimatedImageView, CGSize) -> Void) = { superview, view, size in
        view.snp.makeConstraints { (make) -> Void in
            if size.width <= 90 {
                make.leading.equalTo(superview.snp.trailing).multipliedBy(-12 / size.width)
            } else {
                make.leading.equalTo(superview).multipliedBy(13.0 / size.width)
            }
            make.top.equalTo(superview).multipliedBy(12.0 / size.height)
        }
    }
    
    let weaponSpecial1Constraint: ((AvatarView, YYAnimatedImageView, CGSize) -> Void) = { superview, view, size in
        view.snp.makeConstraints { (make) -> Void in
            if size.width <= 90 {
                make.leading.equalTo(superview.snp.trailing).multipliedBy(-12 / size.width)
            } else {
                make.leading.equalTo(superview).multipliedBy(13.0 / size.width)
            }
            make.top.equalTo(superview).offset(0+3)
        }
    }
    
    let headSpecialConstraint: ((AvatarView, YYAnimatedImageView, CGSize) -> Void) = { superview, view, size in
        view.snp.makeConstraints { (make) -> Void in
            if size.width <= 90 {
                make.leading.equalTo(superview)
            } else {
                make.leading.equalTo(superview.snp.trailing).multipliedBy(13.0 / size.width)
            }
            make.top.equalTo(superview).multipliedBy(12.0 / size.height)
        }
    }
    
    var imageViews = [YYAnimatedImageView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        viewOrder.forEach({ (_) in
            let imageView = YYAnimatedImageView()
            addSubview(imageView)
            imageViews.append(imageView)
        })
    }
    
    private func updateView() {
        guard let avatar = self.avatar else {
            return
        }
        let viewDictionary = avatar.getViewDictionary(showsBackground: showBackground, showsMount: showMount, showsPet: showPet, isFainted: isFainted)
        
        let boxSize = (showBackground || showPet || showMount) ? CGSize(width: 140, height: 147) : CGSize(width: 90, height: 90)
        
        viewOrder.enumerated().forEach({ (index, type) in
            if viewDictionary[type] ?? false {
                let imageView = imageViews[index]
                imageView.isHidden = false
                setConstraints(imageView, type: type, size: boxSize)
                setImage(imageView, type: type, size: boxSize)
            } else {
                let imageView = imageViews[index]
                imageView.image = nil
                imageView.isHidden = true
            }
        })
        
        setNeedsLayout()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            if let action = self.onRenderingFinished {
                action()
            }
        }
    }
    
    private func setImage(_ imageView: YYAnimatedImageView, type: String, size: CGSize) {
        imageView.yy_setImage(with: getImageUrl(type: type), placeholder: nil, options: .showNetworkActivity, manager: nil, progress: nil, transform: { (image, _) in
            if let data = image.yy_imageDataRepresentation() {
                return YYImage(data: data, scale: 1.0)
            }
            return image
        }) { (image, _, _, _, error) in
            if type != "background" {
                self.keepRatioConstraints(self, imageView, image, size)
            }
            if error != nil {
                print(error?.localizedDescription)
            }
        }
    }
    
    private func setConstraints(_ imageView: YYAnimatedImageView, type: String, size: CGSize) {
        imageView.snp.removeConstraints()
        constraintsDictionary[type]?(self, imageView, size)
    }
    
    private func getFormat(name: String) -> String {
        return formatDictionary[name] ?? "png"
    }
    
    private func getImageUrl(type: String) -> URL? {
        guard let name = nameDictionary[type] else {
            return nil
        }
        return URL(string: "https://habitica-assets.s3.amazonaws.com/mobileApp/images/\(name ?? "").\(getFormat(name: name ?? ""))")
    }
}
