//
//  FDDPullToRefresh.swift
//  PullToRefreshDemo
//
//  Created by denglibing on 2017/3/13.
//  Copyright © 2017年 Yalantis. All rights reserved.
//

import UIKit
import QuartzCore
import PullToRefresh

public class FDDPullToRefresh: PullToRefresh {
    convenience init(at position: Position) {
        let refreshView = FDDPullToRefreshView()
        let animator = FDDPullToRefreshAnimator(refreshView: refreshView)
        self.init(refreshView: refreshView, animator: animator, height:refreshView.frame.size.height, position: position)
        
        //springDamping的范围为0.0f到1.0f，数值越小「弹簧」的振动效果越明显
        self.springDamping = 1
        //initialSpringVelocity则表示初始的速度，数值越大一开始移动越快
        self.initialSpringVelocity = 0
    }
}


// MARK: 自定义的PullToRefreshView
public class FDDPullToRefreshView: UIView {
    var fddIcon = UIImageView()
    var fddCircle = UIImageView()
    var fddState = UILabel()
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        fddCircle.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        fddCircle.image = UIImage(named: "fdd_logo_refresh_circle", in: Bundle(for: FDDPullToRefreshView.self), compatibleWith: nil)
        self.addSubview(fddCircle)
        
        fddIcon.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        fddIcon.image = UIImage(named: "fdd_logo_refresh", in: Bundle(for: FDDPullToRefreshView.self), compatibleWith: nil)
        self.addSubview(fddIcon)
        
        fddState.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        fddState.text = "继续下拉刷新"
        fddState.font = UIFont.systemFont(ofSize: 13)
        fddState.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1.0)
        self.addSubview(fddState)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        fddIcon.center = CGPoint(x: self.frame.size.width / 2 - 42, y: self.frame.size.height / 2)
        fddCircle.center = fddIcon.center
        fddState.frame = CGRect(x: self.frame.size.width / 2 - 10, y: (self.frame.size.height - 20) / 2.0, width: 100, height: 20)
    }
    
    public func startAnimation() {
        let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber.init(value: M_PI * 2)
        rotationAnimation.duration = 1
        rotationAnimation.isCumulative = false
        rotationAnimation.repeatCount = MAXFLOAT
        fddCircle.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
        fddState.text = "刷新中"
    }
    
    public func stopAnimation() {
        fddCircle.layer.removeAllAnimations()
        
        fddState.text = "继续下拉刷新"
    }
    
}

// MARK: 自定义PullToRefreshView的动画(Animator)
public class FDDPullToRefreshAnimator: NSObject, RefreshViewAnimator {
    private let refreshView: FDDPullToRefreshView
    init(refreshView: FDDPullToRefreshView) {
        self.refreshView = refreshView
    }
    
    // MARK: RefreshViewAnimator protocol
    public func animate(_ state: State) {
        
        switch state {
        case .initial:
            self.refreshView.stopAnimation()
            break
            
        //case .releasing(let progress):
        case .releasing:
            self.refreshView.stopAnimation()
            break
            
        case .loading:
            self.refreshView.startAnimation()
            break
            
        case .finished:
            self.refreshView.stopAnimation()
            break
        }
    }
}







