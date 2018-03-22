//
//  LoanDetailUserView.swift
//  Loan
//
//  Created by zhaohuan on 2017/8/25.
//  Copyright © 2017年 caipiao. All rights reserved.
//

class TagModel: BaseModel {
    var titleStr : String!
    var type : Int!
    
}
class LoanDetailUserView: UIView {
    var iconImageView : UIImageView!
    var titleLabel : UILabel!
    var tagBgView : UIView!
    var titleArr = Array<Tags>();

    override init(frame: CGRect) {
        super.init(frame: frame);
        self.iconImageView = UIImageView(frame: CGRect(x: 15, y: 20, width: 60, height: 60));
        
        self.iconImageView.contentMode = .scaleAspectFit;
        self.iconImageView.layer.cornerRadius = 30;
        self.iconImageView.layer.masksToBounds = true;
        self.titleLabel = UILabel(frame: CGRect(x: self.iconImageView.right() + 20, y: 30, width: SCREEN_WIDTH - 50 - self.iconImageView.width(), height: 20));
        self.titleLabel.font = UIFont.systemFont(ofSize: 16);
        self.titleLabel.textColor = COLOR_FONT_HEAD;
        self.tagBgView = UIView(frame: CGRect(x: self.titleLabel.left(), y: self.titleLabel.bottom() + 10, width: self.titleLabel.width(), height: 15));
//        self.tagBgView.backgroundColor = COLOR_RED;
        let lineView = UIView(frame: CGRect(x: 15, y: 92, width: SCREEN_WIDTH - 30, height: 0.5));
        lineView.backgroundColor = COLOR_BORDER;
        self.addSubview(self.iconImageView);
        self.addSubview(self.titleLabel);
        self.addSubview(self.tagBgView);
        self.addSubview(lineView);
        self.backgroundColor = COLOR_WHITE;
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadArr(conditionArr:Array<Tags>,descArr:Array<Tags>,imageUrl:String,title:String){
        self.iconImageView.sd_setImage(with: CommonUtil.getURL(imageUrl), placeholderImage: UIImage.init(named: ""));
        self.titleLabel.text = title;
        
        //清空上次标签
        self.titleArr.removeAll();
        for view in self.tagBgView.subviews {
            view.removeFromSuperview();
        }
        
        for tagmodel in conditionArr {
            tagmodel.colorType = 0;
            
            self.titleArr.append(tagmodel);
        }
        
        for tagmodel in descArr {
            tagmodel.colorType = 1;
            
            self.titleArr.append(tagmodel);
        }
        
        
        var totalWidth = CGFloat(0);
        for tagModel in self.titleArr {
           let strWith = CommonUtil.autoLabelWidth(text: tagModel.name ?? "", attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 11)]) + 8;
           let width = CommonUtil.autoLabelWidth(text: tagModel.name ?? "", attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 11)]) + 8 + totalWidth;
            if width < self.tagBgView.width() {
                totalWidth = CommonUtil.autoLabelWidth(text: tagModel.name ?? "", attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 11)]) + totalWidth + 8;
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
        
    }
    
    
    

}
