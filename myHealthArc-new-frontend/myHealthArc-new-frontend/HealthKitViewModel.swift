//
//  HealthKitViewModel.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/6/24.
//

import HealthKit
import SwiftUI

class HealthKitViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager.shared
    
    // Initialize and request permissions if needed
    func initializeHealthKit() {
        healthKitManager.requestPermissionsIfNeeded()
    }
}
