//
//  UIImage + Extension.swift
//  Sketch
//
//  Created by 刘旦 on 2018/4/13.
//  Copyright © 2018年 YLT. All rights reserved.
//

import Foundation

extension UIImage {
    
    static func imageRotation( image : UIImage , orientation : UIImageOrientation) -> UIImage{
        
        var rotate = 0.0
        var rect : CGRect?
        var translateX = 0
        var translateY = 0
        var scaleX : CGFloat = 1.0
        var scaleY : CGFloat = 1.0
        switch (orientation) {
            case .left:
                rotate = .pi/2
                rect = CGRect.init(x: 0, y: 0, width: CGFloat(image.cgImage?.height ?? 0) , height: CGFloat(image.cgImage?.width ?? 0))
                translateX = 0
                translateY = -Int(rect?.size.width ?? 0)
                scaleY = (rect?.size.width ?? 0 )/(rect?.size.height ?? 1)
                scaleX = (rect?.size.height ?? 0)/(rect?.size.width ?? 1)
                break
            case .right:
                rotate = 3 * .pi/2
                rect = CGRect.init(x: 0, y: 0, width: CGFloat(image.cgImage?.height ?? 0) , height: CGFloat(image.cgImage?.width ?? 0))
                translateX = -Int(rect?.size.height ?? 0)
                translateY = 0
                scaleY = (rect?.size.width ?? 0 )/(rect?.size.height ?? 1)
                scaleX = (rect?.size.height ?? 0)/(rect?.size.width ?? 1)
                break
            case .down:
                rotate = .pi/2
                rect = CGRect.init(x: 0, y: 0, width: CGFloat(image.cgImage?.width ?? 0) , height: CGFloat(image.cgImage?.height ?? 0))
                translateX = -Int(rect?.size.width ?? 0)
                translateY = -Int(rect?.size.height ?? 0)
                break
            default:
                rotate = 0.0
                rect = CGRect.init(x: 0, y: 0, width: CGFloat(image.cgImage?.width ?? 0) , height: CGFloat(image.cgImage?.height ?? 0))
                translateX = 0
                translateY = 0
                break
        }
        var newIamge  = image
        if let size = rect?.size{
            UIGraphicsBeginImageContext(size)
            if let context = UIGraphicsGetCurrentContext(){
                context.translateBy(x: 0.0, y: size.height)
                context.scaleBy(x: 1.0, y: -1.0)
                context.rotate(by: CGFloat(rotate))
                context.translateBy(x: CGFloat(translateX), y:  CGFloat(translateY))
                context.scaleBy(x: scaleX, y: scaleY)
                context.draw(image.cgImage!, in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
                newIamge = UIGraphicsGetImageFromCurrentImageContext()!
            }
        }
        return newIamge
    }
    
    static func scaleImage(image: UIImage) -> UIImage {
        let boardH = KScreenHeight-LSize.adapt(105)-64
        // 图片大小
        UIGraphicsBeginImageContext(CGSize(width:boardH/KScreenHeight*KScreenWidth,height:boardH))
        
        image.draw(in: CGRect(x: 0, y: 0, width:boardH/KScreenHeight*KScreenWidth, height: boardH))
       
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //对图片包得大小进行压缩
        let imageData =  UIImagePNGRepresentation(scaledImage!)
        let newImage = UIImage.init(data: imageData!)
        return newImage!
    }
}

