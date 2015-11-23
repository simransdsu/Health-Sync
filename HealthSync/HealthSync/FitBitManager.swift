//
//  FitBitManager.swift
//  HealthSync
//
//  Created by Girish Chaudhari on 11/22/15.
//  Copyright © 2015 SwiftStudio. All rights reserved.
//

import Foundation
import Alamofire
import OAuthSwift

class FitBitManager {
    
    let BASE_AUTH_URL = "https://www.fitbit.com/oauth2/authorize?"
    let BASE_RESOURCE_URL = "https://api.fitbit.com/1/user/-"
    let scopes  = "activity profile weight"
    
    func doFitBitOAuth(){
        
        let authorizeURL = BASE_AUTH_URL+"client_id=" + FitBitCredentials.sharedInstance.fitBitValueForKey("clientID")!
        let scope = scopes.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        
        let oauthswift = OAuth2Swift(
            consumerKey:    FitBitCredentials.sharedInstance.fitBitValueForKey("consumerKey")!,
            consumerSecret: FitBitCredentials.sharedInstance.fitBitValueForKey("consumerSecret")!,
            authorizeUrl:   authorizeURL,
            responseType:   "code"
        )
        
        oauthswift.authorizeWithCallbackURL( NSURL(string: "healthsync://oauth")!, scope: scope!, state:"", success: {
            (credential, response, parameters) -> Void in
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })
    }
    
    func getProfileData(){
        
        let profileURL = BASE_RESOURCE_URL+"/profile.json"
        
        let header = ["Authorization":"Bearer " + FitBitCredentials.sharedInstance.fitBitValueForKey("accessToken")!]
        
        Alamofire.request(.GET, profileURL,headers:header).responseJSON{ response in
            guard response.result.error == nil else {
                print(response.result.error!)
                return
            }
            
            if let value: AnyObject = response.result.value {
                print(value)
            }
        }
        
    }
    
    
    
    
}