//
//  API.swift
//  DaveRamseyShowAPI
//
//  Created by Porter Hoskins on 11/5/17.
//  Copyright © 2017 Porter Hoskins. All rights reserved.
//

import Foundation
import Alamofire

let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    
    decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.formatted(dateFormatter)
    return decoder
}()

@discardableResult
public func fetchEpisodes(completion: @escaping (_ episodes: [Episode]) -> ()) -> DataRequest {
    return Alamofire.request("https://www.daveramsey.com/show/archives/latest-episodes", method: .get).response { response in
        var episodes: [Episode] = []
        defer {
            completion(episodes)
        }
        
        guard let data = response.data else { return }
        
        do {
            episodes = try decoder.decode([Episode].self, from: data)
        } catch {
            print("error fetching episodes \(error)")
        }
    }
}

@discardableResult
public func fetchLiveShow(completion: @escaping (_ isLive: Bool, _ secondsUntilNextShow: Double?) -> ()) -> DataRequest {
    return Alamofire.request("https://www.daveramsey.com/show/stats/is-show-live", method: .get).responseJSON { response in
        var isLive = false
        var secondsUntilNextShow: Double?
        defer {
            completion(isLive, secondsUntilNextShow)
        }
        
        guard let json = response.result.value as? [String: Any] else { return }
        isLive = json["live"] as? Bool ?? false
        secondsUntilNextShow = json["seconds_till_next_show"] as? Double
    }
}
