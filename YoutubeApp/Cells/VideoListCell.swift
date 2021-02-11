//
//  VideoListCell.swift
//  YoutubeApp
//
//  Created by 小野寺祥吾 on 2021/02/09.
//

import UIKit
import Nuke
class VideoListCell:UICollectionViewCell{
    
    var videoItem :Item?{
        didSet{
            
            if let url = URL(string: videoItem?.snippet.thumbnails.medium.url ?? ""){
                Nuke.loadImage(with: url, into: thumbnailImageView)
            }
            if let channelUrl = URL(string: videoItem?.channel?.items[0].snippet.thumbnails.medium.url ?? "" ){
                Nuke.loadImage(with: channelUrl, into: channelImageView)
            }
            
            titleLabel.text = videoItem?.snippet.title
            descriptionLabel.text = videoItem?.snippet.description
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    @IBOutlet weak var channelImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        channelImageView.layer.cornerRadius = 40 / 2
    }
//
//    override init(frame:CGRect){
//        super.init(frame:frame)
//        backgroundColor = .black
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
