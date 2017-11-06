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
    
    let headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        
        return formatter
    }()
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sender = sender as? URL, let playerViewController = segue.destination as? AVPlayerViewController else { return }
        playerViewController.player = AVPlayer(url: sender)
        playerViewController.player?.play()
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
                self?.performSegue(withIdentifier: "play", sender: videoURL)
            }
        }
    }
}

class EpisodeCell: UITableViewCell {
    @IBOutlet var label: UILabel!
}
