//
//  AppConfig.swift
//  CloudscmSwift
//
//  Created by RexYoung on 2017/2/21.
//  Copyright © 2017年 RexYoung. All rights reserved.
//

import UIKit

/**
 *  比例计算
 */
class LSize: NSObject {
    class func adapt(_ size: CGFloat) -> CGFloat {
        return KScreenWidth > 325.0 ? size : size/375*320
    }
}

// 屏幕宽度
let KScreenHeight = UIScreen.main.bounds.height
// 屏幕高度
let KScreenWidth = UIScreen.main.bounds.width
//屏幕比例
let kScale = UIScreen.main.scale
//导航栏高度
let KNavgationBarHeight: CGFloat = 44.0
//tabbar高度
let KTabBarHeight: CGFloat = 49.0
//图片处理宽度自适应链接
let kOSS = "?x-oss-process=image/resize,w_"


//MARK: - RGBA颜色
var RGBAColor: (CGFloat, CGFloat, CGFloat, CGFloat) -> UIColor = {red, green, blue, alpha in
    return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha);
}

var mainColor: UIColor {
    return RGBAColor(212.0,35.0,122.0,1.0)
}

// MARK:- 设置圆角
func HDViewsBorder(_ view:UIView, borderWidth:CGFloat, borderColor:UIColor,cornerRadius:CGFloat){
    view.layer.borderWidth = borderWidth;
    view.layer.borderColor = borderColor.cgColor
    view.layer.cornerRadius = cornerRadius
    view.layer.masksToBounds = true
}

func transferStringToColor(hexString:String, alpha:CGFloat) -> UIColor {
    
    var color = UIColor.red
    var cStr : String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
    if cStr.hasPrefix("#") {
        let index = cStr.index(after: cStr.startIndex)
        cStr = cStr.substring(from: index)
    }
    if cStr.count != 6 {
        return UIColor.black
    }
    
    let rRange = cStr.startIndex ..< cStr.index(cStr.startIndex, offsetBy: 2)
    let rStr = cStr.substring(with: rRange)
    
    let gRange = cStr.index(cStr.startIndex, offsetBy: 2) ..< cStr.index(cStr.startIndex, offsetBy: 4)
    let gStr = cStr.substring(with: gRange)
    
    let bIndex = cStr.index(cStr.endIndex, offsetBy: -2)
    let bStr = cStr.substring(from: bIndex)
    
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    Scanner(string: rStr).scanHexInt32(&r)
    Scanner(string: gStr).scanHexInt32(&g)
    Scanner(string: bStr).scanHexInt32(&b)
    
    color = UIColor.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    
    return color
}



