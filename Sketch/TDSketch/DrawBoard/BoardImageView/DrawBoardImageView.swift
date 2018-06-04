//
//  DrawBoardImageView.swift
//  Sketch
//
//  Created by 刘旦 on 2018/4/11.
//  Copyright © 2018年 YLT. All rights reserved.
//

import UIKit

protocol DrawBoardImageViewDelegate : class {
    
    // 需要输入新内容
    func needInputContent(currentText : String )
    
}


// 模式枚举
enum SketchModel{
    
    case pencil
    case erase
    case input
    case rectangle
    case gaussianBlur
    
}

// 绘制进度
enum DrawingState {
    case began, moved, ended
}


// 开始编辑，返回按钮可以点击
typealias beginDrawClouse = () -> ()

// 当撤销到第一张图片，返回按钮不可点击
typealias undoUnableActionClouse = () -> ()

// 前进到最后一张图片,重置按钮不可点击
typealias redoUnableActionClouse = () -> ()


class DrawBoardImageView: UIImageView {
    
    weak var delegate : DrawBoardImageViewDelegate?
    
    var beginDraw: beginDrawClouse?
    var unableDraw: undoUnableActionClouse?
    var reableDraw: redoUnableActionClouse?
    // 绘图状态
    fileprivate var drawingState: DrawingState!
    // 编辑颜色
    var strokeColor : UIColor = UIColor.black
    // 编辑线条宽度
    var strokeWidth : CGFloat = 3
    // 文本编辑状态,文本的字体大小
    var textFont: UIFont = UIFont.systemFont(ofSize: 14)
    // 编辑类指针
    var brush : BaseBrush?{
        didSet{
            if (brush == nil){
                self.eraserImage.isHidden = true
            }
        }
    }
    // 展示文字的label
    var lableArray = Array<UILabel>()
    // 当前编辑的label
    var currentLable : UILabel?
    // 马赛克图片
    var masicImage : UIImage?
    //保存当前的图形
    fileprivate var realImage : UIImage?
    // 记录当前用户选择的label位置
    var currentLabelOrigin: CGPoint?
    // 模式图案
    var patternImage : UIImage?{
        didSet{
            if let image = patternImage{
                self.strokeColor = UIColor(patternImage: image)
            }
        }
    }
    // 高斯模糊
    var strokeGauussianColor: UIColor = UIColor.clear
    // 当前编辑的图片
    var currentImage : UIImage? {
        didSet{
            self.realImage = currentImage
            if let newImage = currentImage{
                self.scriptManager.addImage(newImage)
                self.backgroundColor = UIColor.init(patternImage: UIImage.scaleImage(image: newImage))
            }
            let image = CTImageEditUtil.getScaleImage(with: currentImage)
            let realimage = CTImageEditUtil.getImageWithOldImage(image)
            self.strokeGauussianColor = UIColor(patternImage: CTImageEditUtil.filter(forGaussianBlur: realimage))
        }
    }
    
    // 用于记录文本输入后的image
    var textImageFlag: UIImage?

    // 创建编辑模式
    var sketchModel : SketchModel?{
        didSet{
            if let model = sketchModel{
                switch model {
                case SketchModel.pencil:
                    self.brush = PencilBrush()
                    break
                case SketchModel.erase:
                    self.brush = EraserBrush()
                    break
                case SketchModel.gaussianBlur:
                    self.brush = GaussianBlurBrush()
                    break
                case SketchModel.input:
                    self.brush = InputBrush()
                    break
                case SketchModel.rectangle:
                    self.brush = RectangleBrush()
                    break
                }
            }
        }
    }
    
    var canUndo: Bool {
        get {
            return self.scriptManager.canUndo
        }
    }
    
    var canRedo: Bool {
        get {
            return self.scriptManager.canRedo
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:  touchesBegan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.lastPoint = nil
            
            brush.beginPoint = touches.first!.location(in: self)
            brush.endPoint = brush.beginPoint
            
            self.drawingState = .began
            
            // 如果是橡皮擦，展示橡皮擦的效果
            if self.brush?.classForKeyedArchiver == EraserBrush.classForCoder() {
                self.eraserImage.isHidden = false
                let imageW = self.strokeWidth*3
                self.eraserImage.frame = CGRect(origin: (brush.beginPoint ?? CGPoint.init(x: 0, y: 0) ), size: CGSize(width: imageW, height: imageW))
                self.eraserImage.layer.cornerRadius = imageW*0.5
                self.eraserImage.layer.masksToBounds = true
                self.eraserImage.backgroundColor = mainColor
            }
            
            // 如果是文本输入就展示文本，其他的是绘图
            if self.brush?.classForKeyedArchiver == InputBrush.classForCoder()  {
                self.drawingText()
            } else {
                // 触摸点没有在文本上
                if self.adjustBeginPoint() == true {
                    self.drawingImage()
                    if beginDraw != nil {
                        self.beginDraw!()
                    }
                }
            }
        }
    }
    
