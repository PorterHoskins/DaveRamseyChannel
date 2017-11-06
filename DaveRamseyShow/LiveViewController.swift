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

class LiveViewController: UIViewController {
	var playerViewController: AVPlayerViewController?

	override func viewDidLoad() {
		super.viewDidLoad()
		
        
	}

	var prefferedFocusView: UIView? {
		return playerViewController?.view
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let playerViewController = segue.destination as? AVPlayerViewController else { return }
        
        self.playerViewController = playerViewController
        playerViewController.requiresLinearPlayback = true
        playerViewController.view.isHidden = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        guard let keyPath = keyPath, let new = change?[.new] as? Int, let status = AVPlayerStatus(rawValue: new), keyPath == "status" else {
//            return
//        }
//
//        switch status {
//        case .readyToPlay:
//            playerViewController?.view.isHidden = false
//        default:
//            playerViewController?.view.isHidden = true
//        }
    }
}

