//
//  ProfileViewController.swift
//  Recyche
//
//  Created by Zel Marko and Gary Greenblatt on 17/10/15.
//  Copyright © 2015 Recyche. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate {
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    let logoutButton = FBSDKLoginButton()
    logoutButton.center = CGPoint(x: view.center.x, y: view.subviews[0].subviews[0].bounds.height + 20)
    logoutButton.delegate = self
    view.addSubview(logoutButton)
  }
  
  func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
  }
  
  func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    navigationController?.popToRootViewControllerAnimated(true)
    NSUserDefaults.standardUserDefaults().removeObjectForKey("id")
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
