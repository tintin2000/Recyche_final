//
//  ProfileViewController.swift
//  Recyche
//
//  Created by Zel Marko and Gary Greenblatt on 17/10/15.
//  Copyright © 2015 Recyche. All rights reserved.
//

import UIKit


class ProfileViewController: UIViewController{
    
     @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height * 3
        scrollView.contentSize = CGSizeMake(contentWidth, contentHeight)
        
    }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
 
  
  }
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
