//
//  BTouristListViewController.swift
//  TouristHelper
//
//  Created by Simon Smiley-Andrews on 27/09/2017.
//  Copyright © 2017 Simon Smiley-Andrews. All rights reserved.
//

import UIKit

class BTouristListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
     
        self.title = "Tourist List"
        self.tabBarItem.image = UIImage(named: "icn_30_mapList.png")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "bCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bCell")
        
        cell?.textLabel?.text = "Hello World"
        
        return cell!
    }
}
