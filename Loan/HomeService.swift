//
//  HomeService.swift
//  Lottery
//
//  Created by DTY on 2017/4/24.
//  Copyright © 2017年 caipiao. All rights reserved.
//

import UIKit

class Paginator: BaseModel {
    
    var page : String?
    var limit: String?
    var nextPage: String?
    var hasNextPage: Bool = true
    
}

class HomeService: BaseService {
    
    var bannerList: Array<Advertisement>!;
    var cornerBanner: Banner!;
    var productList: Array<Product>!;
    var paginator: Paginator!
    var connerAd : Advertisement!
    var popupAd : Advertisement!
    
    func getHome() {
        if LotteryUtil.appKey() == nil {
            //当APPID为空时，初始化失败，需要再次调用inital接口
            AppDelegate.context.initial();
        }
        self.get(HTTPConstants.HOME, parameters: nil) { (json) in
            self.bannerList = [Advertisement].deserialize(from: json["bannerList"].rawString()!) as? Array<Advertisement>;
            self.cornerBanner = Banner.deserialize(from: json["cornerBanner"].rawString()!);
            self.productList = [Product].deserialize(from: json["productList"].rawString()!) as? Array<Product>;
            self.paginator = Paginator.deserialize(from: json["paginator"].rawString()!);

            self.connerAd = Advertisement.deserialize(from: json["connerAd"].rawString()!);
            self.popupAd = Advertisement.deserialize(from: json["popupAd"].rawString()!);

            self.onCompleteSuccess();
        }
    }
}


class HomeLoadMoreService: BaseService {
    var bannerList: Array<Banner>!;
    var cornerBanner: Banner!;
    var productList: Array<Product>!;
    var paginator: Paginator!
    var connerAd : Advertisement!
    var popupAd : Advertisement!
    
    
    func getHomeLoadMore(nextPage:String?,limit:String?) {
        let parameter = ["page":nextPage ?? "1","limit":limit ?? "10"];
        if LotteryUtil.appKey() == nil {
            //当APPID为空时，初始化失败，需要再次调用inital接口
            AppDelegate.context.initial();
        }
        self.get(HTTPConstants.HOME, parameters: parameter) { (json) in
           
            self.productList = [Product].deserialize(from: json["productList"].rawString()!) as? Array<Product>;
            self.paginator = Paginator.deserialize(from: json["paginator"].rawString()!);
            self.connerAd = Advertisement.deserialize(from: json["connerAd"].rawString()!);
            self.popupAd = Advertisement.deserialize(from: json["popupAd"].rawString()!);
            self.onCompleteSuccess();
        }
    }
    
}
