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
    
    var presentedPlayerViewController: AVPlayerViewController?
    var backgroundPlayerViewController: AVPlayerViewController?
    var videoURL: URL? {
        didSet {
            guard let videoURL = videoURL, videoURL != oldValue else { return }
            
            let player = AVPlayer(url: videoURL)
            
            backgroundPlayerViewController?.player = player
            backgroundPlayerViewController?.player?.play()
            backgroundPlayerViewController?.player?.isMuted = true
            
            backgroundPlayerViewController?.view.isHidden = false
        }
    }
    
    var videoID: String?
    
    var isLive: Bool = false {
        didSet {
            UIView.setAnimationsEnabled(false)
            self.playButton.setTitle(isLive ? watchLiveTitle : latestShowTitle, for: .normal)
            UIView.setAnimationsEnabled(true)
        }
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		
        updateShowStatus()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backgroundPlayerViewController?.player?.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check to see if we are coming back from a presentedPlayerViewController and save the duration if we aren't watching the live show.
        if !isLive, let playerItem = presentedPlayerViewController?.player?.currentItem, let videoID = videoID {
            let currentTime = CMTimeGetSeconds(playerItem.currentTime())
            let duration = CMTimeGetSeconds(playerItem.duration)
            
            UserDefaults.updatePercentWatched(for: videoID, percentage: Double(currentTime / duration))
            
            self.presentedPlayerViewController = nil
        }
        
        updateShowStatus()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        backgroundPlayerViewController?.player?.pause()
    }
    
    func updateShowStatus() {
        DaveRamseyShowAPI.fetchIsShowLive { isLive, secondsUntilLive in
            DispatchQueue.main.async {
                self.isLive = isLive
            }
        }
        
        DaveRamseyShowAPI.fetchLiveShow { response in
            guard let response = response, let videoURL = response.videoURL else { return }
            defer {
                self.videoID = response.videoID
            }
            
            guard self.videoID != response.videoID else { return }
            
            Youtube.h264videosWithYoutubeURL(videoURL) { [weak self] videoInfo, error in
                guard let videoURLString = videoInfo?["url"] as? String, let videoURL = URL(string: videoURLString) else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.videoURL = videoURL
                }
            }
        }
    }
    
	var prefferedFocusView: UIView? {
		return playButton
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "play" else {
            guard let playerViewController = segue.destination as? AVPlayerViewController else { return }
            
            self.backgroundPlayerViewController = playerViewController
            playerViewController.view.isHidden = true
            playerViewController.showsPlaybackControls = false
            return
        }
        
        guard let sender = sender as? URL, let playerViewController = segue.destination as? AVPlayerViewController else { return }
        
        let player = AVPlayer(url: sender)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: .new, context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.duration), options: .new, context: nil)
        
        playerViewController.player = player
        presentedPlayerViewController = playerViewController
    }
    
    @IBAction func playPressed(_ sender: Any) {
        performSegue(withIdentifier: "play", sender: videoURL)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let player = object as? AVPlayer, let videoID = videoID else { return }
        
        guard player.status == .readyToPlay else { return }
        
        guard let duration = player.currentItem?.duration, duration != kCMTimeIndefinite else {
            player.play()
            
            return
        }
        
        let watchedPercentage = UserDefaults.watchedPercentage(for: videoID)
        let startTime = CMTimeMakeWithSeconds(watchedPercentage * Double(CMTimeGetSeconds(duration)), 1)
        
        player.currentItem?.seek(to: startTime) { _ in
            player.play()
        }
    }
}

