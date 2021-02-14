//
//  VideoViewController.swift
//  YoutubeApp
//
//  Created by 小野寺祥吾 on 2021/02/12.
//

import UIKit
import Nuke
class VideoViewController:UIViewController{

    var selectedItem :Item?
    
    private var imageViewCenterY :CGFloat?
    var videoImageMaxY:CGFloat {
        let ecludeValue = view.safeAreaInsets.bottom  + (imageViewCenterY ?? 0)
        //viewの高さー bottomのsafeArea + (写真の半分の高さ)
        return view.frame.maxY - ecludeValue
    }
    var minimumImageViewTrailingConstant :CGFloat{
        -(view.frame.width - (150 + 12) )
    }
    //videoImageView
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoImageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoImageViewHeightConstraint: NSLayoutConstraint!
    
    
    //videoImageBackView
    @IBOutlet weak var videoImageBackView: UIView!
    
    //backView 白いところ
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backViewBottomConstraint: NSLayoutConstraint!
    
    //describeView
    @IBOutlet weak var describeView: UIView!
    @IBOutlet weak var describeViewTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var baseBackGroundView: UIView!




    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //全部のビューた出たあとに呼ばれる
        UIView.animate(withDuration: 0.3) {
            self.baseBackGroundView.alpha = 1
        }
        
    }
    private func setupViews(){
        //最前面に持ってくる
        self.view.bringSubviewToFront(videoImageView)
        
        imageViewCenterY = videoImageView.center.y
        
        channelImageView.layer.cornerRadius = 45 / 2
        
        if let url = URL(string: selectedItem?.snippet.thumbnails.medium.url ?? ""){
            Nuke.loadImage(with: url, into: videoImageView)
        }
        if let channelUrl = URL(string: selectedItem?.channel?.items[0].snippet.thumbnails.medium.url ?? "" ){
            Nuke.loadImage(with: channelUrl, into: channelImageView)
        }
        
        videoTitleLabel.text = selectedItem?.snippet.title
        channelTitleLabel.text = selectedItem?.channel?.items[0].snippet.title
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panVideoImageView))
        videoImageView.addGestureRecognizer(panGesture)
        
    }
    @objc private func panVideoImageView(gesture:UIPanGestureRecognizer){
        guard let imageView = gesture.view else{return}
        let move = gesture.translation(in: imageView)
        if gesture.state == .changed{
            //動いているとき
                        
            if videoImageMaxY <= move.y {
                moveToBottom(imageView: imageView as! UIImageView)
                return
            }
            imageView.transform = CGAffineTransform(translationX: 0, y: move.y)//動いた分yを動かす
            videoImageBackView.transform = CGAffineTransform(translationX: 0, y: move.y)
            //左右のpadding設定
            adjustPaddingChange(move: move)
            
            //imageViewの高さの動き
            adjustHeightChange(move: move)
            
            //aopha値の設定 0薄い　1濃い
            adjustAlphaChange(move: move)
            
            //imageViewの横幅の動き150（最小）
            adjustWidthChange(move: move)
            
            
        }else  if gesture.state == .ended {
            self.imageViewEndedAnimation(move: move, imageView: imageView as! UIImageView)
        }
        
        
    
    }
    
