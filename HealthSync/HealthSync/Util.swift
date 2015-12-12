//
//  Util.swift
//  Potholes
//
//  Created by Girish Chaudhari on 11/11/15.
//  Copyright © 2015 Girish Chaudhari. All rights reserved.
//  Red ID : 817375241
//

import Foundation
import UIKit
import SystemConfiguration

// Helper class containes helper functions such as showSpinner/stopSpinner/Connectivity check.


func  showAlertView(title:String, message:String,view:AnyObject){
    let alert = UIAlertController(title: title, message:message, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
    view.presentViewController(alert, animated: true, completion: nil)
}

func isConnectedToNetwork() -> Bool {
    Reach().monitorReachabilityChanges()
    let status = Reach().connectionStatus()
    switch status {
    case .Unknown, .Offline:
        return false
    case .Online(.WWAN):
        return true
    case .Online(.WiFi):
        return true
    }
}

func showSpinner(activitySpinner:UIActivityIndicatorView , forView:UIViewController){
    
    activitySpinner.center = forView.view.center
    activitySpinner.hidesWhenStopped = true
    activitySpinner.color = UIColor.blackColor()
    activitySpinner.center = forView.view.center
    activitySpinner.startAnimating()
    
    forView.view.addSubview(activitySpinner)
}

func getSyncDate()->String{
    
    let syncTime = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
    
    return syncTime
}

func stopSpinner(activitySpinner:UIActivityIndicatorView){
    activitySpinner.stopAnimating()
}

