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
}