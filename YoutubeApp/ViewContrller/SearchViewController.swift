//
//  SearchViewController.swift
//  YoutubeApp
//
//  Created by 小野寺祥吾 on 2021/02/13.
//
import Foundation
import UIKit

class SearchViewController:UIViewController{
    
    
    private let videoCellId = "VideoCell"
    var video:Video?
        lazy var searchBar:UISearchBar = {
            let sb = UISearchBar()
            sb.placeholder = "youtubeを検索"
            sb.delegate = self
            
            return sb
        }()
    
    
    lazy var videoCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionVew = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionVew.delegate = self
        collectionVew.dataSource = self
        collectionVew.backgroundColor = .systemBackground
        return collectionVew
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupViews()
        
    }
    private func setupViews(){
        view.backgroundColor = .white
        navigationItem.titleView = searchBar
        navigationItem.titleView?.frame = searchBar.frame
        
        videoCollectionView.frame = self.view.frame
        self.view.addSubview(videoCollectionView)
        videoCollectionView.register(UINib(nibName:"VideoListCell",bundle: nil),  forCellWithReuseIdentifier: videoCellId)
        
    }
}
//MARK: -UISearchBarDelegate
extension SearchViewController:UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //Cancelボタンを表示
        searchBar.showsCancelButton = true
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        //キーボードをしまう
        searchBar.resignFirstResponder()
 
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //検索ボタン押下時
        
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        //api通信を呼ぶ
        let searchBarText = searchBar.text ?? ""
        fetchYoutubeSearchInfo(searchText: searchBarText)
        
    }
}

//MARK:UICollectionViewDelegate,UICollectionViewDataSource
extension SearchViewController :UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let prevController = self.presentingViewController as! BaseTabBarController
        let videoList = prevController.viewControllers?[0] as! VideoListViewController
        videoList.selectedItem = video?.items[indexPath.row]
        dismiss(animated: true) {
            NotificationCenter.default.post(name: .init("searchedItem"), object: nil)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        return .init(width:width,height:width)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return video?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = videoCollectionView.dequeueReusableCell(withReuseIdentifier: self.videoCellId, for: indexPath) as! VideoListCell
        cell.videoItem = video?.items[indexPath.row]
        return cell
    }
}
//MARK: -API通信
extension SearchViewController{
    private func fetchYoutubeSearchInfo(searchText:String){
        let params = ["q":searchText]
        
        API.shared.request(path: .search , params: params, type: Video.self) { (video) in
            //apiRequestの中のcompletionメソッドが呼ばれたときの処理
            self.video = video //右辺のvideoはVideo型
            self.fetchYoutubeChannelInfo()
        }
    }
    
    private func fetchYoutubeChannelInfo(){
        guard let video = self.video else{return}
        for (index ,item) in video.items.enumerated() {
            let params = [
                "id":item.snippet.channelId
            ]
            API.shared.request(path: .channels, params: params, type: Channel.self) { (channel) in
                self.video?.items[index].channel = channel
                self.videoCollectionView.reloadData()
            }
        }
        

    }
}
