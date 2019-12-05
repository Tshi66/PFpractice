//
//  ViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/11/17.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit
import paper_onboarding

class OnboardingViewController: UIViewController {

    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skipButton.isHidden = true

        setupPaperOnboardingView()
        view.bringSubviewToFront(skipButton)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    

    private func setupPaperOnboardingView() {
        let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)

        // Add constraints
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {

      return [
        OnboardingItemInfo(informationImage: UIImage(named: "onboardImg1")!,
                           title: "1. 決める",
                           description: "どんな人にプレゼントを贈りますか？",
                           pageIcon: UIImage(named: "onboardImg1")!,
                           color: UIColor.white,
                           titleColor: UIColor.black,
                           descriptionColor: UIColor.systemGray,
                           titleFont: UIFont.systemFont(ofSize: 40.0),
                           descriptionFont: UIFont.systemFont(ofSize: 20.0)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "onboardImg2")!,
                           title: "2. つくる",
                           description: "決めたら、その人専用のポストを作る。\nいろいろ管理しましょう。",
                           pageIcon: UIImage(named: "onboardImg2")!,
                           color: UIColor.white,
                           titleColor: UIColor.black,
                           descriptionColor: UIColor.systemGray,
                           titleFont: UIFont.systemFont(ofSize: 40.0),
                           descriptionFont: UIFont.systemFont(ofSize: 20.0)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "onboardImg3")!,
                           title: "3. 貯める",
                           description: "その人のためにお金を貯めてみる。\n貯金のための機能があります。",
                           pageIcon: UIImage(named: "onboardImg3")!,
                           color: UIColor.white,
                           titleColor: UIColor.black,
                           descriptionColor: UIColor.systemGray,
                           titleFont: UIFont.systemFont(ofSize: 40.0),
                           descriptionFont: UIFont.systemFont(ofSize: 20.0)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "onboardImg4")!,
                           title: "4. 贈る",
                           description: "自分の気持ちを大事な人に贈ってみる。\nきっと、喜んでくれる。",
                           pageIcon: UIImage(named: "onboardImg4")!,
                           color: UIColor.white,
                           titleColor: UIColor.black,
                           descriptionColor: UIColor.systemGray,
                           titleFont: UIFont.systemFont(ofSize: 40.0),
                           descriptionFont: UIFont.systemFont(ofSize: 20.0)),
        
        ][index]
    }
    
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
         print(#function)
        
//        performSegue(withIdentifier: "Home", sender: nil)
        
        //storyboardのインスタンスを取得。
        let storyboard: UIStoryboard = self.storyboard!
        
        //変遷先ViewControllerのインスタンを取得。
        let tabVC = storyboard.instantiateViewController(withIdentifier: "TabBar") as! TabBarController
        
        self.navigationController?.pushViewController(tabVC, animated: true)
        
    }
    
}

extension OnboardingViewController: PaperOnboardingDelegate {

    func onboardingWillTransitonToIndex(_ index: Int) {
        skipButton.isHidden = index != 0 ? false : true
    }
}


extension OnboardingViewController: PaperOnboardingDataSource {
    
    
    func onboardingItemsCount() -> Int {
        return 4
    }
    
    func onboardinPageItemRadius() -> CGFloat {
        return 5
    }
    
    func onboardingPageItemSelectedRadius() -> CGFloat {
        return 20
    }
    func onboardingPageItemColor(at index: Int) -> UIColor {
        return [UIColor.systemRed, UIColor.systemRed, UIColor.systemRed,UIColor.systemRed][index]
    }
}
