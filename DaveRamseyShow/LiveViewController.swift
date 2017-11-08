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
    var videoURL: URL? {
        didSet {
            guard let videoURL = videoURL else { return }
            
            playerViewController?.player = AVPlayer(url: videoURL)
            playerViewController?.player?.play()
            playerViewController?.player?.isMuted = true
            
            playerViewController?.view.isHidden = false
        }
    }

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
                    self?.videoURL = videoURL
                }
            }
        }
	}
    
    override func viewWillAppear(_ animated: Bool) {
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
        guard segue.identifier == "play" else {
            guard let playerViewController = segue.destination as? AVPlayerViewController else { return }
            
            self.playerViewController = playerViewController
            playerViewController.view.isHidden = true
            return
        }
        
        guard let sender = sender as? URL, let playerViewController = segue.destination as? AVPlayerViewController else { return }
        playerViewController.player = AVPlayer(url: sender)
        playerViewController.player?.play()
        
    }
    
    @IBAction func playPressed(_ sender: Any) {
        performSegue(withIdentifier: "play", sender: videoURL)
    }
}