//MARK: imageViewのpanGestureのstatusが[.change]のときの動き
    private func adjustPaddingChange(move:CGPoint){
        //左右のpaddingの設定
        let movingConstant = move.y / 30
        if videoImageViewLeadingConstraint.constant <= 12{
            videoImageViewTrailingConstraint.constant = movingConstant
            videoImageViewLeadingConstraint.constant = movingConstant
            backViewTrailingConstraint.constant = movingConstant
        }
    }
    private func adjustHeightChange(move:CGPoint){
        //280（最大値）　ー　70（最小値）　＝210
        let parentViewHeight = self.view.frame.height
        let heightRatio =  210 / (parentViewHeight - (parentViewHeight / 6))
//        let heightRatio =  210 / (parentViewHeight - videoImageMaxY) //これにするとおかしくなるため上記を残す　TODO
        let moveHeight = move.y * heightRatio
            
        backViewTopConstraint.constant = move.y
        videoImageViewHeightConstraint.constant = 280 - moveHeight
        describeViewTopConstraint.constant = move.y * 0.8
        
        //下からせり上がる
        let bottomMoveY = parentViewHeight - videoImageMaxY
        let bottomMoveRatio = bottomMoveY / videoImageMaxY
        let bottomMoveConstant = move.y * bottomMoveRatio
        backViewBottomConstraint.constant = bottomMoveConstant
        

    }
    private func adjustAlphaChange(move:CGPoint){
        //aopha値の設定 0薄い　1濃い
        let alphaRatio = move.y / ( self.view.frame.height / 2 )
        describeView.alpha = 1 - alphaRatio
        baseBackGroundView.alpha = 1 - alphaRatio
    }
    
    private func adjustWidthChange(move :CGPoint){
        let originalWidth = self.view.frame.width
        let constant = originalWidth - move.y
        
        if minimumImageViewTrailingConstant > constant {
            videoImageViewTrailingConstraint.constant = minimumImageViewTrailingConstant
            return
        }
        if constant < -12 {
            videoImageViewTrailingConstraint.constant = -constant
        }
    }
    
    //    MARK: imageViewのpanGestureのstatusが[.ended]のときの動き
    private func imageViewEndedAnimation(move:CGPoint,imageView:UIImageView){
        print(move.y,self.view.frame.height / 3)
        //手を離したとき
        if move.y < self.view.frame.height / 3 {
            //移動している位置が,画面の3分の1の高さよりも小さかったら、上に戻す
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [],animations:  {
                self.backToIdentityAllViews(imageView: imageView)
            } )
        }else{
            //移動している位置が,画面の3分の1の高さよりも大きかった、下に固定する
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
                self.moveToBottom(imageView: imageView )
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {

                    self.videoImageView.isHidden = true
                    self.videoImageBackView.isHidden = true
                    
                    let image = self.videoImageView.image
                    let userInfo:[String:UIImage?] = ["image":image]
//                    let userInfo:[String :Any] = ["image":image,"videoImageMinY":self.videoImageView.frame.minY]
//                    print("self.videoImageView.frame.minY",self.videoImageView.frame.minY)
                    //情報(userInfo)をpostにわたす
                    NotificationCenter.default.post(name: .init("thumbnailImage"), object: nil, userInfo: userInfo as [AnyHashable : Any])

                } completion: { _ in
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    private func moveToBottom(imageView:UIImageView){
//        移動させる
        //imageviewの設定
        imageView.transform = CGAffineTransform(translationX: 0, y: videoImageMaxY)
        videoImageViewTrailingConstraint.constant = -minimumImageViewTrailingConstant
        videoImageViewHeightConstraint.constant = 70
        videoImageViewLeadingConstraint.constant = 12
        
        
        
        self.videoImageBackView.transform = CGAffineTransform(translationX: 0, y: videoImageMaxY)
        backView.alpha = 0
        describeView.alpha = 0
        baseBackGroundView.alpha = 0
        
        self.view.layoutIfNeeded()
    }
    private func backToIdentityAllViews(imageView:UIImageView){
        //元の位置に戻す
        //imageViewの設定
        imageView.transform = .identity//もとの位置に
        videoImageBackView.transform = .identity
        self.videoImageViewHeightConstraint.constant = 280
        self.videoImageViewLeadingConstraint.constant = 0
        self.videoImageViewTrailingConstraint.constant = 0
        
        //backViewの設定
        backViewTrailingConstraint.constant = 0
        backViewBottomConstraint.constant = 0
        backViewTopConstraint.constant = 0
        backView.alpha = 1
        
        
        //descrbeViewのせってい
        describeViewTopConstraint.constant = 0
        describeView.alpha = 1
        
        baseBackGroundView .alpha = 1
        
        self.view.layoutIfNeeded()
    }
}
