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
            
            tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let episode = episodes[indexPath.row]
        let shows = episode.showHours
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EpisodeCell
        cell.titleLabel.text = headerDateFormatter.string(from: episode.broadcastDate)
        cell.descriptionLabel?.text = shows.map({ "• \($0.title)" }).joined(separator: "\n")
        
        let percentWatched = Float(UserDefaults.watchedPercentage(for: episode.id))
        cell.progressView.progress = percentWatched
        
        let progressString: String
        switch percentWatched {
        case 0:
            progressString = NSLocalizedString("Unplayed", comment: "Unplayed")
        case 1:
            progressString = NSLocalizedString("Completed", comment: "Completed")
        default:
            progressString = String(format: NSLocalizedString("%d%% Watched", comment: "Percent of show watched"), Int(percentWatched * 100))
        }
        cell.progressLabel.text = progressString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let show = episodes[indexPath.row].showHours.first else { return }
        
        Youtube.h264videosWithYoutubeURL(show.watchURL) { [weak self] videoInfo, error in
            guard let videoURLString = videoInfo?["url"] as? String, let videoURL = URL(string: videoURLString) else { return }
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "play", sender: EpisodeURL(showID: show.showID, url: videoURL))
            }
        }
    }
}

class EpisodeCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var progressLabel: UILabel!
}
