//
//  HealthManager.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import Foundation
import HealthKit

class HealthManager {
    let storage = HKHealthStore()
    static let TOTAL_STEPS_COUNT_AS_DOUBE:String = "totalStepsCountAsDouble"
    static let STEP_RECORD_ARRAY:String = "stepRecordArray"

    init() {
        authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
            }
            else
            {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                }
            }
        }
    }


    func authorizeHealthKit(completion: ((success: Bool, error: NSError!) -> Void)!) {

        let healthKitTypesToRead = Set(arrayLiteral:
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)!,
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            HKObjectType.workoutType()
        )

        let healthKitTypesToWrite = Set(arrayLiteral:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            HKQuantityType.workoutType()
        )

        if(!HKHealthStore.isHealthDataAvailable()) {
            let error = NSError(domain: "com.CompleteStack", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in thie Device"])
            if(completion != nil) {
                completion(success:false, error: error)
            }
            return ;
        }

        storage.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            if(completion != nil) {
                completion(success: success, error:error)
            }
        }
    }


    func recentSteps(completion: (Dictionary<String, AnyObject>, NSError?) -> () )
    {
        var stepsMap: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()

        // The type of data we are requesting (this is redundant and could probably be an enumeration
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)

        // Our search predicate which will fetch data from now until a day ago
        // (Note, 1.day comes from an extension
        // You'll want to change that to your own NSDate
        let predicate = HKQuery.predicateForSamplesWithStartDate((NSDate() .dateByAddingTimeInterval(60*60*24*(-1))), endDate: NSDate(), options: .None)

        if(!HKHealthStore.isHealthDataAvailable()) {
            return ;
        }
        // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var steps: Double = 0

            if results?.count > 0
            {
                var stepRecords:Array<Double> = Array<Double>();
                for result in results as! [HKQuantitySample]
                {
                    stepRecords.append(result.quantity.doubleValueForUnit(HKUnit.countUnit()))
                    steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                }
                stepsMap[HealthManager.TOTAL_STEPS_COUNT_AS_DOUBE] = steps;
                stepsMap[HealthManager.STEP_RECORD_ARRAY] = stepRecords;
            }

            completion(stepsMap, error)
        }

        storage.executeQuery(query)
    }

    func saveSteps(numberOfStepsToSave:Int) {
        let hkUnit = HKUnit(fromString: "count")

        let steptype = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let stepQuantity = HKQuantity(unit: hkUnit, doubleValue: Double(numberOfStepsToSave))
        let stepSample = HKQuantitySample(type: steptype!, quantity: stepQuantity, startDate: NSDate(), endDate: NSDate())


        storage.saveObject(stepSample, withCompletion: { success, error in
            if(error != nil) {
                print("Error Saving Data \(error)")
            } else {
                print("Data Saved")
            }

        })
    }
    
/*
func checkAuthorization() -> Bool
{
    // Default to assuming that we're authorized
    var isEnabled = true

    // Do we have access to HealthKit on this device?
    if HKHealthStore.isHealthDataAvailable()
    {
        // We have to request each data type explicitly
        let steps = NSSet(object: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)

        // Now we can request authorization for step count data
        storage.requestAuthorizationToShareTypes(nil, readTypes: steps as! Set<HKObjectType>) { (success, error) -> Void in
            isEnabled = success
        }
    }
    else
    {
        isEnabled = false
    }
    
    return isEnabled
}

    func readProfile() -> (age:Int?, biologicalsex: HKBiologicalSexObject?, bloodType: HKBloodTypeObject?) {
        var age:Int?
        var biologicalSex:HKBiologicalSexObject?
        var bloodType:HKBloodTypeObject?
        
        // 1. Request birthday and calculate age
        do {
            let birthDay = try storage.dateOfBirth()
            let today = NSDate()
            let flags: NSCalendarUnit = .Year
            let birthDayComponent = NSCalendar.currentCalendar().components(flags, fromDate: birthDay)
            let todayComponent = NSCalendar.currentCalendar().components(flags, fromDate: today)
            age = todayComponent.year - birthDayComponent.year
            
            // 2. Read biological sex
            biologicalSex = try! storage.biologicalSex()
            
            // 3. Read blood type
            bloodType = try! storage.bloodType()
        } catch {
            
        }
        
        // 4. Return the information read in a tuple
        return (age!, biologicalSex, bloodType)
        
    }

    func getSteps() {
        let healthStore: HKHealthStore? = {
            if HKHealthStore.isHealthDataAvailable() {
                return HKHealthStore()
            } else {
                return nil
            }
        }()
        
        let stepsCount = HKQuantityType.quantityTypeForIdentifier(
            HKQuantityTypeIdentifierStepCount)
        
        let dataTypesToWrite = NSSet(object: stepsCount!)
        let dataTypesToRead = NSSet(object: stepsCount!)
        
        healthStore?.requestAuthorizationToShareTypes((dataTypesToWrite as? Set<HKSampleType>),
            readTypes: (dataTypesToRead as! Set<HKObjectType>),
            completion: { [unowned self] (success, error) in
                if success {
                    print("SUCCESS")
                } else {
                    print(error!.description)
                }
            })
        
        // Don't forget to execute the Query!
        
        
    }

    func getActualSteps() {
        let stepsCount = HKQuantityType.quantityTypeForIdentifier(
            HKQuantityTypeIdentifierStepCount)
        
        let stepsSampleQuery = HKSampleQuery(sampleType: stepsCount!,
            predicate: nil,
            limit: 100,
            sortDescriptors: nil)
            { [unowned self] (query, results, error) in
                if let results = results as? [HKQuantitySample] {
                    for r in results {
                        print(String(r.quantity.doubleValueForUnit(HKUnit.countUnit())) + "\t\t\t" + String(r.startDate))
                    }
                }
        }
        // Don't forget to execute the Query!
        storage.executeQuery(stepsSampleQuery)
    }
    
    func f1() {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let components = calendar.components(.Day, fromDate: now)
        
        let startDate = calendar.dateFromComponents(components)
        let endDate = calendar.dateByAddingUnit(.Day, value: 1, toDate: startDate!, options: NSCalendarOptions(rawValue: 0))
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit: 0, sortDescriptors: nil) {
            query, results, error in
            
            if (results == nil) {
                print("An error occured fetching the user's tracked food. In your app, try to handle this gracefully. The error was: \(error.debugDescription)");
                abort();
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                for sample in results as! [HKQuantitySample] {
                    var foodName = ""
                    
                    if let foodType: AnyObject = sample.metadata![HKMetadataKeyFoodType] {
                        if let name = foodType as? String {
                            foodName = name
                            print(foodName)
                        }
                    }
                }
            }
        }
        
        storage.executeQuery(query)
    }
*/

}