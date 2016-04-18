//
//  ScannerViewController.swift
//  Recyche
//
//  Created by Zel Marko and Gary Greenblatt and Gary Greenblatt on 20/09/15.
//  Copyright © 2015 Recyche. All rights reserved.
//

import UIKit
import AVFoundation
import FBSDKCoreKit
import FBSDKLoginKit
import CloudKit
import CoreLocation
import GoogleMobileAds

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate , CLLocationManagerDelegate {

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var captureDevice: AVCaptureDevice?
    var lastCapturedCode:String?
    var scannedProduct: CKRecord!
    var barcodeScanned:((String) ->())?
    var firstTimeCheck = false
   
    
    
    let locationManager = CLLocationManager()
    var placemark: CLPlacemark!
    
    
    @IBOutlet weak var videoView:UIView!
    @IBOutlet weak var instructionBanner: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet var instructionsView: UIView!
    
    private var allowedTypes = [AVMetadataObjectTypeUPCECode,
        AVMetadataObjectTypeCode39Code,
        AVMetadataObjectTypeCode39Mod43Code,
        AVMetadataObjectTypeEAN13Code,
        AVMetadataObjectTypeEAN8Code,
        AVMetadataObjectTypeCode93Code,
        AVMetadataObjectTypeCode128Code,
        AVMetadataObjectTypePDF417Code,
        AVMetadataObjectTypeAztecCode]
    
    // MARK: - UIViewController functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.tintColor = colorWithHexString("15783D")
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 17)!]
        
        torchButton.layer.shadowOpacity = 1.0
        torchButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        torchButton.layer.shadowRadius = 20.0
        torchButton.layer.shadowColor = UIColor.whiteColor().CGColor
        
        loadingView.hidden = true
        loadingView.frame = view.frame
        UIApplication.sharedApplication().keyWindow?.addSubview(loadingView)
        initializeLocationManager()
       
        
    }
    
  
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if captureSession != nil {
            restartScanner()
        }
        
        setupScanner()
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

//        if (FBSDKAccessToken.currentAccessToken() == nil) {
//            performSegueWithIdentifier("toLoginSegue", sender: self)
//        }
//        else {
//            // Need some error notification
//        }
//        
//        if firstTimeCheck {
            if !didFinishLaunchingOnce() {
                showInstructions(self)
            }
