//
//  UserDefaults.swift
//  DaveRamseyShow
//
//  Created by Porter Hoskins on 11/20/17.
//  Copyright © 2017 Porter Hoskins. All rights reserved.
//

import Foundation


class UserDefaults {
    
    static let watchedPercentageKey = "watchedPercentage"
    
    static func updatePercentWatched(for showID: Int, percentage: Double) {
        updatePercentWatched(for: "\(showID)", percentage: percentage)
    }
    
    static func watchedPercentage(for showID: Int) -> Double {
        return watchedPercentage(for: "\(showID)")
    }
    
    static func updatePercentWatched(for showID: String, percentage: Double) {
        var watchedPercentages = Foundation.UserDefaults.standard.dictionary(forKey: watchedPercentageKey) ?? [:]
        watchedPercentages["\(showID)"] = percentage
        
        Foundation.UserDefaults.standard.set(watchedPercentages, forKey: watchedPercentageKey)
    }
    
    static func watchedPercentage(for showID: String) -> Double {
        return Foundation.UserDefaults.standard.dictionary(forKey: watchedPercentageKey)?[showID] as? Double ?? 0.0
    }
}