    // MARK:  touchesMoved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = touches.first!.location(in: self)
            
            self.drawingState = .moved
            
            // 如果是橡皮擦，展示橡皮擦的效果
            if self.brush?.classForKeyedArchiver == EraserBrush.classForCoder() {
                let imageW = self.strokeWidth*5
                self.eraserImage.frame = CGRect(origin: (brush.endPoint ?? CGPoint.init(x: 0, y: 0)), size: CGSize(width: imageW, height: imageW))
            }
            
            if self.brush?.classForKeyedArchiver == InputBrush.classForCoder()  {
            } else {
                // 触摸点没有在文本上
                if self.adjustBeginPoint() == true {
                    self.drawingImage()
                }
            }
        }
    }
    
    // MARK:  touchesCancelled
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = nil
        }
    }
    
    // MARK:  touchesEnded
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = touches.first!.location(in: self)
            
            self.drawingState = .ended
            
            // 如果是橡皮擦，展示橡皮擦的效果
            if self.brush?.classForKeyedArchiver == EraserBrush.classForCoder() {
                self.eraserImage.isHidden = true
            }
            if self.brush?.classForKeyedArchiver == InputBrush.classForCoder()  {
            } else {
                // 触摸点没有在文本上
                if self.adjustBeginPoint() == true {
                    self.drawingImage()
                }
            }
        }
    }
  
    //MARK: - 写文字
    fileprivate func drawingText() {
        
        if self.adjustBeginPoint() == true {
            self.currentLable = nil
            self.currentLabelOrigin = nil
        }
        
        // 说明是要画文字
        if self.currentLable == nil {
            let lable = UILabel.init(frame: CGRect(x: (self.brush?.beginPoint?.x ?? 0), y: (self.brush?.beginPoint?.y ?? 0), width: KScreenWidth-30, height: 0))
            lable.numberOfLines = 0
            lable.font = textFont
            lable.isUserInteractionEnabled = true
            lable.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(clickContentLable(tap:))))
            lable.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(contentLablePan(pan:))))
            self.delegate?.needInputContent(currentText: "")
            self.addSubview(lable)
            self.currentLable = lable
            self.lableArray.append(lable)
        } else {  // 说明是要编辑某一个label
            
        }
    }
    
    // MARK: 点击文本
    @objc func clickContentLable(tap:UITapGestureRecognizer) {
        self.delegate?.needInputContent(currentText: (self.currentLable?.text ?? ""))
    }
    // MARK:  移动文本
    @objc func contentLablePan(pan:UIPanGestureRecognizer) {
        //得到拖的过程中的xy坐标
        let point : CGPoint = pan.translation(in: self.currentLable)
        if let transform = self.currentLable?.transform.translatedBy(x: point.x, y: point.y){
            self.currentLable?.transform = transform
        }
        pan.setTranslation(CGPoint(x:0,y:0), in: self.currentLable)
        self.currentLabelOrigin = self.currentLable?.frame.origin
    }
    
    //MARK: 判断触摸点是否在文本输入框上面
    func adjustBeginPoint() -> Bool{
        var flag = 0
        // 遍历数组，判断触摸点是否在绘制文字所在的文本框内
        for label in lableArray {
            if label.frame.contains((self.brush?.beginPoint)!){
                self.currentLable = label
                self.currentLabelOrigin = self.currentLable?.frame.origin
                flag = flag + 1
            }
        }
        
        return flag == 0   // true  不在文本上
    }
    
    // 图稿管理对象
    fileprivate lazy var  scriptManager : ManuscriptManager = {
        let manager = ManuscriptManager.init()
        return manager
    }()
    
    // 橡皮擦效果图片
    lazy var eraserImage: UIImageView = {
        let img = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.addSubview(img)
        return img
    }()
    
}

// MARK : 绘制图片
extension DrawBoardImageView {
    
