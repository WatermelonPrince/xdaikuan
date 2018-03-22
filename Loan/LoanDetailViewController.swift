//
//  LoanDetailViewController.swift
//  Loan
//
//  Created by zhaohuan on 2017/8/25.
//  Copyright © 2017年 caipiao. All rights reserved.
//

import UIKit

class LoanDetailViewController: CommonRefreshTableViewController,ServiceDelegate {
    var userHeaderView : LoanDetailUserView!
    var userFilterView : LoanDetailFilterView!
    var tableHeaderView : UIView!
    var loanApplicationView : LoanApplicationView!
    var product : Product!
    var monthRate : String?
    var dayRate : String?
    var tableViewArr = Array<ProductDetailComponent>();
    var applyCommitService : LoanApplyCommitService!
    var productDetailService : ProductService!
    var productId : String?

   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userHeaderView = LoanDetailUserView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 92.5));
        
        self.userFilterView = LoanDetailFilterView(frame: CGRect(x: 0, y: self.userHeaderView.bottom(), width: SCREEN_WIDTH, height: 172));
        
        self.userFilterView.pickersuperView = self.view;
        
        if self.product != nil {
            self.title = self.product.productName ?? "";
            self.userHeaderView.reloadArr(conditionArr: self.product.authorizeTagsList ?? [], descArr: self.product.featureTagsList ?? [], imageUrl: product.productLogo ?? "", title: product.productName ?? "");
            self.userFilterView.reloadViewWithParameter(product: self.product);
            self.reduceProductForTableData(product: self.product);
        }
        
        self.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: self.userFilterView.bottom()));
        self.tableHeaderView.addSubview(self.userHeaderView);
        self.tableHeaderView.addSubview(self.userFilterView);
        self.tableView.tableHeaderView = self.tableHeaderView;
        self.tableView.mj_footer.isHidden = true;
        self.tableView.mj_header.isHidden = false;
        self.tableView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 56 - FOOTERSAFEHEIGHT);
        self.loanApplicationView = LoanApplicationView(frame: CGRect(x: 0, y: SCREEN_HEIGHT - 56 - FOOTERSAFEHEIGHT, width: SCREEN_WIDTH, height: 56));
        self.loanApplicationView.applicationBtn.addTarget(self, action: #selector(applyCommit), for: .touchUpInside);
        
        self.view.addSubview(self.loanApplicationView);
        
        
        self.tableView.register(LoanProcessCell.classForCoder(), forCellReuseIdentifier: "LoanProcessCell");
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell");
        self.tableView.register(LoanDetailsTableViewCell.classForCoder(), forCellReuseIdentifier: "LoanDetailsTableViewCell");
        
        
        
        
        self.applyCommitService = LoanApplyCommitService(delegate:self);
        self.productDetailService = ProductService(delegate:self);
//        if self.product == nil {
            ViewUtil.showProgressToast();
            self.headerRefresh();
//        }

        

    }
    
    override func headerRefresh() {
        self.productDetailService.applyProductDetail(productId: self.productId);
    }
    
    func applyCommit(action : UIButton){
        if LotteryUtil.isLogin() == false {
            LotteryUtil.shouldLogin();
            return;
        }
        self.applyCommitService.applyCommit(token: LotteryUtil.token(), productId: String(describing: self.product.productId!),status: "1");
    }
    
    override func onCompleteSuccess(service: BaseService) {
        if service.isKind(of: applyCommitService.classForCoder) {
            if (product.applyInterface == nil || product.applyInterface == "" ) {
                self.loanApplicationView.applicationBtn.setTitle("已申请", for: .normal);
                self.loanApplicationView.applicationBtn.backgroundColor = COLOR_BROWN;
                return;
            }
            let vc = ProductApplyViewController();
            vc.productId = self.productId;
            vc.urlContent = product.applyInterface;
            self.pushViewController(viewController: vc);

            
        }else if service.isKind(of: ProductService.classForCoder()) {
            ViewUtil.dismissToast();

            if self.productDetailService.product != nil{
                self.product = self.productDetailService.product;
                self.title = self.product.productName ?? "";
                //刷新页面
                self.userHeaderView.reloadArr(conditionArr: self.product.authorizeTagsList ?? [], descArr: self.product.featureTagsList ?? [], imageUrl: product.productLogo ?? "", title: product.productName ?? "");
                self.userFilterView.reloadViewWithParameter(product: self.product);
                self.reduceProductForTableData(product: self.product);
                self.tableView.reloadData();
                self.loadSuccess();
            }
        }
    }
    
    func reduceProductForTableData(product:Product){
        self.tableViewArr.removeAll();
        if self.product.requirements != nil && ((self.product.requirements)!as NSString).length > 0{
            let proComponent = ProductDetailComponent();
            proComponent.titleStr = "申请条件&要点";
            proComponent.contentStr = self.product.requirements!;
            proComponent.type = 0;
            self.tableViewArr.append(proComponent);
        }
        if self.product.auditDetail != nil && ((self.product.auditDetail)!as NSString).length > 0{
            let proComponent = ProductDetailComponent();
            proComponent.titleStr = "借款审核细节";
            proComponent.contentStr = self.product.auditDetail!;
            proComponent.type = 0;

            self.tableViewArr.append(proComponent);

        }
        if self.product.guide != nil && ((self.product.guide)!as NSString).length > 0{
            let proComponent = ProductDetailComponent();
            proComponent.titleStr = "新手引导";
            proComponent.contentStr = self.product.guide!;
            proComponent.type = 0;

            self.tableViewArr.append(proComponent);
            
        }
        if self.product.advantage != nil && ((self.product.advantage)!as NSString).length > 0{
            let proComponent = ProductDetailComponent();
            proComponent.titleStr = "产品优势";
            proComponent.contentStr = self.product.advantage!;
            proComponent.type = 0;

            self.tableViewArr.append(proComponent);
            
        }
        if self.product.applyFlowTagsList != nil {
            let proComponent = ProductDetailComponent();
            proComponent.titleStr = "流程&材料";
            proComponent.applyFlowTagsList = self.product.applyFlowTagsList;
            proComponent.type = 1;

            self.tableViewArr.insert(proComponent, at: 1);
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerBgView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 55));
        headerBgView.backgroundColor = COLOR_GROUND;
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: DIMEN_BORDER));
        lineView.backgroundColor = COLOR_BORDER;
        let header = ViewforHeaderInLoan(frame: CGRect(x: 0, y: 10, width: SCREEN_WIDTH, height: 45));
        headerBgView.addSubview(lineView);
        headerBgView.addSubview(header);
        header.verLineView.backgroundColor = COLOR_BLUE;
        let proCompnentModel = self.tableViewArr[section];
        header.titleLabel.text = proCompnentModel.titleStr!;
        return headerBgView;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let proComponetModel = self.tableViewArr[indexPath.section];
        if proComponetModel.type == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoanDetailsTableViewCell")as!LoanDetailsTableViewCell;
            let str = proComponetModel.contentStr!;
            cell.reloadCell(textStr: str);
            cell.selectionStyle = .none;
            return cell;
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoanProcessCell", for: indexPath)as!LoanProcessCell;
            cell.reloadCellWithPrameter(dataArr: proComponetModel.applyFlowTagsList!);
            cell.selectionStyle = .none;

            return cell;
            
        }
        
       
        
        
       
        
        
    }
    

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewArr.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 84 * RATIO;

        }else{
            let cell = self.tableView(tableView, cellForRowAt: indexPath)as! LoanDetailsTableViewCell;
            return cell.height();
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
