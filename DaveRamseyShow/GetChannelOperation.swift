//
//  GetChannelOperation.swift
//  DaveRamseyShow
//
//  Created by Porter Hoskins on 9/19/15.
//  Copyright © 2015 Porter Hoskins. All rights reserved.
//

import Foundation
import PSOperations
import SwiftyJSON

class GetChannelOperation: Operation {
	var channel: Channel?

	override func execute() {
		guard let url = NSURL(string: "https://api.drtlgi.com/media/channels/tdrs/") else {
			finish([NSError(code: OperationErrorCode.ExecutionFailed)])
			return
		}

		guard let data = NSData(contentsOfURL: url) else {
			finish([NSError(code: OperationErrorCode.ExecutionFailed)])
			return
		}

		channel = Channel(json: JSON(data: data))
		finish()
	}
}

class GetStreamUrlOperation: Operation {
	private var url: NSURL
	var streamUrl: NSURL?

	init(url: NSURL) {
		self.url = url
	}

	override func execute() {
		guard let html = try? NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding) else {
			finish([NSError(code: OperationErrorCode.ExecutionFailed)])
			return
		}

		do {
			let regex = try NSRegularExpression(pattern: "<video src=\"(.*)\\?", options: .CaseInsensitive)
			let match = regex.matchesInString(html as String, options: NSMatchingOptions.ReportProgress, range: html.rangeOfString(html as String)).first

			guard match?.numberOfRanges > 1 else {
				finish([NSError(code: OperationErrorCode.ExecutionFailed)])
				return
			}

			guard let range = match?.rangeAtIndex(1) else {
				finish([NSError(code: OperationErrorCode.ExecutionFailed)])
				return
			}

			let urlString = html.substringWithRange(range)
			guard let url = NSURL(string: urlString) else {
				finish([NSError(code: OperationErrorCode.ExecutionFailed)])
				return
			}

			streamUrl = url
			finish()
		} catch let error as NSError {
			finish([error])
		}
	}
}

class Channel {
	let data: JSON
	init(json: JSON) {
		data = json["_embedded"]["lampo:media/category"][0]["_embedded"]["lampo:media/category"]
	}

	var liveStreamUrl: NSURL? {
		let liveStreamInformation = data[1]["_embedded"]["lampo:media/category"][3]["_embedded"]["lampo:media/clip"][0]["_embedded"]["lampo:media/clip/video"][1]
		guard let link = liveStreamInformation["href"].string, let type = liveStreamInformation["media_format"].string?.componentsSeparatedByString(":").last else {
			return nil
		}

		return NSURL(string: String(format: "%@&manifest=%@", arguments: [link, type]))
	}
}