    // MARK: - 绘制图片
    fileprivate func drawingImage() {
        if let brush = self.brush {
            
            // 1.开启一个新的ImageContext，为保存每次的绘图状态作准备。
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
            
            // 2.初始化context，进行基本设置（画笔宽度、画笔颜色、画笔的圆润度等）。
            let context = UIGraphicsGetCurrentContext()
            
            UIColor.clear.setFill()
            UIRectFill(self.bounds)
            
            context?.setLineCap(CGLineCap.round)
            context?.setLineWidth(self.strokeWidth)
            context?.setStrokeColor(self.strokeColor.cgColor)
            
            if self.brush?.classForKeyedArchiver == GaussianBlurBrush.classForCoder()  {
                context?.setLineWidth(self.strokeWidth*10)
                context?.setStrokeColor(self.strokeColor.cgColor)
            }
            
            if self.brush?.classForKeyedArchiver == RectangleBrush.classForCoder()  {
                // 马赛克
                context?.setLineWidth(30)
                if let masicimage = self.masicImage{
                    context?.setStrokeColor(UIColor(patternImage: masicimage).cgColor)
                }else{
                    context?.setStrokeColor(UIColor.gray.cgColor)
                }
            }
            
            // 3.把之前保存的图片绘制进context中。
            if let realimage = self.realImage {
                realimage.draw(in: self.bounds)
            }
            
            // 4.设置brush的基本属性，以便子类更方便的绘图；调用具体的绘图方法，并最终添加到context中。
            brush.strokeWidth = self.strokeWidth
            brush.drawInContext(context!)
            context?.strokePath()
            
            // 5.从当前的context中，得到Image，如果是ended状态或者需要支持连续不断的绘图，则将Image保存到realImage中。
            let previewImage = UIGraphicsGetImageFromCurrentImageContext()
            if self.drawingState == .ended || brush.supportedContinuousDrawing() {
                self.realImage = previewImage
            }
            UIGraphicsEndImageContext()
            // 6.实时显示当前的绘制状态，并记录绘制的最后一个点
            self.image = previewImage
            
            // 用 Ended 事件代替原先的 Began 事件
            if self.drawingState == .ended {
                // 如果是第一次绘制,同时让前进按钮处于不可点击状态
                if self.scriptManager.index == -1 {
                    if self.reableDraw != nil {
                        self.reableDraw!()
                    }
                }
                self.scriptManager.addImage(self.image!)
            }
            
            brush.lastPoint = brush.endPoint
        }
    }
    
    //MARK: - 将文本与图片融合
    fileprivate func DrawTextAndImage(){
        //开启图片上下文
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        //图形重绘
        self.draw(self.bounds)
        for lable in self.lableArray {
            //水印文字大小
            let text = NSString(string: lable.text ?? "")
            //绘制文字 ,文字显示的位置，要在textview的适当位置
            text.draw(in: lable.frame, withAttributes: [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue):lable.textColor,NSAttributedStringKey.font:self.textFont,NSAttributedStringKey.backgroundColor:UIColor.clear])
        }
        //从当前上下文获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        self.textImageFlag = image
    }
    
}

// MARK : 数据源处理 返回重置
extension DrawBoardImageView {
    
    //MARK: - 返回画板上的图片，用于保存
    func takeImage() -> UIImage {
        // 保存之前先把文字和图片绘制到一起
        if self.lableArray.count > 0 {
            self.DrawTextAndImage()
        }
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        self.backgroundColor?.setFill()
        UIRectFill(self.bounds)
        
        if self.lableArray.count > 0 {
            self.textImageFlag?.draw(in: self.bounds)
        } else {
            self.image?.draw(in: self.bounds)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // 是否可以撤销
    func canBack() -> Bool {
        return self.canUndo
    }
    
    // 是否可以前进
    func canForward() -> Bool {
        return self.canRedo
    }
    
    // 撤销
    func undo() {
        if self.canUndo == false {
            return
        }
        self.image = self.scriptManager.imageForUndo()
        self.realImage = self.image
        
        // 已经撤销到第一张图片
        if self.scriptManager.index == -1 {
            if self.unableDraw != nil {
                self.unableDraw!()
            }
        }
    }
    // 前进
    func redo() {
        if self.canRedo == false {
            return
        }
        self.image = self.scriptManager.imageForRedo()
        self.realImage = self.image
        
        // 已经撤前进到最后一张图片
        if self.scriptManager.index == self.scriptManager.imagesArray.count-1 {
            if self.reableDraw != nil {
                self.reableDraw!()
            }
        }
    }
    // 还原
    func retureAction() {
        self.image = self.currentImage
        self.realImage = self.image
    }
}

// MARK : BoardInputViewDelegate
extension DrawBoardImageView : BoardInputViewDelegate{
    
    // 输入完成
    func finishInputRemind(remindString : String , inputView : BoardInputView){
        inputView.textView.endEditing(true)
        self.currentLable?.text = inputView.textView.text
        self.currentLable?.frame.size.width = KScreenWidth-30
        self.currentLable?.textColor = inputView.textView.textColor
        self.currentLable?.sizeToFit()
        if self.currentLabelOrigin != nil {
            self.currentLable?.frame.origin = self.currentLabelOrigin ?? CGPoint.init(x: KScreenWidth/2, y: 200)
        }
    }
    
}