//            firstTimeCheck = false
//        }
    }

    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        videoPreviewLayer?.frame = self.videoView.layer.bounds
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        switch(orientation){
        case UIInterfaceOrientation.LandscapeLeft:
            videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            
        case UIInterfaceOrientation.LandscapeRight:
            videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            
        case UIInterfaceOrientation.Portrait:
            videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
            
        case UIInterfaceOrientation.PortraitUpsideDown:
            videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            
        default:
            print("Unknown orientation state")
        }
    }
    
    // MARK: - Location
    
    func initializeLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        guard let currentLocation = locations.first else
        {
            return
        }
        CLGeocoder().reverseGeocodeLocation(currentLocation) { (placemarks, error) -> Void in
            guard let _placemark = placemarks?.first else
            {
                return
            }
            self.placemark = _placemark
            info_placemark = _placemark
            
            if  let cityInfo = self.placemark.locality{
                var cityInfoCopy: Int
                if cityToFind.contains(cityInfo){
                    cityInfoCopy = 1
                }  else if cityToFind6.contains(cityInfo){
                    cityInfoCopy =  6
                } else {
                    cityInfoCopy =  0
                }
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setInteger(cityInfoCopy, forKey: "cityInfoCopy")
                defaults.setObject(self.placemark.locality, forKey: "userCity")
                print(cityInfoCopy)
            }
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func toProductDetail(sender: AnyObject) {
        lastCapturedCode = "0123456789012"
        databaseCheck(lastCapturedCode!)
    }
    
    @IBAction func toAddProduct(sender: AnyObject) {
        loadingView.hidden = false
        loadingIndicator.startAnimating()
        lastCapturedCode = "\(arc4random_uniform(892357235))"
        databaseCheck(lastCapturedCode!)
    }
    
    @IBAction func torch(sender: AnyObject) {
        if let device = captureDevice {
            if device.hasTorch && device.isTorchModeSupported(.Auto) {
                do {
                    try device.lockForConfiguration()
                    if device.torchMode == .On {
                        torchButton.setImage(UIImage(named: "Greentech Filled"), forState: .Normal)
                        device.torchMode = .Off
                    }
                    else {
                        device.torchMode = .On
                        torchButton.setImage(UIImage(named: "Greentech"), forState: .Normal)
                    }
                    device.unlockForConfiguration()
                }
                catch  {
                    
                }
                
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
    
    @IBAction func dismissInstructions(sender: AnyObject) {
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.instructionsView.transform = CGAffineTransformIdentity
            }) { (complete) -> Void in
                self.instructionsView.removeFromSuperview()
        }
    }
 
    
    // MARK: - Class Functions
    
    func setupScanner() {
        
          if Reachability.isConnectedToNetwork() == true {
            
            
        self.captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error:NSError?
        let input : AnyObject!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        }
        catch let error1 as NSError {
            error = error1
            input = nil
        }
        if (error != nil) {
            // Error
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input as! AVCaptureInput)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = self.allowedTypes
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResize
        videoPreviewLayer?.frame = videoView.layer.bounds
        videoView.layer.insertSublayer(videoPreviewLayer!, below: instructionBanner.layer)
        videoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScannerViewController.restartScanner)))
        
        captureSession?.startRunning()
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 3
        qrCodeFrameView?.autoresizingMask = [UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin]
        
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
            
            
          }   else {

                let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet." , preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default) { _ in
                    // Put here any code that you would like to execute when
                    // the user taps that OK button (may be empty in your case if that's just
                    // an informative alert)
                }
                alert.addAction(action)
                self.presentViewController(alert, animated: true){}
                
            }


    }
    
    func databaseCheck(upc: String) {
        
        let container = CKContainer.defaultContainer()
        let publicData = container.publicCloudDatabase
        
        publicData.fetchRecordWithID(CKRecordID(recordName: upc)) { (record, error) -> Void in
            if error != nil {
                if error!.userInfo["ServerErrorDescription"] as! String == "Record not found" {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("toAddProductSegue", sender: self)
                        self.loadingIndicator.stopAnimating()
                        self.loadingView.hidden = true
                        
                        
                    })
                
                }
                else {
                    // Error
                }
                
            }
            else if record != nil {
                if let rec = record {
                    self.scannedProduct = rec
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("toProductInfoSegue", sender: self)
                        self.loadingIndicator.stopAnimating()
                        self.loadingView.hidden = true
                        
                    })
                }
            }
            else {
                // Wierd Situation
            }
        }
    }
    
    func restartScanner() {
        
          if Reachability.isConnectedToNetwork() == true {
        
        if !captureSession!.running {
            captureSession!.startRunning()
            qrCodeFrameView?.frame = CGRectZero
        }
        else {
            
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet." , preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default) { _ in
                // Put here any code that you would like to execute when
                // the user taps that OK button (may be empty in your case if that's just
                // an informative alert)
            }
            alert.addAction(action)
            self.presentViewController(alert, animated: true){}
            }
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        videoPreviewLayer?.frame = videoView.layer.bounds
    }
    
    func didFinishLaunchingOnce() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let _ = defaults.stringForKey("scannerHasBeenLaunchedBefore") {
            return true
        }
        else {
            defaults.setBool(true, forKey: "scannerHasBeenLaunchedBefore")
            return false
        }
    }
    
    // MARK: - AVCaptureOutput Delegate
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0
        {
            qrCodeFrameView?.frame = CGRectZero
            
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if self.allowedTypes.contains(metadataObj.type) {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.loadingView.hidden = false
                    self.loadingIndicator.startAnimating()
                })
                
                captureSession?.stopRunning()
                
                lastCapturedCode = metadataObj.stringValue
                databaseCheck(metadataObj.stringValue)
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindViewController(segue: UIStoryboardSegue) {
        firstTimeCheck = true
        
    }

    @IBAction func guideBarButtonPressed(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let myVC = storyboard.instantiateViewControllerWithIdentifier("profileId")
        self.presentViewController(myVC, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toAddProductSegue" {
            let addProductViewController = segue.destinationViewController as! AddProductViewController
            addProductViewController.scannedUPC = lastCapturedCode
        }
        else if segue.identifier == "toProductInfoSegue" {
            let productInfoViewController = segue.destinationViewController as! ProductInfoViewController
            productInfoViewController.scannedProduct = scannedProduct
        
        }
    }

}