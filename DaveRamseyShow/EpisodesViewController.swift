//
//  EpisodesViewController.swift
//  DaveRamseyShow
//
//  Created by Porter Hoskins on 11/5/17.
//  Copyright © 2017 Porter Hoskins. All rights reserved.
//

import UIKit
import DaveRamseyShowAPI
import AVKit

class EpisodesViewController: UIViewController {
    
    struct EpisodeURL {
        let showID: Int
        let url: URL
    }
    
    let headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        
        return formatter
    }()
    
    private var playerViewController: AVPlayerViewController?
    private var selectedEpisode: EpisodeURL?
    
    @IBOutlet var tableView: UITableView!
    
    var episodes: [Episode] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension

        DaveRamseyShowAPI.fetchEpisodes { [weak self] episodes in
            self?.episodes = episodes
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check to see if we are coming back from a playerViewController and save the duration
        if let playerItem = playerViewController?.player?.currentItem, let episode = selectedEpisode {
            let currentTime = CMTimeGetSeconds(playerItem.currentTime())
            let duration = CMTimeGetSeconds(playerItem.duration)
            
            UserDefaults.updatePercentWatched(for: episode.showID, percentage: Double(currentTime / duration))
            
            self.playerViewController = nil
            self.selectedEpisode = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sender = sender as? EpisodeURL, let playerViewController = segue.destination as? AVPlayerViewController else { return }
        let player = AVPlayer(url: sender.url)
        playerViewController.player = player
        
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: .new, context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.duration), options: .new, context: nil)
        
        
        
        
        self.playerViewController = playerViewController
        self.selectedEpisode = sender
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let player = object as? AVPlayer, let episode = selectedEpisode else { return }
        print(change ?? [:])
        
        guard player.status == .readyToPlay else { return }
        
        guard let duration = player.currentItem?.duration, duration != kCMTimeIndefinite else {
            player.play()
            
            return
        }
        
        let watchedPercentage = UserDefaults.watchedPercentage(for: episode.showID)
        let startTime = CMTimeMakeWithSeconds(watchedPercentage * Double(CMTimeGetSeconds(duration)), 1)
        player.currentItem?.seek(to: startTime) { _ in
            player.play()
        }
    }

}

extension EpisodesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shows = episodes[indexPath.section].showHours
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EpisodeCell
        cell.label?.text = shows.map({ $0.title }).joined(separator: ", ")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerDateFormatter.string(from: episodes[section].broadcastDate)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let show = episodes[indexPath.section].showHours[indexPath.row]
        
        Youtube.h264videosWithYoutubeURL(show.watchURL) { [weak self] videoInfo, error in
            guard let videoURLString = videoInfo?["url"] as? String, let videoURL = URL(string: videoURLString) else { return }
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "play", sender: EpisodeURL(showID: show.showID, url: videoURL))
            }
        }
    }
}

class EpisodeCell: UITableViewCell {
    @IBOutlet var label: UILabel!
}
