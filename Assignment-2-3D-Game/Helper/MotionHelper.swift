//
//  MotionHelper.swift
//  Assignment-2-3D-Game
//
//  Created by James McArdle on 19/04/2021.
//

import Foundation
import CoreMotion

// this will report movement detected by the device's onboard sensors.
class MotionHelper {
    let motionManager = CMMotionManager()
    
    init() {
    }
    // referenced from https://www.hackingwithswift.com/example-code/system/how-to-use-core-motion-to-read-accelerometer-data 
    func getAccelerometerData(interval: TimeInterval = 0.1, motionDataResults: ((_ x: Float, _ y: Float, _ z: Float) -> ())? ){
        
        if motionManager.isAccelerometerAvailable {
        
            motionManager.accelerometerUpdateInterval = interval
            
            // every frame get the acceleration of the device in each direction and return a vector to push the ball in that direction.
            motionManager.startAccelerometerUpdates(to: OperationQueue()) { (data, error) in
                if motionDataResults != nil {
                    motionDataResults!(Float(data!.acceleration.x), Float(data!.acceleration.y), Float(data!.acceleration.z))
                }
            }
            
        }
    }
}
