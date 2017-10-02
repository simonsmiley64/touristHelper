//
//  BSettingsViewController.swift
//  TouristHelper
//
//  Created by Simon Smiley-Andrews on 27/09/2017.
//  Copyright © 2017 Simon Smiley-Andrews. All rights reserved.
//

import UIKit

class BSettingsViewController: UIViewController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Settings"
        self.tabBarItem.image = UIImage(named: "icn_30_settings.png")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
