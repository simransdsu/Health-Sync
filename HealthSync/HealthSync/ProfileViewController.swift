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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFitBitProfile()
    }
    
    func loadFitBitProfile(){
        
        fitbitManager.getProfileData({(result)-> Void in
            guard  let fitbitProfile =   result as? FitBitUserProfile else{
                print("Error in loading user FitBit profile.")
                return
            }
            
            self.nameInfo.text = fitbitProfile.fullName
            self.ageInfo.text = String(fitbitProfile.age)
            self.genderInfo.text = fitbitProfile.gender
            self.weightInfo.text = String(format:"%f", fitbitProfile.weight)
            self.profileAvatarUrl = fitbitProfile.avatar_url
            print(self.profileAvatarUrl)
            
            if let url  = NSURL(string: self.profileAvatarUrl),
                data = NSData(contentsOfURL: url)
            {
                self.fitbitAvatar.image = UIImage(data: data)
            }
        })
        
    }
    
}
