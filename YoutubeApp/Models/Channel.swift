//
//  Channel.swift
//  YoutubeApp
//
//  Created by 小野寺祥吾 on 2021/02/11.
//

import Foundation

class Channel:Decodable{
    let items:[ChannelItem]
}
class ChannelItem:Decodable{
    let snippet:ChannelSnippet
}
class ChannelSnippet:Decodable{
    let title :String
    let thumbnails:Thumbnail
}
