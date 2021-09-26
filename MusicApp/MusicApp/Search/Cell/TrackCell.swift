//
//  TrackCell.swift
//  MusicApp
//
//  Created by Дмитрий Осипенко on 29.08.21.
//

import UIKit
import SDWebImage

protocol TrackCellViewModel {
    var iconUrlString: String? {get}
    var trackName: String {get}
    var artistName: String {get}
    var collectionName: String {get}
    
}

class TrackCell: UITableViewCell {
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var collectionName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.image = nil
    }
    
    func set(viewModel: TrackCellViewModel) {
        trackName.text = viewModel.trackName
        artistName.text = viewModel.artistName
        collectionName.text = viewModel.collectionName
        guard let url = URL(string: viewModel.iconUrlString ?? "") else {return}
        trackImageView.sd_setImage(with: url, completed: nil)
    }
    
}
