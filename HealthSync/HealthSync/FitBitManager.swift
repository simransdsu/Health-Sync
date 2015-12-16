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
    let walking_activity_id = "90013" // FitBit walking activity id
    let running_activity_id = "90009" // FitBit running activity id
    var fitbitProfile: FitBitUserProfile?
    let  OK = 200
    func doFitBitOAuth(completion: (result: AnyObject) -> Void){
        
        let authorizeURL = BASE_AUTH_URL+"client_id=" + (FitBitCredentials.sharedInstance.fitBitValueForKey("clientID")!)
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
        completion(result: "doFitBitOAuth")
        
    }
    
    func getAuthInformation(url: NSURL, completion:() -> Void) {
        
        let clientID = FitBitCredentials.sharedInstance.fitBitValueForKey("clientID")
        let code = (url.query!).characters.split{$0 == "="}.map(String.init)
        
        var parameter = Dictionary<String, AnyObject>()
        var headers = Dictionary<String, String>()
        
        headers["Authorization"] = "Basic MjI5UjZWOjFlNDkzOGVlMzA3ZDk4MmI2NWFmYmQyZGYwYTU1ZDBi"
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        
        parameter["grant_type"] = "authorization_code"
        parameter["client_id"] = clientID
        parameter["redirect_uri"] = "healthsync://oauth"
        parameter["code"] = code[1]
        
        let fitbit_token_url =  "https://api.fitbit.com/oauth2/token?";
        
        Alamofire.request(.POST, fitbit_token_url,parameters: parameter, headers:headers).responseJSON{ response in
            guard response.result.error == nil else {
                return
            }
            
            if let value: AnyObject = response.result.value {
                let jsonObject = value as! NSDictionary
                if let accessToken = jsonObject["access_token"] {
                    FitBitCredentials.sharedInstance.setFitbitValue((accessToken as? String)!, withKey: "accessToken")
                    FitBitCredentials.sharedInstance.setFitbitValue(String(jsonObject["expires_in"]!), withKey: "expiresIn")
                    let refreshToken = String(jsonObject["refresh_token"]!)
                    FitBitCredentials.sharedInstance.setFitbitValue(refreshToken, withKey: "refreshToken")
                }
            }
            completion()
        }
        
    }
    
    func getProfileData(completion:(result:AnyObject?)->Void) {
        refereshRequest({(refreshToken, accessToken) -> Void in
            let fitbit_profile_url = self.BASE_RESOURCE_URL+"/profile.json"
            
            let header = ["Authorization":"Bearer " + accessToken]
            
            Alamofire.request(.GET, fitbit_profile_url,headers:header).responseJSON{ response in
                
                let statusCode = response.response?.statusCode
                
                guard statusCode == self.OK else{
                    completion(result:nil)
                    return
                }
                
                if let result: AnyObject = response.result.value {
                    let jsonObject  =  result as! NSDictionary
                    let user = jsonObject["user"]!
                    
                    let age  = user["age"]!?.integerValue
                    let avatar_url = (user["avatar150"]! as! String)
                    let fullName = (user["fullName"]! as! String)
                    let gender = (user["gender"]! as! String)
                    let height = user["height"]!?.doubleValue
                    let weight = user["weight"]!?.doubleValue
                    self.fitbitProfile = FitBitUserProfile(age: age!, avatar_url: avatar_url, fullName: fullName, gender: gender, height: height!, weight: weight!)
                    completion(result:self.fitbitProfile!)
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
                print(response.result.error!)
                return
            }
            
            if let value: AnyObject = response.result.value {
                let jsonObject = value as! NSDictionary
                
                if let errorFound = jsonObject["errors"] {
                    let errorType = errorFound as! NSArray
                    let error = (errorType[0]["errorType"])
                    if error != nil && (error! as! String) == "invalid_grant" {
                        if(isConnectedToNetwork()){
                            let fbManager = FitBitManager()
                            fbManager.doFitBitOAuth({(result) -> Void in
                                
                            })
                        }else{
                            showAlertView("No Internet Access", message: "Please Connect to Internet and try again later.", view: self)
                        }
                    }
                }
                
                if let newAccessToken = jsonObject["access_token"] {
                    let newRefreshToken = jsonObject["refresh_token"]
                    
                    FitBitCredentials.sharedInstance.setFitbitValue((newAccessToken as! String), withKey: "accessToken")
                    FitBitCredentials.sharedInstance.setFitbitValue((newRefreshToken as! String), withKey: "refreshToken")
                    completion(refreshToken: (newRefreshToken as! String), accessToken: (newAccessToken as! String))
                }
            }
        }
    }
    
    func getFitbitSteps(completion:(result:Int?)->Void){
        
        refereshRequest({(refreshToken, accessToken) -> Void in
            let fitbit_activity_steps_url = self.BASE_RESOURCE_URL+"/activities/steps/date/today/1d.json"
            let header = ["Authorization":"Bearer " + accessToken]
            
            Alamofire.request(.GET, fitbit_activity_steps_url,headers:header).responseJSON{ response in
                
                let statusCode = response.response?.statusCode
                
                guard statusCode == self.OK else{
                    completion(result:nil)
                    return
                }
                
                if let result: AnyObject = response.result.value {
                    let jsonObject  =  result as! NSDictionary
                    let activitySteps = jsonObject["activities-steps"]!
                    let activityArray = activitySteps as! NSArray
                    let activity = activityArray[0] as! NSDictionary
                    let steps = activity["value"]?.integerValue
                    completion(result:steps)
                }
                
            }
        })
    }
    
    func syncStepsWithFitbit(steps:Int,syncSource:String, completion:(result:AnyObject?)->Void){
        
        refereshRequest({(refreshToken, accessToken) -> Void in
            let fitbit_activity_url =  self.BASE_RESOURCE_URL+"/activities.json";
            
            let header = ["Authorization":"Bearer " + accessToken]
            
            var parameter = Dictionary<String, AnyObject>()
            
            let durationMillis = self.getApproximateActivityTime(steps)
            let startTime = self.getStartTime()
            let activityDate = self.getActivityDate()
            let calories = self.getCalories(steps)
            
            parameter["activityId"] = self.walking_activity_id
            parameter["startTime"] = startTime
            parameter["durationMillis"] = durationMillis
            parameter["date"] = activityDate
            parameter["distance"] = steps
            parameter["manualCalories"]=calories
            parameter["distanceUnit"] = "Steps"
            
            Alamofire.request(.POST, fitbit_activity_url,parameters: parameter,headers:header).responseJSON{response in
                
                let statusCode = response.response?.statusCode
                guard statusCode == 201 else{
                    completion(result:nil)
                    return
                }
                
                if let _ = response.result.value {
                    completion(result: "success")
                    let logger = SyncLogger.sharedInstance
                    logger.storeSyncLogs(syncSource, steps: steps)
                }
            }})
    }
    
    private func getCalories(steps:Int)->Int{
        return Int(Double(steps) * 0.05) // steps to calories conversion 1 Cal/ 20 steps
    }
    
    private func getApproximateActivityTime(steps:Int)-> Int {
        return Int(steps*500); //  approx 2 steps per sec
    }
    
    private func getStartTime()->String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.stringFromDate(NSDate())
    }
    
    private func getActivityDate()->String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.stringFromDate(NSDate())
    }
}