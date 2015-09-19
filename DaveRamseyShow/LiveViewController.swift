//
//  FirstViewController.swift
//  DaveRamseyShow
//
//  Created by Porter Hoskins on 9/19/15.
//  Copyright © 2015 Porter Hoskins. All rights reserved.
//

import UIKit
import PSOperations
import AVKit

var channel: Channel?

class LiveViewController: UIViewController {
	var playerViewController: AVPlayerViewController?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let channelOperation = GetChannelOperation()
		let completion = BlockOperation {
			channel = channelOperation.channel
			guard let url = channel?.liveStreamUrl else {
				return
			}

			let streamOperation = GetStreamUrlOperation(url: url)
			let playOperation = BlockOperation {
				guard let streamUrl = streamOperation.streamUrl else {
					return
				}

				let player = AVPlayer(URL: streamUrl)
				self.playerViewController?.player = player
				player.play()
			}

			playOperation.addDependency(streamOperation)
			operationQueue.addOperation(streamOperation)
			operationQueue.addOperation(playOperation)
		}

		completion.addDependency(channelOperation)
		operationQueue.addOperation(channelOperation)
		operationQueue.addOperation(completion)
	}

	var prefferedFocusView: UIView? {
		return playerViewController?.view
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let playerViewController = segue.destinationViewController as? AVPlayerViewController {
			self.playerViewController = playerViewController
//			playerViewController.requiresLinearPlayback = true
		}
	}
}

