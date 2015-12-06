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
    
    func doFitBitOAuth(){
        
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
    }
    
    func getProfileData(completion:(result:AnyObject)->Void){
        
        let fitbit_profile_url = BASE_RESOURCE_URL+"/profile.json"
        
        let header = ["Authorization":"Bearer " + (FitBitCredentials.sharedInstance.fitBitValueForKey("accessToken")! )]
        
        Alamofire.request(.GET, fitbit_profile_url,headers:header).responseJSON{ response in
            guard response.result.error == nil else {
                print(response.result.error!)
                return
            }
            
            if let result: AnyObject = response.result.value {
                let jsonObject  =  result as! NSDictionary
                let user = jsonObject["user"]!
                
                let age  = user["age"]!?.integerValue
                let avatar_url = (user["avatar"]! as! String)
                let fullName = (user["fullName"]! as! String)
                let gender = (user["gender"]! as! String)
                let height = user["height"]!?.doubleValue
                let weight = user["weight"]!?.doubleValue
                let fitbitProfile = FitBitUserProfile(age: age!, avatar_url: avatar_url, fullName: fullName, gender: gender, height: height!, weight: weight!)
                completion(result:fitbitProfile)
            }
        }
    }
    
    
    func getFitbitSteps(){
        
        let fitbit_activity_steps_url = BASE_RESOURCE_URL+"/activities/steps/date/today/1d.json"
        
        let header = ["Authorization":"Bearer " + (FitBitCredentials.sharedInstance.fitBitValueForKey("accessToken")! )]
        
        Alamofire.request(.GET, fitbit_activity_steps_url,headers:header).responseJSON{ response in
            guard response.result.error == nil else {
                print(response.result.error!)
                return
            }
            if let result: AnyObject = response.result.value {
                let jsonObject  =  result as! NSDictionary
                let activitySteps = jsonObject["activities-steps"]!
                let activityArray = activitySteps as! NSArray
                let activity = activityArray[0] as! NSDictionary
                let steps = (activity["value"]! as! String)
                FitBitCredentials.sharedInstance.setFitbitValue(steps, withKey: "fitbit_steps")
            }
        }
    }
    
    func syncStepsWithFitbit(steps:Int){
        
        let fitbit_activity_url =  BASE_RESOURCE_URL+"/activities.json";
        
        let header = ["Authorization":"Bearer " + (FitBitCredentials.sharedInstance.fitBitValueForKey("accessToken")! )]
        
        var parameter = Dictionary<String, AnyObject>()
        
        let durationMillis = getApproximateActivityTime(steps)
        let startTime = getStartTime()
        let activityDate = getActivityDate()
        let calories = getCalories(steps)
        
        parameter["activityId"] = walking_activity_id
        parameter["startTime"] = startTime
        parameter["durationMillis"] = durationMillis
        parameter["date"] = activityDate
        parameter["distance"] = steps
        parameter["manualCalories"]=calories
        parameter["distanceUnit"] = "Steps"
        
        Alamofire.request(.POST, fitbit_activity_url,parameters: parameter,headers:header).responseJSON{response in
            guard response.result.error == nil else {
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                print(value)
            }
        }
    }
    
    private func getCalories(steps:Int)->Double{
        return Double(steps) * 0.05
    }
    
    private func getApproximateActivityTime(steps:Int)-> Int {
        return steps*500; //  approx 2 steps per sec
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