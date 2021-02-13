//
//  APIRequest.swift
//  YoutubeApp
//
//  Created by 小野寺祥吾 on 2021/02/11.
//

import Foundation
import Alamofire

class API{
        
    enum PathType:String{
        case search
        case channels
    }
    //    シングルトン
    static let shared = API()

    private let baseUrl = "https://www.googleapis.com/youtube/v3/"
    func request<T:Decodable>(path :PathType,params:[String:Any],type:T.Type,completion:@escaping (T) -> Void){

        let path = path.rawValue //rawValueはStringに変換してくれる
        let url = baseUrl + path + "?"
        var params = params
        params["key"] = "AIzaSyCxgMb9ErrplXhasAXVKCK2nW_otYbNSEs"
        params["part"] = "snippet"

        
        let request = AF.request(url, method: .get, parameters: params)
        
        request.responseJSON{(response) in
            guard let statucCode =  response.response?.statusCode else{return}
            if statucCode <= 300 {
                do{
                    guard let data = response.data else{return}
                    let decorder = JSONDecoder()
                    //T　ジェネリクス
                    let value = try decorder.decode(T.self, from: data)
                    
                    completion(value)
                }catch{
                    print("変換に失敗しました。：",error)
                }

            }
        }
    }

}
