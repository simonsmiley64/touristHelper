//
//  BTabBarController.swift
//  TouristHelper
//
//  Created by Simon Smiley-Andrews on 27/09/2017.
//  Copyright © 2017 Simon Smiley-Andrews. All rights reserved.
//

import UIKit

class BTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        let touristMapVC = BTouristMapViewViewViewController()
        
        // Additional tabs to increase functionality
//        let touristListVC = BTouristListViewController()
//        let settingsVC = BSettingsViewController()
        
//        self.viewControllers = [touristMapVC, touristListVC, settingsVC];
        self.viewControllers = [touristMapVC];
        
        self.title = "Tourist Helper"
    }
}
