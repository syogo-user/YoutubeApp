//
//  AttentionCollectionViewCell.swift
//  YoutubeApp
//
//  Created by 小野寺祥吾 on 2021/02/11.
//

import UIKit
import Nuke
class AttentionCollectionViewCell:UICollectionViewCell{
    

    @IBOutlet weak var thumbnailImageview: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var videoItem :Item? {
        didSet{
            if let url = URL(string: videoItem?.snippet.thumbnails.medium.url ?? ""){
                Nuke.loadImage(with: url, into: thumbnailImageview)
            }
            videoTitleLabel.text = videoItem?.snippet.title
            descriptionLabel.text = videoItem?.snippet.description
            channelTitleLabel.text = videoItem?.channel?.items[0].snippet.title
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
}
