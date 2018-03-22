//
//  HomeTableViewCell.swift
//  Lottery
//
//  Created by DTY on 17/1/18.
//  Copyright © 2017年 caipiao. All rights reserved.
//

import UIKit

class HomeTableViewCell: CommonBaseTableViewCell {
    let MAX_AUTHORIZE_TAGS = 5;
    
    var borderView: UIView!;
    var logoImageView: UIImageView!
    var merchantNameLabel: UILabel!;
    var loanAmountLabel: UILabel!;
    var loanDaysLabel: UILabel!;
    var authorizeTagsLabelArray: Array<UILabel>!;
    var advantageLabel: UILabel!;
    var titleArr = Array<Tags>();
    var tagBgView : UIView!
    var recommandImage : UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.selectionStyle = .none;
        
        self.backgroundColor = COLOR_GROUND;
        
        self.borderView = UIView(frame: CGRect(x: 10, y: 5, width: SCREEN_WIDTH - 20, height: 130));
        self.borderView.backgroundColor = COLOR_WHITE;
        self.borderView.layer.cornerRadius = 6;
        self.borderView.layer.borderColor = COLOR_BORDER.cgColor;
        self.borderView.layer.borderWidth = 0.5;
        self.contentView.addSubview(borderView);
        
        // 公司logo
        self.logoImageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 70, height: 70));
        self.contentView.addSubview(self.logoImageView);
        
        // 公司名称
        self.merchantNameLabel = UILabel(frame: CGRect(x: self.logoImageView.frame.maxX + 30, y: self.logoImageView.frame.minY, width: self.frame.width - self.logoImageView.frame.maxX - 20 - 30, height: 20));
        self.merchantNameLabel.font = UIFont.boldSystemFont(ofSize: 14);
        self.merchantNameLabel.textColor = COLOR_FONT_TEXT;
        self.merchantNameLabel.textAlignment = .left;
        self.contentView.addSubview(self.merchantNameLabel);
        
        // 金额
        self.loanAmountLabel = UILabel(frame: CGRect(x: self.merchantNameLabel.frame.minX, y: self.merchantNameLabel.frame.maxY + 5, width: self.merchantNameLabel.frame.width, height: 24));
        self.loanAmountLabel.font = UIFont.systemFont(ofSize: 17);
        self.loanAmountLabel.textColor = COLOR_RED;
        self.contentView.addSubview(self.loanAmountLabel);
        
        //标签背景视图
        self.tagBgView = UIView(frame: CGRect(x: self.loanAmountLabel.left(), y: self.loanAmountLabel.bottom() + 10, width: self.loanAmountLabel.width(), height: 15));

      //推荐tag图
        self.recommandImage = UIImageView(frame: CGRect(x: self.borderView.right() - 35, y: self.borderView.top(), width: 35, height: 35));
        
        
        
        
        
        let splitLine = UILabel(frame: CGRect(x: self.borderView.frame.minX, y: self.loanAmountLabel.frame.maxY + 35, width: self.borderView.frame.width, height: DIMEN_BORDER));
        splitLine.backgroundColor = COLOR_BORDER;
        
        //优势
        self.advantageLabel = UILabel(frame: CGRect(x: self.logoImageView.left(), y: splitLine.bottom() + 10, width: self.borderView.width() - 30, height: 15));
        self.advantageLabel.textColor = COLOR_FONT_TEXT;
        self.advantageLabel.font = UIFont.systemFont(ofSize: 13);
        self.contentView.addSubview(splitLine);
        self.contentView.addSubview(self.recommandImage);
        self.contentView.addSubview(self.advantageLabel);
        self.contentView.addSubview(self.tagBgView);

        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(product: Product) {
        self.logoImageView.sd_setImage(with: CommonUtil.getURL(product.productLogo ?? ""));
        self.merchantNameLabel.text = product.productName;
        let appedStr = NSMutableAttributedString(string: "最高额度：", attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15)]);
        let amoutAttstr = NSMutableAttributedString(string: product.maxLoanAmount ?? "", attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 17)]);
        appedStr.append(amoutAttstr);
        self.loanAmountLabel.attributedText = appedStr;
        
//        //清空上次标签
        for view in self.tagBgView.subviews {
            view.removeFromSuperview();
        }
        self.titleArr.removeAll();
        
        if product.authorizeTagsList != nil {
            for tagModel in product.authorizeTagsList! {
                tagModel.colorType = 0;
                self.titleArr.append(tagModel);
            }
        }
        
        if product.featureTagsList != nil {
            for tagModel in product.featureTagsList! {
                tagModel.colorType = 1;

                self.titleArr.append(tagModel);
            }
        }
        
        
        
        
        
        var totalWidth = CGFloat(0);
        for tagModel in self.titleArr {
            let strWith = CommonUtil.autoLabelWidth(text: tagModel.name!, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 11)]) + 8;
            let width = CommonUtil.autoLabelWidth(text: tagModel.name!, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 11)]) + 8 + totalWidth;
            if width < self.tagBgView.width() {
                totalWidth = CommonUtil.autoLabelWidth(text: tagModel.name!, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 11)]) + totalWidth + 8;
                let label = UILabel(frame: CGRect(x: totalWidth - strWith, y: 0, width: strWith - 4, height: 15));
                label.font = UIFont.systemFont(ofSize: 11);
                label.layer.cornerRadius = 2;
                label.textAlignment = .center;
                label.layer.borderWidth = DIMEN_BORDER;
                label.text = tagModel.name;
                self.tagBgView.addSubview(label);
                if tagModel.colorType == 0 {
                    label.backgroundColor = COLOR_TAGGROUND_BLUE;
                    label.layer.borderColor = COLOR_TAG_BLUE.cgColor;
                    label.textColor = COLOR_TAG_BLUE;
                }else{
                    label.backgroundColor = COLOR_TAGGROUND_YELLOW.withAlphaComponent(0.7);
                    label.layer.borderColor = COLOR_YELLOW.cgColor;
                    label.textColor = COLOR_TAGTEXT_YELLOW;
                    
                }
            }
            
        }
        self.recommandImage.image = nil;
        if (product.recommendTagsList != nil) {
            self.recommandImage.sd_setImage(with: CommonUtil.getURL(product.recommendTagsList?[0].image));
        }
        
        self.advantageLabel.text = product.advantage ?? "";
        

    }
    
}

