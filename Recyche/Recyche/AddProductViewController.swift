//
//  AddProductViewController.swift
//  Recyche
//
//  Created by Zel Marko and Gary Greenblatt on 20/09/15.
//  Copyright © 2015 Recyche. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CloudKit

class AddProductViewController: UIViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
  
  @IBOutlet weak var productNameLabel: UILabel!
  @IBOutlet weak var productImageView: UIImageView!
  @IBOutlet weak var productPicker: UIPickerView!
  @IBOutlet weak var addProductToDatabaseButton: UIButton!
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
  @IBOutlet var instructionsView: UIView!
  @IBOutlet weak var boxView: UIView!
  
  let naMessage = "The Product information is not in our database. Please 'SELECT PRODUCT MATERIAL' below and add it."
  let naProduct = "Product Name Not Available"
  var scannedUPC: String!
  var material: String!
  var newProduct: CKRecord!
  var name: String?
  var imageURL: String?
  
  // MARK: - UIViewController Stuff
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    addProductToDatabaseButton.enabled = false
    addProductToDatabaseButton.alpha = 0.3
    loadingActivityIndicator.startAnimating()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadingView.frame = view.frame
    UIApplication.sharedApplication().keyWindow?.addSubview(loadingView)
    
    checkUPCCodesApiForMatchingCode()
    
    self.boxView.layer.borderWidth = 2
    self.boxView.layer.borderColor = UIColor(red:0.08, green:0.47, blue:0.24, alpha:1.0).CGColor
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if !didFinishLaunchingOnce() {
      showInstructions(self)
    }
  }
  
  // MARK: - Actions
  
  @IBAction func addProductToDatabase(sender: AnyObject) {
    
    loadingView.hidden = false
    loadingActivityIndicator.startAnimating()
    
    let container = CKContainer.defaultContainer()
    let publicData = container.publicCloudDatabase
    
    let productToVerify = CKRecord(recordType: "Verification", recordID: CKRecordID(recordName: "\(scannedUPC)_\(material)"))
    productToVerify.setValue(NSUserDefaults.standardUserDefaults().valueForKey("id") as! String, forKey: "user1")
    
    let product = CKRecord(recordType: "Product", recordID: CKRecordID(recordName: scannedUPC))
    product.setValue(material, forKey: "material")
    if let nm = name {
      product.setValue(nm, forKey: "name")
    }
    else {
      product.setValue("Unknown", forKey: "name")
    }
    
    if let _ = imageURL {
      let imageData = UIImageJPEGRepresentation(productImageView.image!, 1)
      let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
      let fileURL = documentsURL.URLByAppendingPathComponent("imageasset")
      imageData?.writeToURL(fileURL, atomically: true)
      
      let asset = CKAsset(fileURL: fileURL)
      product.setValue(asset, forKey: "image")
    }
    
    publicData.saveRecord(product) { (record, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.loadingActivityIndicator.stopAnimating()
          self.loadingView.hidden = true
        })
      }
      else {
        self.newProduct = record
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.loadingActivityIndicator.stopAnimating()
          self.loadingView.hidden = true
          self.performSegueWithIdentifier("addToInfoSegue", sender: self)
        })
      }
    }
  }
  
  @IBAction func showInstructions(sender: AnyObject) {
    instructionsView.center = CGPoint(x: view.center.x, y: view.center.y - 64 - view.bounds.height)
    instructionsView.layer.shadowColor = UIColor.blackColor().CGColor
    instructionsView.layer.shadowOffset = CGSize(width: 0, height: 0)
    instructionsView.layer.shadowRadius = 20
    instructionsView.layer.shadowOpacity = 1.0
    view.addSubview(instructionsView)
    
    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: ({
      self.instructionsView.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.height)
    }), completion: nil)
  }
  
  @IBAction func hideInstructions(sender: AnyObject) {
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.instructionsView.transform = CGAffineTransformIdentity
      }) { (complete) -> Void in
        self.instructionsView.removeFromSuperview()
    }
  }
  
  // MARK: - Class Functions
  
  func checkUPCCodesApiForMatchingCode() {
    Alamofire.request(.GET, URLString, parameters: ["access_token" : access_token ,"upc": scannedUPC]).responseJSON { response in
      
      if let data = response.data {
        let json = JSON(data: data)
        if let _name = json["0"]["productname"].string {
          if _name == " " {
            self.productNameLabel.text = self.naProduct
          }
          else {
            self.productNameLabel.text = _name
            self.name = _name
          }
        }
        else {
          self.productNameLabel.text = self.naProduct
        }
        
        if let _imageURL = json["0"]["imageurl"].string {
          if verifyUrl(_imageURL) {
            self.productImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: _imageURL)!)!)
            self.imageURL = _imageURL
          }
        }
        self.loadingActivityIndicator.stopAnimating()
        self.loadingView.hidden = true
      }
    }
  }
  
  func didFinishLaunchingOnce() -> Bool {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    if let _ = defaults.stringForKey("addHasBeenLaunchedBefore") {
      return true
    }
    else {
      defaults.setBool(true, forKey: "addHasBeenLaunchedBefore")
      return false
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resour  ces that can be recreated.
  }
  
  // MARK: - UIPickerView Delegate
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return recycleCodes.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return recycleCodes[row]
  }
  
  func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
    let pickerLabel = UILabel()
    let titleData = recycleCodes[row]
    let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Arial", size: 14.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
    pickerLabel.attributedText = myTitle
    pickerLabel.textAlignment = .Center
    pickerLabel.backgroundColor = colorForCode(titleData)
    
    return pickerLabel
  }
  
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
    material = recycleCodes[row]
    
    if !addProductToDatabaseButton.enabled && row != 0 {
      addProductToDatabaseButton.enabled = true
      addProductToDatabaseButton.alpha = 1
    }
    else if addProductToDatabaseButton.enabled && row == 0 {
      addProductToDatabaseButton.enabled = false
      addProductToDatabaseButton.alpha = 0.3
    }
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    dismissViewControllerAnimated(true, completion: nil)
    
    productImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
  }
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "addToInfoSegue" {
      let productInfoViewController = segue.destinationViewController as! ProductInfoViewController
      productInfoViewController.scannedProduct = newProduct
    }
  }
}

