//
//  SketchModelView.swift
//  Sketch
//
//  Created by 刘旦 on 2018/4/11.
//  Copyright © 2018年 YLT. All rights reserved.
//

import UIKit

// 模式切换协议
protocol  SketchModelDelegate : class {
    
    // 切换编辑模式
    func choiceSketchModel(model : SketchModel , isChoice : Bool)
    
}

// 底部绘画模式栏 (显示绘制模式 : 铅笔 橡皮擦 文本输入)

class SketchModelView: UIView {
    
    let buttonH = LSize.adapt(40)
    
    let buttonW = LSize.adapt(60)
    
    weak var delegate : SketchModelDelegate?
    
    var modeltext = ""{
        didSet{
            if modeltext.count > 0{
                self.pencilSelected = false
                self.eraseSelected = false
                self.modelLabel.text = modeltext
            }
        }
    }
    
    // 模式重置
    var modelreload = false{
        didSet{
            if modelreload{
                self.pencilSelected = false
                self.eraseSelected = false
            }
        }
    }
    
    // 铅笔模式选中状态
    var pencilSelected  = false{
        didSet{
            self.pencilButton.isSelected = pencilSelected
            if pencilSelected{
                self.eraseSelected = false
                self.modelLabel.text = "画笔模式"
            }else{
                self.modelLabel.text = ""
            }
        }
    }
    
    // 橡皮擦模式选中状态
    var eraseSelected = false{
        didSet{
            self.eraseButton.isSelected = eraseSelected
            if eraseSelected{
                self.pencilSelected = false
                self.modelLabel.text = "橡皮擦模式"
            }else{
                self.modelLabel.text = ""
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addsubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addconstraints()
    }
    
    //MARK: 点击画笔模式
    @objc func choicePencilModel(button : UIButton){
        self.pencilSelected = !self.pencilSelected
        self.delegate?.choiceSketchModel(model: .pencil , isChoice : self.pencilSelected)
    }
    
    //MARK: 点击橡皮擦模式
    @objc func choiceEraseModel(button : UIButton){
        self.eraseSelected = !self.eraseSelected
        self.delegate?.choiceSketchModel(model: .erase , isChoice : self.eraseSelected)

    }
    
    
    //MARK: 添加子视图
    func addconstraints(){
        pencilButton.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview().offset(-LSize.adapt(35))
            maker.centerY.equalToSuperview()
            maker.width.equalTo(buttonW)
            maker.height.equalTo(buttonH)
        }
        eraseButton.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview().offset(LSize.adapt(35))
            maker.centerY.equalToSuperview()
            maker.width.equalTo(buttonW)
            maker.height.equalTo(buttonH)
        }
        modelLabel.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(LSize.adapt(10))
            maker.centerY.equalToSuperview()
            maker.right.equalTo(pencilButton.snp.left).offset(-LSize.adapt(10))
        }
    }
    
    //MARK: 添加子视图
    func addsubviews(){
        self.addSubview(pencilButton)
        self.addSubview(eraseButton)
        self.addSubview(modelLabel)
    }
    
    fileprivate lazy var  pencilButton : UIButton = {
        let button = UIButton.init(type: .custom)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage.init(named: "huabi"), for: .normal)
        button.setImage(UIImage.init(named: "huabi_red"), for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: LSize.adapt(14))
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.red, for: .selected)
        button.setTitle("画笔", for: .normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0 , -buttonW/2+10 , -buttonH/2 , 0)
        button.imageEdgeInsets = UIEdgeInsetsMake( -buttonH/2 , 0 , 0 , -buttonW/2)
        button.addTarget(self, action: #selector(choicePencilModel(button:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var  eraseButton : UIButton = {
        let button = UIButton.init(type: .custom)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage.init(named: "erase"), for: .normal)
        button.setImage(UIImage.init(named: "erase_red"), for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: LSize.adapt(14))
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.red, for: .selected)
        button.titleEdgeInsets = UIEdgeInsetsMake(0 , -buttonW/2+10 , -buttonH/2 , 0)
        button.imageEdgeInsets = UIEdgeInsetsMake( -buttonH/2 , 0 , 0 , -buttonW/2-10)
        button.titleLabel?.font = UIFont.systemFont(ofSize: LSize.adapt(14))
        button.setTitle("橡皮擦", for: .normal)
        button.addTarget(self, action: #selector(choiceEraseModel(button:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var  modelLabel : UILabel = {
        let pradoView = UILabel.init()
        pradoView.textColor = UIColor.red
        pradoView.textAlignment = NSTextAlignment.center
        pradoView.font = UIFont.systemFont(ofSize: 16)
        return pradoView
    }()
    
}
