//
//  FitBitUserProfile.swift
//  HealthSync
//
//  Created by Girish Chaudhari on 12/5/15.
//  Copyright © 2015 SwiftStudio. All rights reserved.
//

import Foundation

class FitBitUserProfile {
    
    var age:Int
    let avatar_url:String
    let fullName:String
    let gender:String
    let height:Double
    let weight:Double
    
    init (age:Int,avatar_url:String,fullName:String,gender:String,height:Double,weight:Double){
        
        self.age = age
        self.avatar_url = avatar_url
        self.fullName = fullName
        self.gender = gender
        self.height = height
        self.weight = weight
        
    }
    
}