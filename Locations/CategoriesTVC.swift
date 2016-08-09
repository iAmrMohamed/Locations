//
//  CategoriesTableViewController.swift
//  Locations
//
//  Created by Amr Mohamed on 7/17/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import UIKit

protocol CategoriesTableViewControllerDelegate : class {
    func didSelectCategoryWithName(name:String)
}

class CategoriesTableViewController: UITableViewController {
    
    let tableData = ["No Category","Apple Store","Bookstore","Club","Grocery Store","Historic Building","House","Icecream Vendor","Landmark","Park", "Friends", ""]
    
//    var selectedCategoryName = ""
    var selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    weak var delegate : CategoriesTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.tableData[indexPath.row]
        
        if indexPath.compare(self.selectedIndexPath) == .OrderedSame {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
        self.delegate?.didSelectCategoryWithName(self.tableData[indexPath.row])
        self.tableView.reloadData()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
