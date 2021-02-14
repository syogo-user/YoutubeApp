//
//  ViewController.swift
//  YoutubeApp
//
//  Created by 小野寺祥吾 on 2021/02/09.
//

import UIKit
import Alamofire

class VideoListViewController: UIViewController {
    
    //MARK: Properties
    private let cellId = "cellId"
    private let atentionCellId = "atentionCellId"
    private var videoItems = [Item]()
    private let headerMoveHeight :CGFloat = 5
    private var selectedItem : Item?

    private var prevContentOffset :CGPoint = .init(x:0,y:0)    //0.5秒前のスクロール位置
    

    @IBOutlet weak var videoListCollectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomVideoView: UIView!
    @IBOutlet weak var bottomVideoImageView: UIImageView!
    @IBOutlet weak var searchButton: UIButton!
    
    //bottomImageViewの制約
    @IBOutlet weak var bottomViedeoViewTraling: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoViewLeading: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoViewBottom: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoImageWidth: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoImageHeight: NSLayoutConstraint!

    @IBOutlet weak var bottomSubscribeView: UIView!
    @IBOutlet weak var bottomCloseButton: UIButton!
    @IBOutlet weak var bottomVideoTitleLabel: UILabel!
    @IBOutlet weak var bottomVideoDescribeLabel: UILabel!
    
    
    
    //MARK:LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchYoutubeSearchInfo()
        setupGestureRecognize()
        //videoViewControllerからうけとるpostが呼ばれたときにここが呼ばれる
        NotificationCenter.default.addObserver(self, selector: #selector(showThubnaiImage), name: .init("thumbnailImage"), object: nil)
        
    }
    //MARK:Methods
    @objc private func showThubnaiImage(notification:NSNotification){
        guard let userInfo = notification.userInfo as? [String:UIImage] ,
              let image = userInfo["image"] else{return}
//        let videoImageMinY = userInfo["videoImageMinY"] as? CGFloat ?? 0
//        let diffBottomConstant  = videoImageMinY - self.bottomVideoView.frame.minY
//        print("videoImageMinY",videoImageMinY ,"self.bottomVideoView.frame.minY",self.bottomVideoView.frame.minY)
//        bottomVideoViewBottom.constant -= diffBottomConstant //これをするとずれるため TODO
        bottomVideoViewBottom.constant = 30 //TODO
        
        bottomSubscribeView.isHidden = false
        bottomVideoView.isHidden = false
        bottomVideoImageView.image = image
        bottomVideoTitleLabel.text = self.selectedItem?.snippet.title
        bottomVideoDescribeLabel.text = self.selectedItem?.snippet.description
    }
    
    private func setupViews(){
        
        videoListCollectionView.delegate = self
        videoListCollectionView.dataSource = self
        videoListCollectionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        videoListCollectionView.register(AttentionCell.self, forCellWithReuseIdentifier: atentionCellId)
        profileImageView.layer.cornerRadius = 20
        
        view.bringSubviewToFront(bottomVideoView)
        bottomVideoView.isHidden = true
        bottomCloseButton.addTarget(self, action: #selector(tappedBottomCloseButton), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(tappedSearchButton), for: .touchUpInside)
    }
    
    @objc private  func tappedSearchButton(){
        let searchController = SearchViewController()
        let nav = UINavigationController(rootViewController: searchController)
        self.present(nav,animated: true,completion: nil)
    }
    
    @objc private func tappedBottomCloseButton(){
        UIView.animate(withDuration: 0.2) {
            self.bottomVideoViewBottom.constant = -150
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.bottomVideoView.isHidden = true
            self.selectedItem = nil
        }

    }
}
//MARK: -API通信
extension VideoListViewController{
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
    
}



// MARK: - scrollViewのDelegateメソッド
extension VideoListViewController{
    //scrollViewがscroollしたときに呼ばれるメソッド
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //今どのくらいスクロールしているかわかるメソッド （もともと持っているメソッド）
        headerAnimation(scrollView: scrollView)
                    
    }
    
    private func headerAnimation(scrollView:UIScrollView){
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
    }
    
