//
//  FuliTableViewController.swift
//  Loan
//
//  Created by zhaohuan on 2017/8/24.
//  Copyright © 2017年 caipiao. All rights reserved.
//

import UIKit

class FuliTableViewController: CommonRefreshTableViewController, ServiceDelegate,SDCycleScrollViewDelegate{
    var cycleScrollView: SDCycleScrollView!;
    var tableHeaderView: UIView!
    var fcousBgView : UIView!;
    
    var fuliService : FuliService!;
    var fuliObject = FuliObject();
    var popupAd : Advertisement?
    var connerAd : Advertisement?
    var fuliAdView : HomeAdView!
    var adRedPacketView : AdRedpacketView!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "福利"
        self.tableView.register(FuliTableViewCell.classForCoder(), forCellReuseIdentifier: "FuliTableViewCell");
        self.setUpTableHeaderView();
        self.tableView.backgroundColor = COLOR_GROUND;
        


        self.fuliService = FuliService(delegate: self);
        ViewUtil.showProgressToast();
        self.headerRefresh();
        self.tableView.mj_footer.isHidden = true;
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        if self.fuliAdView != nil {
            self.fuliAdView.removeFromSuperview();
        }
        if self.adRedPacketView != nil {
            self.adRedPacketView.removeFromSuperview();
        }
    }
    
    override func headerRefresh() {
        self.fuliService.getFuli();
    }
    
    override func onCompleteSuccess(service: BaseService) {
        ViewUtil.dismissToast();
        if service.isKind(of: FuliService.classForCoder()){
            if self.fuliService.fuliObject != nil {
                self.fuliObject = self.fuliService.fuliObject;
                self.reloadTableHeaderView();
                self.tableView.reloadData();
                if self.fuliObject.popupAd != nil {
                    self.popupAd = self.fuliObject.popupAd;
                    if AppConfigure.shareAppConfigure.advertisementShowOrHidden(adModel: self.popupAd ?? nil) == true {
                        self.perform(#selector(showPopupAdView), with: nil, afterDelay: 3);
                    }
                }
                if self.fuliObject.connerAd != nil {
                    self.connerAd = self.fuliObject.connerAd;
                    if AppConfigure.shareAppConfigure.advertisementShowOrHidden(adModel: self.connerAd ?? nil) == true {
                        self.perform(#selector(showConnerAdView), with: nil, afterDelay: 3);
                    }
                }
            }
        }
        self.loadSuccess();
    }
    
    
    func showPopupAdView(){
        
        self.fuliAdView = HomeAdView(frame: self.view.bounds);
        self.fuliAdView.adverImageView.sd_setImage(with: CommonUtil.getURL(self.popupAd?.imageUrl ?? ""));
        self.fuliAdView.tapGesture?.addTarget(self, action: #selector(fuliAdLinkAction));

        UIApplication.shared.keyWindow?.addSubview(self.fuliAdView);
    }
    
    func showConnerAdView(){
        self.adRedPacketView = AdRedpacketView(frame:CGRect(x: SCREEN_WIDTH - 75 - 30, y: SCREEN_HEIGHT - TABBARHEIGHT - 15 - 60, width: 60, height: 60));
        self.adRedPacketView.adModel = self.connerAd;
        self.view.addSubview(self.adRedPacketView);
    }
    
    func fuliAdLinkAction(){
        guard self.popupAd?.link != nil else {
            return;
        }
        LoanRoutes.routeURLString((self.popupAd?.link!)!);
    }
    
    func setUpTableHeaderView(){
        self.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: SCREEN_WIDTH/750*245+10));
        tableHeaderView.backgroundColor = COLOR_GROUND;
        
        //Banner
        self.cycleScrollView = CommonCycleScrollView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: SCREEN_WIDTH/750*245), delegate: self, placeholderImage: nil);
        tableHeaderView.addSubview(self.cycleScrollView);
        self.cycleScrollView.delegate = self;
