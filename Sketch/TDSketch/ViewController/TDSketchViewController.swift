//
//  TDSketchViewController.swift
//  Sketch
//
//  Created by 刘旦 on 2018/4/11.
//  Copyright © 2018年 YLT. All rights reserved.
//

import UIKit
import SnapKit

class TDSketchViewController : UIViewController {
    
    // 编辑的图片
    var editImage : UIImage?{
        didSet{
            if let image = editImage{
                var eimge = image
                if (image.cgImage?.width ?? 0) > (image.cgImage?.height ?? 0){
                   eimge = UIImage.imageRotation(image: image, orientation: .right)
                }
                self.drawBoardImageView.currentImage = eimge
                self.drawBoardImageView.backgroundColor = UIColor.init(patternImage: UIImage.scaleImage(image: eimge))
                self.drawBoardImageView.masicImage = UIImage.trans(toMosaicImage: eimge, blockLevel: 20)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNotificationCenter()
        self.addsubviews()
        drawBoardImageView.beginDraw = {[weak self]() in
            self?.editingView.backoutIsEnabled = true
        }
        drawBoardImageView.unableDraw = {[weak self]() in
            self?.editingView.backoutIsEnabled = false
        }
        drawBoardImageView.reableDraw = {[weak self]() in
            self?.editingView.resetIsEnabled = true
        }
        self.setNavigationButtonItems()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setNavigationButtonItems(){
        let btnDownLoad = UIBarButtonItem.init(image: UIImage(named:"downLoad"), style: .done, target: self, action: #selector(TDSketchViewController.clickLoadBtn))
        let btnEditor = UIBarButtonItem.init(image: UIImage(named:"editor"), style: .done, target: self, action: #selector(TDSketchViewController.clickEditorBtn))
        self.navigationItem.rightBarButtonItems = [btnDownLoad,btnEditor]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.addcontractions()
    }
    
    //MARK: - 编辑,文本输入
    @objc func clickEditorBtn() {
        self.modelView.modeltext = "文本输入"
        self.scrollview.isScrollEnabled = false
        self.drawBoardImageView.sketchModel = .input
    }
    
    //MARK: - 下载图片
    @objc func clickLoadBtn(){
        let alertController = UIAlertController(title: "提示", message: "您确定要保存整个图片到相册吗？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: {
            action in
            
            UIImageWriteToSavedPhotosAlbum(self.drawBoardImageView.takeImage(), self, #selector(TDSketchViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // 保存图片的结果
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if error != nil {
           print("保存失败")
        } else {
           print("保存成功")
        }
    }
    
    //MARK: 显示颜色选项栏
    func showColorView(){
        UIView.animate(withDuration: 0.3) {
            if self.editingView.frame.origin.y <= self.colourView.frame.origin.y{
                self.colourView.frame.origin.y = self.colourView.frame.origin.y - LSize.adapt(50)
            }
        }
    }
    
    //MARK: 隐藏颜色选项栏
    func dismissColorView(){
        UIView.animate(withDuration: 0.3) {
            if self.editingView.frame.origin.y > self.colourView.frame.origin.y{
                self.colourView.frame.origin.y = self.colourView.frame.origin.y + LSize.adapt(50)
            }
        }
    }
    
    // 确认编辑模式
    func confirmEditBrushType(image : UIImage){
        // 先判断是不是文本，如果是文本，直接设置文本的颜色
        if self.drawBoardImageView.brush?.classForKeyedArchiver == InputBrush.classForCoder() {
            return
        }
        if image == UIImage(named: "rectangle") {
            self.drawBoardImageView.sketchModel = .rectangle
        } else if image == UIImage(named: "gaussianBlur") { 
            self.drawBoardImageView.sketchModel = .gaussianBlur
        } else {
            self.drawBoardImageView.sketchModel = .pencil
        }
    }
    
    //MARK: 添加子视图
    func addsubviews(){
        self.view.addSubview(scrollview)
        self.view.addSubview(modelView)
        self.view.addSubview(colourView)
        self.view.addSubview(editingView)
        self.scrollview.addSubview(drawBoardImageView)
        self.view.addSubview(drawIputView)
    }
    
    func addcontractions(){
        self.modelView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.height.equalTo(LSize.adapt(55))
        }
        self.editingView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(modelView.snp.top)
            maker.height.equalTo(LSize.adapt(50))
        }
        self.colourView.snp.makeConstraints { (maker) in
            maker.top.equalTo(editingView.snp.top)
            maker.left.equalTo(editingView.snp.left)
            maker.width.equalTo(editingView.snp.width)
            maker.height.equalTo(editingView.snp.height)
        }
        self.scrollview.snp.makeConstraints { (maker) in
            maker.top.equalTo(64)
            maker.left.equalToSuperview()
            maker.width.equalTo(KScreenWidth)
            maker.bottom.equalTo(editingView.snp.top)
        }
        self.drawBoardImageView.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(0)
            maker.width.equalTo((KScreenHeight-LSize.adapt(105)-64)/KScreenHeight*KScreenWidth)
            maker.height.equalTo(KScreenHeight-LSize.adapt(105)-64)
        }
    }
    
    // 绘画区域
    fileprivate lazy var  drawBoardImageView  : DrawBoardImageView = {
        let pradoView = DrawBoardImageView.init(frame: CGRect.zero)
        pradoView.contentMode = .redraw
        pradoView.delegate = self
        pradoView.isUserInteractionEnabled = true
        return pradoView
    }()
    
    // 底部绘画模式栏
    fileprivate lazy var  modelView : SketchModelView = {
        let pradoView = SketchModelView.init()
        pradoView.delegate = self
        pradoView.backgroundColor = UIColor.white
        return pradoView
    }()
    
    // 编辑栏 
    fileprivate lazy var  editingView : SketchEditingView = {
        let pradoView = SketchEditingView.init()
        pradoView.colorImage = UIImage.init(name: "clr_black")
        pradoView.backgroundColor = transferStringToColor(hexString:"#f2f2f2", alpha: 1.0)
        pradoView.delegate = self
        return pradoView
    }()
    
    // 选择编辑颜色栏
    fileprivate lazy var  colourView : SketchColourView = {
        let pradoView = SketchColourView.init(frame: CGRect.zero, images: ["rectangle","gaussianBlur","clr_red","clr_orange","clr_blue","clr_green","clr_purple","clr_black"])
        pradoView.backgroundColor = UIColor.gray
        pradoView.clickEditingColor = { [weak self] (image : UIImage) in
            self?.editingView.colorImage = image
            self?.dismissColorView()
            self?.confirmEditBrushType(image: image)
            self?.drawBoardImageView.patternImage = image
            self?.modelView.pencilSelected = true
            self?.scrollview.isScrollEnabled = false
        }
        return pradoView
    }()
    
    fileprivate lazy var  scrollview : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 10
        return scrollView
    }()
    
    lazy var  drawIputView : BoardInputView = {
        let textView = BoardInputView.init(frame: CGRect(x: 0, y: KScreenHeight, width: KScreenWidth, height: 10+24+10+0.5+40))
        textView.delegate = self.drawBoardImageView
        return textView
    }()

}


// MARK : UIScrollViewDelegate
extension TDSketchViewController : UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return drawBoardImageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        drawBoardImageView.brush = nil
        self.modelView.modelreload = true
        self.scrollview.isScrollEnabled = true
    }
}


// MARK : SketchModelDelegate
extension TDSketchViewController : SketchModelDelegate{
    
