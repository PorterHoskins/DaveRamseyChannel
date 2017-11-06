//
//  Episode.swift
//  DaveRamseyShowAPI
//
//  Created by Porter Hoskins on 11/5/17.
//  Copyright © 2017 Porter Hoskins. All rights reserved.
//

import Foundation

public struct Episode: Codable {
    public let id: Int
    public let broadcastDate: Date
    public let title: String
    public let complete: Bool
    public let showHours: [ShowHour]
    
    enum CodingKeys: String, CodingKey {
        case id
        case broadcastDate = "broadcast_on"
        case title
        case complete
        case showHours = "show_hours"
    }
}