//        self.setBannerImageUrl();
        self.fcousBgView = UIView();
        self.fcousBgView.frame = CGRect(x: 0, y: self.cycleScrollView.bottom(), width: SCREEN_WIDTH, height: 167/2);
        
       
        self.tableHeaderView.addSubview(self.fcousBgView);
        self.tableHeaderView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: self.fcousBgView.bottom() + 15);
        
        self.tableView.tableHeaderView = tableHeaderView;
    }
    
    func pushToCatagoryList(action:UIButton){
        let model = self.fuliService.fuliObject.tagsList[action.tag - 1000];
        if model.link != nil {
            LoanRoutes.routeURLString(model.link!);

        }else{
            let alertController = UIAlertController(title: "敬请期待", message: nil, preferredStyle: .alert);
            alertController.addAction(UIAlertAction(title: "好的", style: .cancel, handler: nil));
            alertController.show();
        }
        
    }
    
    func reloadTableHeaderView(){
        self.setBannerImageUrl();
        self.tableHeaderView.backgroundColor = COLOR_WHITE;
        for view in self.fcousBgView.subviews {
            view.removeFromSuperview();
        }
        if self.fuliService.fuliObject.tagsList != nil {
            
            while self.fuliService.fuliObject.tagsList.count > 4 {
                self.fuliService.fuliObject.tagsList.removeLast();
            }
            
            let count = self.fuliService.fuliObject.tagsList.count;
            let width = CGFloat(70.0);
            let height = CGFloat(60);
            let spaceWith = (SCREEN_WIDTH - 70 * CGFloat(count))/CGFloat(count);
            
            for i in 0..<count  {
                let fcousView = FcousView(frame: CGRect(x: spaceWith/2 + (width + spaceWith)*CGFloat(i), y: 15, width: width, height: height));
                fcousView.fcousButton.tag = 1000 + i;
                fcousView.fcousButton.addTarget(self, action: #selector(pushToCatagoryList), for: .touchUpInside);
                let model = self.fuliService.fuliObject.tagsList[i];
                fcousView.fcousButton.sd_setImage(with: CommonUtil.getURL(model.imageUrl!), for: .normal);
                fcousView.fcousLabel.text = model.title;
                
                self.fcousBgView.addSubview(fcousView);
            }
        }
    }
    
    
    func setBannerImageUrl() {
        let bannerList = self.fuliService.fuliObject.bannerList;
        var imageUrlList = Array<String>();
        if (bannerList != nil) {
            for banner in bannerList! {
                if (banner.imageUrl != nil) {
                    imageUrlList.append(banner.imageUrl!);
                }
            }
            self.cycleScrollView.imageURLStringsGroup = imageUrlList;
        }
    }
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
         let adverObj = self.fuliObject.bannerList[index];
        if (adverObj.link != nil){
            LoanRoutes.routeURLString(adverObj.link ?? "");
        }else{
            let alertController = UIAlertController(title: "敬请期待", message: nil, preferredStyle: .alert);
            alertController.addAction(UIAlertAction(title: "好的", style: .cancel, handler: nil));
            alertController.show();
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.fuliObject.categoryList != nil {
            return self.fuliObject.categoryList[section].advertisements.count;
        }
        return 0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FuliTableViewCell")as!FuliTableViewCell;
        let category = self.fuliObject.categoryList[indexPath.section];
        let fuliProduct = category.advertisements[indexPath.row];
        cell.setData(model: fuliProduct);
        cell.patiButton.addTarget(self, action: #selector(cellButtonAction), for: .touchUpInside);
        return cell;
    }
    func cellButtonAction(action:PaticipateButton){
        let model = action.fuliModel;
        if (model?.link != nil){
            LoanRoutes.routeURLString((model?.link)!);
        }else{
            let alertController = UIAlertController(title: "敬请期待", message: nil, preferredStyle: .alert);
            alertController.addAction(UIAlertAction(title: "好的", style: .cancel, handler: nil));
            alertController.show();
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let category = self.fuliObject.categoryList[section];
        let headerBgView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 55));
        headerBgView.backgroundColor = COLOR_GROUND;
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: DIMEN_BORDER));
        lineView.backgroundColor = COLOR_BORDER;
        let header = ViewforHeaderInLoan(frame: CGRect(x: 0, y: 10, width: SCREEN_WIDTH, height: 45));
        headerBgView.addSubview(lineView);
        headerBgView.addSubview(header);
        header.titleLabel.text = category.name;
        
        
        switch section%3 {
        case 0:
            header.verLineView.backgroundColor = COLOR_BLUE;
            header.tagImageView.sd_setImage(with: CommonUtil.getURL(category.image));
        case 1:
            header.verLineView.backgroundColor = COLOR_RED;
        case 2:
            header.verLineView.backgroundColor = COLOR_YELLOW;

            
        default:
            ();
        }
        
        return headerBgView;
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.fuliObject.categoryList != nil {
            return self.fuliObject.categoryList.count;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: false);
        let category = self.fuliObject.categoryList[indexPath.section];
        let fuliProduct = category.advertisements[indexPath.row];
        if fuliProduct.link != nil {
            LoanRoutes.routeURLString(fuliProduct.link ?? "");
        }else{
            let alertController = UIAlertController(title: "敬请期待", message: nil, preferredStyle: .alert);
            alertController.addAction(UIAlertAction(title: "好的", style: .cancel, handler: nil));
            alertController.show();
        }
        
      
    }
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
