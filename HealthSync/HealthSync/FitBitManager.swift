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
    let BASE_RESOURCE_URL = "https://api.fitbit.com/1/user/-/"
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
    
    func getProfileData(completion:(result: AnyObject) -> Void) {
       
        refereshRequest({(refreshToken, accessToken) -> Void in
            
            let profileURL = self.BASE_RESOURCE_URL + "profile.json"
            let header = ["Authorization":"Bearer " + accessToken]
            
            Alamofire.request(.GET, profileURL,headers:header).responseJSON{ response in
                
                guard response.result.error == nil else {
                    print(response.result.error!)
                    return
                }
                
                if let value: AnyObject = response.result.value {
                    print(value)
                    completion(result: value)
                }
            }
        })
    }
    
    func refereshRequest(completion: (refreshToken: String, accessToken: String) -> Void) {
        
        let _refreshToken:URLStringConvertible = FitBitCredentials.sharedInstance.fitBitValueForKey("refreshToken")!
        
        let refreshTokenURL = "https://api.fitbit.com/oauth2/token?grant_type=refresh_token&refresh_token=\(_refreshToken)"
        var headers = Dictionary<String, String>()
        headers["Authorization"] = "Basic MjI5UjZWOjFlNDkzOGVlMzA3ZDk4MmI2NWFmYmQyZGYwYTU1ZDBi"
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        
        let parameters = Dictionary<String, AnyObject>()
            
        Alamofire.request(.POST, refreshTokenURL, parameters: parameters, headers:headers).responseJSON{ response in
            
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on /posts/1")
                print(response.result.error!)
                return
            }
            
            if let value: AnyObject = response.result.value {
                let jsonObject = value as! NSDictionary
                print(jsonObject)
                if let newAccessToken = jsonObject["access_token"] {
                    let newRefreshToken = jsonObject["refresh_token"]
                    print(newAccessToken)
                    print(newRefreshToken)
                    FitBitCredentials.sharedInstance.setFitbitValue((newAccessToken as! String), withKey: "accessToken")
                    FitBitCredentials.sharedInstance.setFitbitValue((newRefreshToken as! String), withKey: "refreshToken")
                    completion(refreshToken: (newRefreshToken as! String), accessToken: (newAccessToken as! String))
                }
            }
        }
    }
    
    
    
    
}