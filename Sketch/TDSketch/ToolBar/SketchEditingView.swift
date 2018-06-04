//
//  SketchEditingView.swift
//  Sketch
//
//  Created by 刘旦 on 2018/4/11.
//  Copyright © 2018年 YLT. All rights reserved.
//

import UIKit

protocol SketchEditingDelegate : class {
    
    // 选择编辑颜色
    func sketchchoiceEditColor()
    
    // 滑动值变化
    func sketchEditingSliderChangeValue(value : Float)
    
    // 撤销操作
    func sketchchoiceEditBackout()
    
    // 返回操作
    func sketchchoiceEditReturn()
    
    // 重置操作
    func sketchchoiceEditReset()
    
}

// 编辑栏  (选择颜色 撤回 返回 重置)

class SketchEditingView: UIView {
    
    weak var delegate : SketchEditingDelegate?
    
    var backoutIsEnabled : Bool? {
        didSet{
            self.backoutButton.isEnabled = backoutIsEnabled ?? false
        }
    }
    
    var returnIsEnabled : Bool? {
        didSet{
            self.returnButton.isEnabled = returnIsEnabled ?? false
        }
    }
    
    var resetIsEnabled : Bool? {
        didSet{
            self.resetButton.isEnabled = resetIsEnabled ?? false
        }
    }
    
    // 选择好的颜色图
    var colorImage : UIImage?{
        didSet{
            if let newImage = colorImage{
                self.colorImageView.image = newImage
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
    
    //MARK : 滑动值变
    @objc func sliderAction(sender : Any){
        self.delegate?.sketchEditingSliderChangeValue(value: self.slider.value)
    }
    
    //MARK : 撤销按钮
    @objc func backoutAction(button : UIButton){
        self.delegate?.sketchchoiceEditBackout()
    }
    
    //MARK : 返回按钮
    @objc func returnAction(button : UIButton){
        self.delegate?.sketchchoiceEditReturn()
    }
    
    //MARK : 重置按钮
    @objc func resetAction(button : UIButton){
        self.delegate?.sketchchoiceEditReset()
    }
    
    //MARK : 点击选择编辑颜色
    @objc func choiceEditColor(sender : UIView){
       self.delegate?.sketchchoiceEditColor()
    }
    
    //MARK : 添加子控件
    func addsubviews(){
        self.addSubview(colorImageView)
        self.addSubview(slider)
        self.addSubview(backoutButton)
        self.addSubview(resetButton)
        self.addSubview(returnButton)
    }
    //MARK : 添加约束
    func addconstraints(){
        colorImageView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(LSize.adapt(20))
            maker.width.height.equalTo(LSize.adapt(32))
            maker.centerY.equalToSuperview()
        }
        resetButton.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(-LSize.adapt(17))
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(30)
        }
        returnButton.snp.makeConstraints { (maker) in
            maker.right.equalTo(resetButton.snp.left).offset(-LSize.adapt(17))
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(30)
        }
        backoutButton.snp.makeConstraints { (maker) in
            maker.right.equalTo(returnButton.snp.left).offset(-LSize.adapt(17))
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(30)
        }
        slider.snp.makeConstraints { (maker) in
            maker.left.equalTo(colorImageView.snp.right).offset(LSize.adapt(10))
            maker.centerY.equalToSuperview()
            maker.right.equalTo(backoutButton.snp.left).offset(-LSize.adapt(10))
        }
    }
    
    fileprivate lazy var  colorImageView : UIImageView = {
        let pradoView = UIImageView.init()
        pradoView.layer.cornerRadius = 5
        pradoView.layer.masksToBounds = true
        pradoView.backgroundColor = UIColor.blue
        pradoView.isUserInteractionEnabled = true
        pradoView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(choiceEditColor(sender:))))
        return pradoView
    }()
    
    fileprivate lazy var  slider : UISlider = {
        let sliderView = UISlider()
        sliderView.value = 0.5
        sliderView.maximumValue = 1
        sliderView.minimumValue = 0
        sliderView.thumbTintColor = UIColor.orange
        sliderView.minimumTrackTintColor = UIColor.orange
        sliderView.addTarget(self, action: #selector(sliderAction(sender:)), for: .valueChanged)
        return sliderView
    }()
    
    fileprivate lazy var  backoutButton : UIButton = {
        let pradoView = UIButton.init(type: .custom)
        pradoView.setImage(UIImage.init(named: "back_left"), for: .normal)
        pradoView.setImage(UIImage.init(named: "back_left_gray"), for: .selected)
        pradoView.addTarget(self, action: #selector(backoutAction(button:)), for: .touchUpInside)
        return pradoView
    }()
    
    fileprivate lazy var  returnButton : UIButton = {
        let pradoView = UIButton.init(type: .custom)
        pradoView.setImage(UIImage.init(named: "back_right"), for: .normal)
        pradoView.setImage(UIImage.init(named: "back_right_gray"), for: .selected)
        pradoView.addTarget(self, action: #selector(returnAction(button:)), for: .touchUpInside)
        return pradoView
    }()
    
    fileprivate lazy var  resetButton : UIButton = {
        let pradoView = UIButton.init(type: .custom)
        pradoView.setImage(UIImage.init(named: "resetImage"), for: .normal)
        pradoView.addTarget(self, action: #selector(resetAction(button:)), for: .touchUpInside)
        return pradoView
    }()
}
