//
//  SearchViewController.swift
//  MusicApp
//
//  Created by Дмитрий Осипенко on 29.08.21.
//

import UIKit

struct TrackModel {
    var trackName: String
    var artistName: String
}

class SearchMusicViewController: UITableViewController {
    private var timer: Timer?
let searchController = UISearchController(searchResultsController: nil)
    var tracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
        setupSearchBar()
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        let track = tracks[indexPath.row]
        cell.textLabel?.numberOfLines = 2
        guard let name = track.artistName else { return cell}
        guard let albom = track.collectionName else { return cell}
        cell.imageView?.image = UIImage(systemName: "person")
        cell.textLabel?.text = "\(name) \n \(albom)"
        return cell
    }
}

extension SearchMusicViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            NetworkManager.shared.getMusic(text: searchText) { [weak self] searchResponse in
                guard let data = searchResponse.results else {return}
                self?.tracks = data
                self?.tableView.reloadData()
            } failure: {
                print("ERROR")
            }
        })
    }
}
