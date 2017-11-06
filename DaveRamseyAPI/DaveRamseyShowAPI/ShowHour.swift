//
//  ShowHour.swift
//  DaveRamseyShowAPI
//
//  Created by Porter Hoskins on 11/5/17.
//  Copyright © 2017 Porter Hoskins. All rights reserved.
//

import Foundation

public struct ShowHour: Codable {
    public let id: Int
    public let showID: Int
    public let title: String
    public let hourNumber: Int
    public let watchURL: URL
    public let listenURL: URL
    public let complete: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case showID = "show_id"
        case title
        case hourNumber = "hour_number"
        case watchURL = "watch_url"
        case listenURL = "listen_url"
        case complete
    }
}
