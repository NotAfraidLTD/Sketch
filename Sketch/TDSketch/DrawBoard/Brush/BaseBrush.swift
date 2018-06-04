//
//  BaseBrush.swift
//  Sketch
//
//  Created by 刘旦 on 2018/4/11.
//  Copyright © 2018年 YLT. All rights reserved.
//

import UIKit

// 绘图工具协议
protocol PaintbrushProtocol {
    
    // 表示是否是连续绘图
    func supportedContinuousDrawing() -> Bool
    
    // 基于Context的绘图
    func drawInContext(_ context: CGContext)
    
}

// 画笔基类
class BaseBrush : NSObject , PaintbrushProtocol{

    var beginPoint : CGPoint?
    
    var endPoint : CGPoint?
    
    var lastPoint : CGPoint?
    
    // 线的粗细
    var strokeWidth: CGFloat?
    
    // 表示是否是连续绘图
    func supportedContinuousDrawing() -> Bool{
        return false
    }
    
    // 基于Context的绘图
    func drawInContext(_ context: CGContext){
        assert(false, "must implements in subclass.")
    }
    
}


//MARK: 输入框
class InputBrush : BaseBrush {
    
}


//MARK: 画笔
class PencilBrush : BaseBrush {
    
    override func drawInContext(_ context: CGContext) {
        
        if let lastPoint = self.lastPoint {
            context.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            context.addLine(to: CGPoint(x: (endPoint?.x ?? 0), y: (endPoint?.y ?? 0)))
        } else {
            context.move(to: CGPoint(x: (beginPoint?.x ?? 0), y: ( beginPoint?.y ?? 0)))
            context.addLine(to: CGPoint(x: (endPoint?.x ?? 0), y: ( endPoint?.y ?? 0 )))
        }
    }
    
    override func supportedContinuousDrawing() -> Bool {
        return true
    }
}

//MARK: 橡皮擦
class EraserBrush : PencilBrush {
    override func drawInContext(_ context: CGContext) {
        context.setBlendMode(CGBlendMode.clear)
        super.drawInContext(context)
    }
}

//MARK: 高斯模糊
class GaussianBlurBrush : BaseBrush {
    override func drawInContext(_ context: CGContext) {
        
        if let lastPoint = self.lastPoint {
            context.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            context.addLine(to: CGPoint(x: (endPoint?.x ?? 0), y: (endPoint?.y ?? 0)))
        } else {
            context.move(to: CGPoint(x: (beginPoint?.x ?? 0), y: ( beginPoint?.y ?? 0)))
            context.addLine(to: CGPoint(x: (endPoint?.x ?? 0), y: ( endPoint?.y ?? 0 )))
        }
    }
    
    override func supportedContinuousDrawing() -> Bool {
        return true
    }
}

//MARK: 马赛克
class RectangleBrush : BaseBrush {
    override func drawInContext(_ context: CGContext) {
        
        if let lastPoint = self.lastPoint {
            context.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            context.addLine(to: CGPoint(x: (endPoint?.x ?? 0), y: (endPoint?.y ?? 0)))
        } else {
            context.move(to: CGPoint(x: (beginPoint?.x ?? 0), y: ( beginPoint?.y ?? 0)))
            context.addLine(to: CGPoint(x: (endPoint?.x ?? 0), y: ( endPoint?.y ?? 0 )))
        }
    }
    
    override func supportedContinuousDrawing() -> Bool {
        return true
    }
}
