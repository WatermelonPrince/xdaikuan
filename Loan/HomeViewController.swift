//
//  HomeViewController.swift
//  Lottery
//
//  Created by DTY on 17/1/18.
//  Copyright © 2017年 caipiao. All rights reserved.
//

import UIKit

class HomeViewController: CommonRefreshTableViewController, SDCycleScrollViewDelegate, ServiceDelegate ,UIGestureRecognizerDelegate{
    
    var cycleScrollView: SDCycleScrollView!;
    var productList = Array<Product>();
    var redPacketButton: UIButton!;
    
    var homeService: HomeService!;
    var homeLoadMoreService : HomeLoadMoreService!
    var paginator = Paginator();
    var homeAd : HomeAdView!
    var adRedPacketView : AdRedpacketView!
    var connerAd : Advertisement?
    var popupAd : Advertisement?
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationItem.title = "首页";
        
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: SCREEN_WIDTH/750*245 + 7));
        tableHeaderView.backgroundColor = COLOR_GROUND;
        
        //Banner
        self.cycleScrollView = CommonCycleScrollView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: SCREEN_WIDTH/750*245), delegate: self, placeholderImage: nil);
        tableHeaderView.addSubview(self.cycleScrollView);
        self.cycleScrollView.delegate = self;
        self.setBannerImageUrl();
        
        self.tableView.tableHeaderView = tableHeaderView;
        
        
        //TableView
        self.tableView.register(HomeTableViewCell.classForCoder(), forCellReuseIdentifier: "cell");
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        self.tableView.mj_footer.isHidden = false;
        self.hasNoMoreData = false
        if LotteryUtil.homeEntranceList() != nil {
            self.productList = LotteryUtil.homeEntranceList()!;
        }

        
        //redPacket
        let redPacketWidth = SCREEN_WIDTH*0.13;
        self.redPacketButton = UIButton(frame: CGRect(x: SCREEN_WIDTH-redPacketWidth-10, y: SCREEN_HEIGHT-redPacketWidth-100, width: redPacketWidth, height: redPacketWidth));
        self.redPacketButton.sd_setImage(with: CommonUtil.getURL(LotteryUtil.cornerBanner()?.imgUrl), for: .normal);
        self.redPacketButton.addTarget(self, action: #selector(cornerBannerAction), for: .touchUpInside);
        self.view.addSubview(self.redPacketButton);
        
        self.homeService = HomeService(delegate: self);
        self.homeLoadMoreService = HomeLoadMoreService(delegate:self);
        ViewUtil.showProgressToast();
        self.headerRefresh();
        
        //Observer
        NotificationCenter.default.addObserver(self, selector: #selector(headerRefresh), name: Notification.Name.UIApplicationWillEnterForeground, object: nil);
        
       
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        if self.homeAd != nil {
            self.homeAd.removeFromSuperview();
        }
        if self.adRedPacketView != nil {
            self.adRedPacketView.removeFromSuperview();
        }
    }
    
   
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    override func headerRefresh() {
        self.homeService.getHome();
    }
    
    override func footerRefresh() {
        if self.paginator.hasNextPage == false {
            ViewUtil.showToast(text: "没有更多数据");
            self.tableView.mj_footer.endRefreshing();
            return;
        }
        self.homeLoadMoreService.getHomeLoadMore(nextPage: self.paginator.nextPage, limit: self.paginator.limit);
    }
    
    override func onCompleteSuccess(service: BaseService) {
        ViewUtil.dismissToast();
        
        if (service.isKind(of: homeService.classForCoder)) {
            //Banner
            if (self.homeService.bannerList != nil) {
                LotteryUtil.saveBannerList(bannerList: self.homeService.bannerList);
            }
            self.setBannerImageUrl();
            
            if (self.homeService.cornerBanner != nil) {
                LotteryUtil.saveCornerBanner(banner: self.homeService.cornerBanner);
            }
            self.redPacketButton.sd_setImage(with: CommonUtil.getURL(LotteryUtil.cornerBanner()?.imgUrl), for: .normal);
            
            //ProductList
            if (self.homeService.productList != nil) {
                self.productList = self.homeService.productList;
                LotteryUtil.saveHomeEntranceList(entranceList: self.productList);
               
                self.tableView.reloadData();
            }
            self.paginator = self.homeService.paginator;
            self.connerAd = self.homeService.connerAd;
            self.popupAd = self.homeService.popupAd;
            if AppConfigure.shareAppConfigure.advertisementShowOrHidden(adModel: self.popupAd ?? nil) == true {
                self.perform(#selector(showPopupAdView), with: nil, afterDelay: 3);
            }
            
            if AppConfigure.shareAppConfigure.advertisementShowOrHidden(adModel: self.connerAd ?? nil) == true {
                self.perform(#selector(showConnerAdView), with: nil, afterDelay: 3);
            }

        }else if(service.isKind(of: HomeLoadMoreService.classForCoder())){
            if (self.homeLoadMoreService.productList != nil) {
                self.productList.append(contentsOf: self.homeLoadMoreService.productList);
                self.tableView.reloadData();
            }
            self.paginator = self.homeLoadMoreService.paginator;
            self.connerAd = self.homeLoadMoreService.connerAd;
            self.popupAd = self.homeLoadMoreService.popupAd;
        }
        
       
        
 
        self.loadSuccess();
        
        
    }
    
    func showPopupAdView(){
        if self.homeAd != nil {
            self.homeAd.removeFromSuperview();
        }
        
        self.homeAd = HomeAdView(frame: self.view.bounds);
        self.homeAd.adverImageView.sd_setImage(with: CommonUtil.getURL(self.popupAd?.imageUrl ?? ""));
        self.homeAd.tapGesture?.addTarget(self, action: #selector(homeAdLinkAction));
        UIApplication.shared.keyWindow?.addSubview(self.homeAd);
    }
    
    func showConnerAdView(){
        if self.adRedPacketView != nil {
            self.adRedPacketView.removeFromSuperview();
        }

        self.adRedPacketView = AdRedpacketView(frame:CGRect(x: SCREEN_WIDTH - 75 - 30, y: SCREEN_HEIGHT - TABBARHEIGHT - 15 - 60, width: 60, height: 60));
        self.adRedPacketView.adModel = self.connerAd;
        self.view.addSubview(self.adRedPacketView);
    }
    
    func homeAdLinkAction(){
        guard self.popupAd?.link != nil else {
            return;
        }
        LoanRoutes.routeURLString((self.popupAd?.link!)!);
    }
    
    
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        let urlContent = LotteryUtil.bannerList()?[index].link;
        if (urlContent != nil) {
            LoanRoutes.routeURLString(urlContent!);
        }else{
            let alertController = UIAlertController(title: "敬请期待", message: nil, preferredStyle: .alert);
            alertController.addAction(UIAlertAction(title: "好的", style: .cancel, handler: nil));
            alertController.show();
        }

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productList.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeTableViewCell;
        
        cell.setData(product: self.productList[indexPath.row]);
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        let product = self.productList[indexPath.row];
        let vc = LoanDetailViewController();
        vc.hidesBottomBarWhenPushed = true;
        vc.product = product;
        vc.productId = product.productId;
        AppContext().sendProductStatis(productId: product.productId);

        self.navigationController?.pushViewController(vc, animated: true);
//        self.showAdView();
        
    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero;
        cell.layoutMargins = UIEdgeInsets.zero;
    }
    
    func navAction(_ button: HomeCellItemView) {
        // todo 进详情页
    }
    
    func setBannerImageUrl() {
        let bannerList = LotteryUtil.bannerList();
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
    
    func cornerBannerAction() {
        if (LotteryUtil.cornerBanner() != nil) {
            let urlContent = LotteryUtil.cornerBanner()?.detailUrl;
            if (urlContent != nil) {
               LoanRoutes.routeURLString(urlContent!);
            }
            
        }
    }
    
}
