//
//  ListTableViewController.swift
//  MyPassword
//
//  Created by WuYikai on 15/7/14.
//  Copyright (c) 2015年 secoo. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
  var passwordList: [MyPassword]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.rightBarButtonItem = self.editButtonItem()
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "_handleAddBarButtonItemAction")
    self.tableView.tableFooterView = UIView()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "_handleCoreDataDidSaveAction:", name: kCoreDataDidSaveNotification, object: nil)
    
    self._reloadData()
  }
  
  // MARK: - Actions
  private func _handleAddBarButtonItemAction() {
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    var detailVC = storyBoard.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
    detailVC.showType = .Add
    self.navigationController?.pushViewController(detailVC, animated: true)
  }
  
  private func _handleCoreDataDidSaveAction(note: NSNotification) {
    self._reloadData()
  }
  
  // MARK: - Private methods
  private func _reloadData() {
    self.passwordList = CoreDataManager.defaultManager.passwordList() as? [MyPassword]
    self.tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let pwdList = self.passwordList {
      return pwdList.count
    }
    return 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("listTableViewCell", forIndexPath: indexPath) as! UITableViewCell
    println(self.passwordList)
    let password = self.passwordList![indexPath.row] as MyPassword
    let content = password.p_title
    let data = NSData(base64EncodedString: content, options: NSDataBase64DecodingOptions.allZeros)
    let str = SecurityUtil.decryptAESData(data)
    cell.textLabel?.text = str
    return cell
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    
    return true
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      // Delete the row from the data source
      CoreDataManager.defaultManager.remove(self.passwordList![indexPath.row])
      self.passwordList!.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
  }
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var detailVC: DetailViewController = segue.destinationViewController as! DetailViewController
    detailVC.showType = ShowType.Detail
    if let cell: AnyObject = sender {
      let indexPath = self.tableView.indexPathForCell(cell as! UITableViewCell)
      if let currentIndexPath = indexPath {
        detailVC.password = self.passwordList![currentIndexPath.row]
      }
    }
  }
  
}
