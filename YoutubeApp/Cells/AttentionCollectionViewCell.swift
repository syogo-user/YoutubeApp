//
//  AttentionCollectionViewCell.swift
//  YoutubeApp
//
//  Created by 小野寺祥吾 on 2021/02/11.
//

import UIKit
class AttentionCollectionViewCell:UICollectionViewCell{
    
    @IBOutlet weak var thumbnailImageview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .purple
        
    }
}
