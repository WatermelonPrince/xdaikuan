//
//  LoanApplicationView.swift
//  Loan
//
//  Created by zhaohuan on 2017/8/28.
//  Copyright © 2017年 caipiao. All rights reserved.
//

import UIKit

class LoanApplicationView: UIView {
    var lineView : UIView!
    var applicationBtn : UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.lineView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: DIMEN_BORDER));
        self.lineView.backgroundColor = COLOR_BORDER;
        self.applicationBtn = UIButton(frame: CGRect(x: 15, y: 8, width: SCREEN_WIDTH - 30, height: 40));
        self.applicationBtn.backgroundColor = COLOR_BLUE_BUTTON;
        self.applicationBtn.setTitle("立即申请", for: .normal);
        self.applicationBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15);
        self.applicationBtn.layer.cornerRadius = 5;
        self.applicationBtn.layer.masksToBounds = true;
        self.backgroundColor = COLOR_WHITE;
        self.addSubview(self.lineView);
        self.addSubview(self.applicationBtn);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    

}
