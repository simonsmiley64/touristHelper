//
//  BTouristMapViewViewViewController.swift
//  TouristHelper
//
//  Created by Simon Smiley-Andrews on 27/09/2017.
//  Copyright © 2017 Simon Smiley-Andrews. All rights reserved.
//

import UIKit

class BTouristMapViewViewViewController: UIViewController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        //Do whatever you want here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Tourist Map"
    }
    
}
