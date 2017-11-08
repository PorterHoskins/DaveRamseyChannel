//
//  LiveShowResponse.swift
//  DaveRamseyShowAPI
//
//  Created by Porter Hoskins on 11/7/17.
//  Copyright © 2017 Porter Hoskins. All rights reserved.
//

import Foundation

public struct LiveShowResponse: Codable {
    public let items: [LiveShowItem]
    
    public var videoURL: URL? {
        return items.first?.snippet.resource.videoURL
    }
    
    public var thumbnails: [String: LiveShowItem.Snippet.Thumbnail] {
        return items.first?.snippet.thumbnails ?? [:]
    }
    
    public struct LiveShowItem: Codable {
        public let snippet: Snippet
        
        public struct Snippet: Codable {
            public let thumbnails: [String: Thumbnail]
            public let resource: Resource
            
            public enum ThumbnailType: String, Codable {
                case `default`
                case medium
                case high
                case standard
                case maxres
            }
            
            public struct Thumbnail: Codable {
                public let url: URL
                public let width: Int
                public let height: Int
            }
            
            public struct Resource: Codable {
                public let kind: String
                public let videoID: String
                
                enum CodingKeys: String, CodingKey {
                    case kind
                    case videoID = "videoId"
                }
                
                public var videoURL: URL? {
                    return URL(string: "https://www.youtube.com/watch?v=\(videoID)")
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case thumbnails
                case resource = "resourceId"
            }
        }
    }
}
