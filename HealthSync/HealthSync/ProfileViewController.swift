//
//  ProfileViewController.swift
//  HealthSync
//
//  Created by Girish Chaudhari on 12/6/15.
//  Copyright © 2015 SwiftStudio. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var fitbitAvatar: UIImageView!
    
    @IBOutlet weak var nameInfo: UILabel!
    @IBOutlet weak var ageInfo: UILabel!
    @IBOutlet weak var genderInfo: UILabel!
    @IBOutlet weak var weightInfo: UILabel!
    
    var profileAvatarUrl = ""
    let fitbitManager:FitBitManager = FitBitManager()
    
    let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadFitBitProfile()
    }
    
    func loadFitBitProfile(){
        
        let accessToken = FitBitCredentials.sharedInstance.fitBitValueForKey("accessToken")
        if accessToken == nil || accessToken!.characters.count == 0 {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FitbitLoginViewController") as! FitbitLoginViewController
            secondViewController.delegate = self
            secondViewController.methodStatus = "getProfileData"
            self.navigationController?.pushViewController(secondViewController, animated: true)
        } else {
            self.getProfileData()
        }
        
        
        
    }
    
    func getProfileData() {
        
        Util.showSpinner(activitySpinner, forView: self)
        
        guard Util.isConnectedToNetwork() else{
            Util.showAlertView("No Internet Access", message: "Please Connect to Internet to get updated profile info.                   ", view: self)
            Util.stopSpinner(activitySpinner)
            return
        }
        
        fitbitManager.getProfileData({(result)-> Void in
            guard  let fitbitProfile =   result as? FitBitUserProfile else{
                Util.stopSpinner(self.activitySpinner)
                Util.showAlertView("Profile Error", message: "Error in loading profile please try again later. ", view: self)
                return
            }
            
            self.nameInfo.text = fitbitProfile.fullName
            self.ageInfo.text = String(fitbitProfile.age) + "  year"
            self.genderInfo.text = fitbitProfile.gender.lowercaseString
            let weightInPounds  = fitbitProfile.weight * 2.20
            self.weightInfo.text = String(format:"%.2f", weightInPounds) + "  lbs"
            self.profileAvatarUrl = fitbitProfile.avatar_url
            
            Util.stopSpinner(self.activitySpinner)
            
            if let url  = NSURL(string: self.profileAvatarUrl),
                data = NSData(contentsOfURL: url)
            {
                self.fitbitAvatar.image = UIImage(data: data)
            }
        })
    }
    
}
