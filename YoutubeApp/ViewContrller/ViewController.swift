//
//  ViewController.swift
//  YoutubeApp
//
//  Created by 小野寺祥吾 on 2021/02/09.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    private let cellId = "cellId"
    private var videoItems = [Item]()
    private let headerMoveHeight :CGFloat = 5

    private var prevContentOffset :CGPoint = .init(x:0,y:0)    //0.5秒前のスクロール位置
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var videoListCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoListCollectionView.delegate = self
        videoListCollectionView.dataSource = self

        videoListCollectionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        profileImageView.layer.cornerRadius = 20
        fetchYoutubeSearchInfo()
    }
    private func fetchYoutubeSearchInfo(){
        let params = ["q":"reborn katekyo"]
        
        API.shared.request(path: .search , params: params, type: Video.self) { (video) in
            //apiRequestの中のcompletionメソッドが呼ばれたときの処理
            self.videoItems = video.items
            let id = self.videoItems[0].snippet.channelId
            self.fetchYoutubeChannelInfo(id: id)
        }
    }
    
    private func fetchYoutubeChannelInfo(id:String){
        let params = [
            "id":id
        ]
        
        API.shared.request(path: .channels, params: params, type: Channel.self) { (channel) in
            self.videoItems.forEach{ (item) in
                item.channel = channel
            }
            self.videoListCollectionView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //今どのくらいスクロールしているかわかるメソッド （もともと持っているメソッド）
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //0.5秒ごとのスクロール位置情報を保持する (0.5ごとに呼ばれる）
            self.prevContentOffset = scrollView.contentOffset
        }
        
        guard let presentIndexPath = videoListCollectionView.indexPathForItem(at: scrollView.contentOffset) else { return}
                
        
        //一番上になったとき
        if scrollView.contentOffset.y < 0 {return}
        
        //一番下になったとき
        if presentIndexPath.row >= videoItems.count - 2 {return}
        
        let alphaRatio = 1 / headerHeightConstraint.constant//ここは0.1とかの固定の数字でも良い気がする。headerHeightConstraint.constantで割る必要はないかも
//        print("headerHeightConstraint.constant",headerHeightConstraint.constant ,"alphaRatio",alphaRatio)
        if self.prevContentOffset.y < scrollView.contentOffset.y{
            //0.5秒前のスクロールが今のスクロールより小さい場合 =下にスクロールしている
            if headerTopConstraint.constant <= -headerHeightConstraint.constant {return}//ヘッダーの高さを超えたらreturn
            //ヘッダーの高さを超えるまではヘッダーを上に移動させる
            headerTopConstraint.constant -= headerMoveHeight
            //ヘッダーの薄さ
            headerView.alpha -= alphaRatio * headerMoveHeight
        } else if self.prevContentOffset.y > scrollView.contentOffset.y{
            //0.5秒前のスクロールが今のスクロールより大きい場合 =上にスクロールしている
            
            if headerTopConstraint.constant >= 0 {return}//ヘッダーの高さが0以上ならreturn
            //ヘッダーの高さが0になるまではヘッダーを下に移動させる
            headerTopConstraint.constant += headerMoveHeight
            //ヘッダーの薄さ
            headerView.alpha += alphaRatio * headerMoveHeight
        }
                    
//        print("self.prevContentOffset:", self.prevContentOffset ,"scrollView.contentOffset:",scrollView.contentOffset)
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //　ドラッグが終わって指が離れた。減速しつつも慣性でその後もスクロールがある場合はdecelerateがYESになっている。
        if !decelerate {
            //ピタッと止めたとき
            headerViewEndAnimation()
        }

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //　スクロールが急停止した際に呼ばれる。
        headerViewEndAnimation()
    }
    
    
    private func headerViewEndAnimation(){
        //途中でスクロールを止めたときの動きを実装
        
        if headerTopConstraint.constant < -headerHeightConstraint.constant / 2 {
            //上に隠す
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: []) {
                self.headerTopConstraint.constant = -self.headerHeightConstraint.constant
                self.headerView.alpha = 0
                self.view.layoutIfNeeded() //Animationをつけるときにこれを設定
            }
        }else{
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: []) {
                self.headerTopConstraint.constant = 0
                self.headerView.alpha = 1
                self.view.layoutIfNeeded() //Animationをつけるときにこれを設定
            }
        }
    }
}

extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        return .init(width:width,height:width)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier:cellId, for: indexPath) as! VideoListCell
        cell.videoItem = videoItems[indexPath.row]
        return cell
    }
    
    
}
