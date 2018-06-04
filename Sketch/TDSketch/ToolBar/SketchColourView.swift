//
//  SketchColourView.swift
//  Sketch
//
//  Created by 刘旦 on 2018/4/11.
//  Copyright © 2018年 YLT. All rights reserved.
//

import UIKit

typealias ClickEditingColor = (UIImage) -> ()

// 选择编辑颜色

class SketchColourView: UIView {
    
    var imageArray = Array<String>()
    
    var clickEditingColor : ClickEditingColor?
    
    var currentImage: UIImageView?
    
    init(frame: CGRect , images : Array<String>) {
        super.init(frame: frame)
        self.alpha = 0.8
        self.addSubview(scrollview)
        self.imageArray = images
        self.addsubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addconstraints()
    }
    
    //MARK : 添加约束
    func addconstraints(){
        scrollview.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }
    
    //MARK : 添加子控件
    func addsubviews(){
      
        for i in 0..<imageArray.count {
            let img = UIImageView()
            img.image = UIImage(named: imageArray[i])
            img.isUserInteractionEnabled = true
            viewBorder(img, borderWidth: 1.5, borderColor: UIColor.white, cornerRadius: 3)
            img.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(clickColorImageview(tap:))))
            scrollview.addSubview(img)
            
            img.snp.makeConstraints({ (maker) in
                maker.centerY.equalToSuperview()
                maker.left.equalTo(LSize.adapt(25) + (LSize.adapt(25)+20)*CGFloat(i))
                maker.width.height.equalTo(20)
            })
            
            // 默认选中黑色
            if i == imageArray.count-1 {
                self.currentImage = img
                self.currentImage?.alpha = 0.5
                if let selectImage = self.currentImage{
                    viewBorder(selectImage, borderWidth: 0, borderColor: UIColor.white, cornerRadius: 3)
                }
            }
        }
        
        scrollview.contentSize = CGSize(width: LSize.adapt(25)*CGFloat(imageArray.count+1)+20*CGFloat(imageArray.count)-KScreenWidth, height: 0)
        
    }
    
    // MARK:  设置圆角
    func viewBorder(_ view:UIView, borderWidth:CGFloat, borderColor:UIColor,cornerRadius:CGFloat){
        view.layer.borderWidth = borderWidth;
        view.layer.borderColor = borderColor.cgColor
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
    }
    
    // MARK : 选中颜色
    @objc func clickColorImageview(tap : UITapGestureRecognizer){
        if self.clickEditingColor != nil{
            self.currentImage?.alpha = 1
            if let oldColorImage = self.currentImage{
                viewBorder(oldColorImage, borderWidth: 1.5, borderColor: UIColor.white, cornerRadius: 3)
            }
            if let imageView = tap.view as? UIImageView{
                imageView.alpha = 0.5
                viewBorder(imageView, borderWidth: 0, borderColor: UIColor.white, cornerRadius: 3)
                self.currentImage = imageView
            }
            if let image = self.currentImage?.image , let clickblock = self.clickEditingColor {
                clickblock(image)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var  scrollview : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

}
