//
//  ListOfProductsViewController.swift
//  Recyche
//
//  Created by Zel Marko and Gary Greenblatt on 20/09/15.
//  Copyright © 2015 Recyche. All rights reserved.
//

import UIKit

class ListOfProductsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var totalProducts: UIView!
    var products: [Product]!
    var someDict = [Int: String]()
    
 
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theHeight = view.frame.size.height

        // Do any additional setup after loading the view.
        totalProducts.frame = CGRect(x: 0, y: theHeight - 50 , width: self.view.frame.width, height: 50 )
        
        for product in products
            
        {
            let materialItem = (code: materialForCode(product.material!))
            print("this" ,materialItem)
        }
        
        
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
