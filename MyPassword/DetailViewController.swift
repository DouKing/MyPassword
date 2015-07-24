//
//  DetailViewController.swift
//  MyPassword
//
//  Created by WuYikai on 15/7/14.
//  Copyright (c) 2015年 secoo. All rights reserved.
//

import UIKit

enum ShowType {
  case Add
  case Detail
}

class DetailViewController: UIViewController {
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var descriptionTextField: UITextField!
  @IBOutlet weak var detailTextField: UITextField!
  @IBOutlet weak var confirmButton: UIButton!
  var password: MyPassword?
  var showType: ShowType?
  
  var titleStr: String {
    let title = password!.p_title
    let data = NSData(base64EncodedString: title, options: NSDataBase64DecodingOptions.allZeros)
    return SecurityUtil.decryptAESData(data)
  }
  var descriptionStr: String {
    let description = password!.p_description;
    let data = NSData(base64EncodedString: description, options: NSDataBase64DecodingOptions.allZeros)
    return SecurityUtil.decryptAESData(data)
  }
  var detailStr: String {
    let detail = password!.p_detail
    let data = NSData(base64EncodedString: detail, options: NSDataBase64DecodingOptions.allZeros)
    return SecurityUtil.decryptAESData(data)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    switch self.showType! {
    case .Add:
      self.navigationItem.rightBarButtonItem = nil
    case .Detail:
      self.view.userInteractionEnabled = false
      self.navigationItem.rightBarButtonItem = self.editButtonItem()
      self.confirmButton.hidden = true
      self.titleTextField.text = self.titleStr
      self.descriptionTextField.text = self.descriptionStr
      self.detailTextField.text = self.detailStr
    }
  }
  
  override func setEditing(editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    if editing {
      self.view.userInteractionEnabled = true
      self.confirmButton.hidden = false
    } else {
      if self._checkTitleValid() {
        self._modifyMyPassword()
        self.view.endEditing(true)
        self.view.userInteractionEnabled = false
        self.confirmButton.hidden = true
      }
    }
  }
  
  // MARK: - Private methods
  
  @IBAction func _handleConfirmButtonAction(sender: UIButton) {
    if self._checkTitleValid() {
      self._modifyMyPassword()
      self.navigationController?.popViewControllerAnimated(true)
    }
  }
  
  func _checkTitleValid() -> Bool {
    var title = titleTextField.text
    title = title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    if title.isEmpty {
      UIAlertView(title: nil, message: "标题不能为空", delegate: nil, cancelButtonTitle: "知道了").show()
      return false
    }
    return true
  }
  
  func _modifyMyPassword() {
    var password: MyPassword?
    let titleData = SecurityUtil.encryptAESData(titleTextField.text)
    let descriptionData = SecurityUtil.encryptAESData(descriptionTextField.text)
    let detailData = SecurityUtil.encryptAESData(detailTextField.text)
    println("titleData: \(titleData)")
    let title = titleData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
    let description = descriptionData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
    let detail = detailData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
    
    switch self.showType! {
    case .Add:
      password = CoreDataManager.defaultManager.creatPassword()
    case .Detail:
      password = self.password
    }
    password?.p_title = title
    password?.p_description = description
    password?.p_detail = detail
  }
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    self.view.endEditing(true)
  }
}
