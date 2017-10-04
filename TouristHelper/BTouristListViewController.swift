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

        let nib = UINib(nibName: "BLocationCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "bCellIdentifier")
        
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BLocationCell")
//        tableView.register(UINib.init(), forCellReuseIdentifier: "BLocationCell")
        
//        tableView.register(BLocationCell.classForCoder(), forCellReuseIdentifier: "BLocationCell")
//        tableView.register(BLocationCell.self, forCellReuseIdentifier: "BLocationCell")
        
        //tableView.register(UINib.init(nibName: "BLocationCell", bundle: nil), forCellReuseIdentifier: "BLocationCell")
        //tableView.registerNib(UINib(nibName: "CustomOneCell", bundle: nil), forCellReuseIdentifier: "CustomCellOne")

        //self.tableView.register(BLocationCell.self, forCellReuseIdentifier: "Cell")
        
        //tableView.register(CustomTableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        //tableView.registerClass(BLocationCell.self, forCellReuseIdentifier: NSStringFromClass(BLocationCell))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BLocationCell

//        let cell = Bundle.main.loadNibNamed("BLocationCell", owner: self, options: nil)?.first as! BLocationCell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bCellIdentifier", for: indexPath) as! BLocationCell
        
        return cell
        

        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "bCell")
//
//        cell?.textLabel?.text = "Hello World"
//
//        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