    // 切换编辑模式
    func choiceSketchModel(model : SketchModel ,isChoice : Bool){
        if isChoice{
            self.scrollview.isScrollEnabled = false
            drawBoardImageView.sketchModel = model
        }else{
            drawBoardImageView.brush = nil
        }
    }
}

// MARK : DrawBoardImageViewDelegate
extension TDSketchViewController : DrawBoardImageViewDelegate{
    // 需要输入新内容
    func needInputContent(currentText : String ){
        self.drawIputView.textView.text = currentText
        self.drawIputView.textView.becomeFirstResponder()
    }
}

// MARK : SketchEditingDelegate
extension TDSketchViewController : SketchEditingDelegate{
    
    // 选择编辑颜色
    func sketchchoiceEditColor(){
        self.showColorView()
    }
    
    // 滑动值变化
    func sketchEditingSliderChangeValue(value : Float){
        drawBoardImageView.strokeWidth = CGFloat(value*15)
    }
    
    // 撤销操作
    func sketchchoiceEditBackout(){
        if self.drawBoardImageView.canBack() {
            self.editingView.backoutIsEnabled = true
            self.editingView.returnIsEnabled = true
            drawBoardImageView.undo()
        } else {
            self.editingView.backoutIsEnabled = false
        }
    }
    
    // 返回操作
    func sketchchoiceEditReturn(){
        if self.drawBoardImageView.canForward() {
            self.editingView.backoutIsEnabled = true
            self.editingView.returnIsEnabled = true
            drawBoardImageView.redo()
        } else {
            self.editingView.returnIsEnabled = false
        }
    }
    
    // 重置操作
    func sketchchoiceEditReset(){
        let alertController = UIAlertController(title: "提示",message: "您确定要还原图片吗？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: {
            action in
            self.drawBoardImageView.retureAction()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension TDSketchViewController {
    
    // MARK : addNotificationCenter
    func addNotificationCenter() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    // MARK : 键盘的出现
    @objc func keyBoardWillShow(_ notification: Notification){
        //获取userInfo
        let kbInfo = notification.userInfo
        //获取键盘的size
        let kbRect = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //键盘弹出的时间
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        //界面偏移动画
        UIView.animate(withDuration: duration) {
            self.drawIputView.frame.origin.y = KScreenHeight-kbRect.size.height-self.drawIputView.frame.size.height
        }
    }
    
    // MARK : 键盘的隐藏
    @objc func keyBoardWillHide(_ notification: Notification){
        let kbInfo = notification.userInfo
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.drawIputView.frame.origin.y = KScreenHeight
        }
    }
    
}

