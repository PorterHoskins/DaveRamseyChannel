//
//  FirstViewController.swift
//  DaveRamseyShow
//
//  Created by Porter Hoskins on 9/19/15.
//  Copyright © 2015 Porter Hoskins. All rights reserved.
//

import UIKit
import AVKit
import DaveRamseyShowAPI

let latestShowTitle = NSLocalizedString("Replay Latest Show", comment: "Replay latest show button title")
let watchLiveTitle = NSLocalizedString("Watch Live", comment: "Watch Live button title")

class LiveViewController: UIViewController {
	
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    var playerViewController: AVPlayerViewController?

	override func viewDidLoad() {
		super.viewDidLoad()
		
        DaveRamseyShowAPI.fetchIsShowLive { isLive, secondsUntilLive in
            DispatchQueue.main.async {
                UIView.setAnimationsEnabled(false)
                self.playButton.setTitle(isLive ? watchLiveTitle : latestShowTitle, for: .normal)
                UIView.setAnimationsEnabled(true)
            }
        }
        
        DaveRamseyShowAPI.fetchLiveShow { response in
            guard let videoURL = response?.videoURL else { return }
            Youtube.h264videosWithYoutubeURL(videoURL) { [weak self] videoInfo, error in
                guard let videoURLString = videoInfo?["url"] as? String, let videoURL = URL(string: videoURLString) else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.playerViewController?.player = AVPlayer(url: videoURL)
                    self?.playerViewController?.player?.play()
                    self?.playerViewController?.player?.isMuted = true
                    
                    self?.playerViewController?.view.isHidden = false
                }
            }
        }
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playerViewController?.player?.play()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playerViewController?.player?.pause()
    }
    
	var prefferedFocusView: UIView? {
		return playButton
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let playerViewController = segue.destination as? AVPlayerViewController else { return }
        
        self.playerViewController = playerViewController
        playerViewController.view.isHidden = true
    }
    
    @IBAction func playPressed(_ sender: Any) {
        overlayView.isHidden = true
        playButton.isHidden = true
        
        let player = playerViewController?.player
        player?.seek(to: kCMTimeZero)
        player?.isMuted = false
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