    //scrollViewのscrollがピタッと止まったときに呼ばれる
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //　ドラッグが終わって指が離れた。減速しつつも慣性でその後もスクロールがある場合はdecelerateがYESになっている。
        if !decelerate {
            //ピタッと止めたとき
            headerViewEndAnimation()
        }

    }
    
    //scrollViewが止まったときに呼ばれる
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //　スクロールが急停止した際に呼ばれる。
        headerViewEndAnimation()
    }
    
    


}

//  MARK: - UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout
extension VideoListViewController:UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //セルをタップしたときに呼ばれる。
        
        let videoViewController = UIStoryboard(name: "Video", bundle: nil).instantiateViewController(identifier: "VideoViewController")as VideoViewController
        if videoItems.count == 0 {
            videoViewController.selectedItem = nil
            self.selectedItem = nil
        }else {
            //三項演算子
            let item = indexPath.row > 2 ? videoItems[indexPath.row - 1] : videoItems[indexPath.row]
            videoViewController.selectedItem = item
            self.selectedItem = item
        }
        bottomVideoView.isHidden = true
        self.present(videoViewController,animated: true,completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        
        if indexPath.row == 2{
            return .init(width:width ,height:200)
        }else{
            return .init(width:width,height:width)
        }
        
        
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoItems.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //? TODO
        if indexPath.row == 2{
            let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: atentionCellId, for: indexPath) as! AttentionCell
            cell.videoItems = self.videoItems
            return cell
        }else {
            let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier:cellId, for: indexPath) as! VideoListCell
            if self.videoItems.count == 0{return cell}
            
            if indexPath.row > 2{
                cell.videoItem = videoItems[indexPath.row - 1]
            }else {
                cell.videoItem = videoItems[indexPath.row]
            }
            return cell
        }

    }


    
}
//MARK: Animation関連
extension VideoListViewController {
    private func setupGestureRecognize(){
        //パンジェスチャーとタップジェスチャー
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panBottomVideoView))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBottomVideoView))
        bottomVideoView.addGestureRecognizer(panGesture)
        bottomVideoView.addGestureRecognizer(tapGesture)
        
    }
    @objc private func panBottomVideoView(sender:UIPanGestureRecognizer){
        let move  = sender.translation(in: view)
        guard let imageView = sender.view else{return}
        if sender.state == .changed {
            //動かしている場合
            imageView.transform = CGAffineTransform(translationX: 0 , y:move.y)
        }else if sender.state == .ended{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
                imageView.transform = .identity//元の位置
                self.view.layoutIfNeeded()
            }

        }
    }
    @objc private func tapBottomVideoView(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
            self.bottomSubscribeView.isHidden = true
            //Viewのサイズを大きくする
            self.bottomVideoViewExpandAnimation()
        } completion: {_ in
            //Viewのサイズを大きくしたあとに画面遷移する
            let videoViewController = UIStoryboard(name: "Video", bundle: nil).instantiateViewController(identifier: "VideoViewController") as VideoViewController
            videoViewController.selectedItem = self.selectedItem
            self.present(videoViewController,animated: false){
                //画面遷移後に実行 後ろのViewの大きさを変更
                self.bottomVideoViewBackToIdentyty()
            }

        }

        
    }
    private func bottomVideoViewExpandAnimation(){
        let topSafeArea = self.view.safeAreaInsets.top
        let bottomSafeArea = self.view.safeAreaInsets.bottom
        //bottomVideoView
        bottomVideoViewLeading.constant = 0
        bottomViedeoViewTraling.constant = 0
        bottomVideoViewBottom.constant = -bottomSafeArea
        bottomVideoViewHeight.constant = self.view.frame.height - topSafeArea
        
        //bottomVideoImageView
        bottomVideoImageWidth.constant = view.frame.width
        bottomVideoImageHeight.constant = 280
        
        self.tabBarController?.tabBar.isHidden = true
        self.view.layoutIfNeeded()
    }
    private func bottomVideoViewBackToIdentyty(){
        //bottomVideoView
        bottomVideoViewLeading.constant = 12
        bottomViedeoViewTraling.constant = 12
        bottomVideoViewBottom.constant = 55
        bottomVideoViewHeight.constant = 70
        
        //bottomVideoImageView
        bottomVideoImageWidth.constant = 150
        bottomVideoImageHeight.constant = 70
        
        bottomVideoView.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
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
