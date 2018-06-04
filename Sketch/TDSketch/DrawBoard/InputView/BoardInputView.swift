//
//  BoardInputView.swift
//  Sketch
//
//  Created by 刘旦 on 2018/4/13.
//  Copyright © 2018年 YLT. All rights reserved.
//

import UIKit

protocol BoardInputViewDelegate {
    
    // 输入完成
    func finishInputRemind(remindString : String , inputView : BoardInputView)
    
}


class BoardInputView: UIView {
    
    // 底部颜色选择的高度
    let bottomViewH: CGFloat = 40
    // 字体的大小
    let textF: CGFloat = 20
    // textView的初始化高度 间距+20字体高+间距
    let textViewInitH: CGFloat = 10+24+10
    
    var delegate : BoardInputViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0, alpha: 0.9)
        textView.inputView = nil
        textView.inputAccessoryView = nil
        self.addSubview(textView)
        self.addSubview(colourView)
        // 颜色
        colourView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(self.bottomViewH)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 选择编辑颜色栏
    fileprivate lazy var  colourView : SketchColourView = {
        let pradoView = SketchColourView.init(frame: CGRect.zero, images: ["clr_red","clr_orange","clr_blue","clr_green","clr_purple","clr_black"])
        pradoView.backgroundColor = UIColor.gray
        pradoView.clickEditingColor = { [weak self] (image : UIImage) in
            self?.textView.textColor = UIColor(patternImage: image)
        }
        return pradoView
    }()
    
    lazy var textView: UITextField = {
        let textView = UITextField.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: self.textViewInitH))
        textView.textColor = UIColor.black
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: self.textF)
        textView.returnKeyType = .done
        return textView
    }()
    
}

extension BoardInputView : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textView.becomeFirstResponder()
        self.delegate?.finishInputRemind(remindString: textField.text ?? "", inputView: self)
        return true
    }
    
}
