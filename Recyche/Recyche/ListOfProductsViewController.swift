//
//  ListOfProductsViewController.swift
//  Recyche
//
//  Created by Zel Marko and Gary Greenblatt on 20/09/15.
//  Copyright © 2015 Recyche. All rights reserved.
//

import UIKit
import GoogleMobileAds





class ListOfProductsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!

    @IBOutlet weak var totalProductView: UIView!
    @IBOutlet weak var totalListLabel: UILabel!
  
    @IBOutlet weak var totalPlasticLabel: UILabel!
    @IBOutlet weak var totalMetalLabel: UILabel!
    @IBOutlet weak var totalPaperLabel: UILabel!
    @IBOutlet weak var totalGlassLabel: UILabel!
    @IBOutlet weak var totalCardboardLabel: UILabel!

    @IBOutlet weak var totalCartonLabel: UILabel!
    var products: [Product]!
    var countDict:[String:Int] = [String:Int]()
  

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        


        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countDict["PLASTIC"] = 0
        countDict["CARTON"] = 0
        countDict["GLASS"] = 0
        countDict["PAPER"] = 0
        countDict["CARDBOARD"] = 0
        countDict["METAL"] = 0
        
     
        
        

        // Do any additional setup after loading the view.
        bannerView.adUnitID = "ca-app-pub-7645740474114618/8624276289"
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        
        for product in products
            
        {
            let materialItem = (code: materialForCode(product.material!))
            
                
                countDict[materialItem] = (countDict[materialItem] ?? 0) + 1
            print(countDict[materialItem]!)
    
        }
     
        
    totalListLabel.text = String(products.count)
    totalPlasticLabel.text = String(countDict["PLASTIC"]!)
    totalCartonLabel.text = String(countDict["CARTON"]!)
    totalGlassLabel.text = String(countDict["GLASS"]!)
    totalPaperLabel.text   = String(countDict["PAPER"]!)
    totalCardboardLabel.text = String(countDict["CARDBOARD"]!)
    totalMetalLabel.text = String (countDict["METAL"]!)
     
        

    }
    

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProductCell", forIndexPath: indexPath) as! ProductTableViewCell
        
        let product = products[indexPath.row]
        
        cell.nameLabel.text = product.name
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("d MMM y")
        
        cell.dateLabel.text = dateFormatter.stringFromDate(product.dateadded!)
        
        cell.backgroundColor = colorForCode(product.material!)
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func guideBarButtonPressed(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let myVC = storyboard.instantiateViewControllerWithIdentifier("profileId")
        myVC.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        navigationController?.pushViewController(myVC, animated: true)
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


