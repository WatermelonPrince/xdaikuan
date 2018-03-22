//
//  AppConfigure.swift
//  Loan
//
//  Created by zhaohuan on 2017/9/15.
//  Copyright © 2017年 caipiao. All rights reserved.
//

import UIKit

class AppConfigure {
    
    var adCache = NSCache<AnyObject, AnyObject>();
    
    class var shareAppConfigure: AppConfigure {
        struct Static {
            static let instace : AppConfigure = AppConfigure();
        }
        return Static.instace;
    }
    
    
    func advertisementShowOrHidden(adModel : Advertisement?) -> (Bool){
        if adModel == nil {
            return false;
            
            
        }
        if (adModel?.showType == nil || adModel?.showType == "") {
            print("广告showType为空");
            return false;
        }
        guard let imageUrl = adModel?.imageUrl else {
            print("广告imageUrl为nil");
            return false;
        }
        if adModel?.showType == "1" {
            if self.adCache.object(forKey: imageUrl as AnyObject) != nil {
                return false;
            }else{
                self.adCache.setObject(true as AnyObject, forKey: imageUrl as AnyObject);
                return true;
            }
            
        }else if(adModel?.showType == "2"){
            if adModel?.cycleTime == nil || adModel?.cycleTime == 0 {
                return false;
            }
            guard let value = UserDefaults.standard.object(forKey: (imageUrl as NSString).xh_md5 + (adModel?.position ?? "")) else {
                let date = Date.init(timeIntervalSinceNow: 0);
                let interval = date.timeIntervalSince1970;
                UserDefaults.standard.set(Double(interval), forKey: (imageUrl as NSString).xh_md5 + (adModel?.position ?? ""));
                UserDefaults.standard.synchronize();
                return true;
            }
            let date = Date.init(timeIntervalSinceNow: 0);
            let interval = date.timeIntervalSince1970;
            let minus = Double(interval) - (value as! Double)
            if minus < (adModel?.cycleTime!)! {
                return false;
            }else{
                UserDefaults.standard.set(Double(interval), forKey: (imageUrl as NSString).xh_md5 + (adModel?.position ?? ""));
                UserDefaults.standard.synchronize();
                return true;
            }
            
        }else if(adModel?.showType == "3"){
            guard UserDefaults.standard.object(forKey: (imageUrl as NSString).xh_md5 + (adModel?.position ?? "")) != nil else {
                UserDefaults.standard.set(true, forKey: (imageUrl as NSString).xh_md5 + (adModel?.position ?? ""));
                UserDefaults.standard.synchronize();
                return true;
            }
            return false;
        }
        return false;
    }

}
