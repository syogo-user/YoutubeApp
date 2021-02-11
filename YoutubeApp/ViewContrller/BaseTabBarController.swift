//
//  BaseTabBarController.swift
//  YoutubeApp
//
//  Created by 小野寺祥吾 on 2021/02/11.
//

import UIKit
class BaseTabBarController:UITabBarController{
    enum ContrllerName:Int{
        //Int入れたことによってhomeが0,searchが1・・・となる
        case home ,search ,channel,inbox,library
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViewContrller()
    }
    
    private func setUpViewContrller(){
        viewControllers?.enumerated().forEach({ (index,viewController) in
            if let name = ContrllerName.init(rawValue: index) {
                switch name{
                case .home:
                    setTabbarImage(viewController, selectedImageName: "home_red", unselectedImageName: "home", title: "ホーム")
               
                case .search:
                    setTabbarImage(viewController, selectedImageName: "houi_red", unselectedImageName: "houi", title: "検索")
                case .channel:
                    setTabbarImage(viewController, selectedImageName: "start_red", unselectedImageName: "start", title: "登録チャンネル")
                case .inbox:
                    setTabbarImage(viewController, selectedImageName: "mail_red", unselectedImageName: "mail", title: "受信トレイ")
                case .library:
                    setTabbarImage(viewController, selectedImageName: "book_red", unselectedImageName: "book", title: "ライブラリ")
                }
            }//例indexが2だったらchannelをnameに入れてくれる

        })
    }
    private func setTabbarImage(_ viewController:UIViewController,selectedImageName :String,unselectedImageName:String,title:String){
        viewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.resize(size: .init(width: 20, height: 20
        ))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.image = UIImage(named: unselectedImageName)?.resize(size: .init(width: 20, height: 20))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.title = title
    }
    
}
