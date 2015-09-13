//
//  RakutenFetcher.swift
//  Twitter2App
//
//  Created by Yoshi Ishigami on 2015/09/13.
//  Copyright (c) 2015年 Yoshi Ishigami. All rights reserved.
//

import Foundation
import Alamofire


class RakutenFetcher{
    let baseURL = "https://app.rakuten.co.jp/services/api/IchibaItem/Ranking/20120927"
    var defaultParameter:[String:String] = [
        "format":"json",
        "applicationId":"1008957560914550287"
    ]
    
    func download(callback : ([RakutenItem]) -> Void){

        Alamofire.request(.GET, baseURL, parameters: defaultParameter)
            .responseJSON { _, _, JSON, _ in
                
                if let json: AnyObject = JSON, let items = json["Item"] as? [AnyObject]{
                    
                    var returnArray:[RakutenItem] = []
                    
                    for(var i=0; i<items.count; i++){
                        if let item = items[i]["item"] as? [String:AnyObject]{
                            
                        }
                    }
                    callback(returnArray)
                }
                
        }
        
    }
}