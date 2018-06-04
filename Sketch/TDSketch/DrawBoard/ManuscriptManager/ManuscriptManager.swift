//
//  ManuscriptManager.swift
//  Sketch
//
//  Created by 刘旦 on 2018/4/13.
//  Copyright © 2018年 YLT. All rights reserved.
//

import UIKit

class ManuscriptManager: NSObject {

    // 稿图数组
    var imagesArray = Array<UIImage>.init()
    
    // 当前稿图索引
    var index = -1
    
    // 是否能返回
    var canUndo: Bool {
        get {
            return index > 0
        }
    }
    
    // 能否重做
    var canRedo: Bool {
        get {
            return index < imagesArray.count-1
        }
    }
    
    // MARK: 添加图片
    func addImage(_ image: UIImage) {
        // 添加之前先判断是不是还原到最初的状态
        if index == -1 {
            imagesArray.removeAll()
        }
        
        if let imgData = UIImagePNGRepresentation(image) , let img = UIImage.init(data: imgData){
            imagesArray.append(img)
            index = imagesArray.count - 1
        }
    }
    
    // MARK: 上一步图片
    func imageForUndo() -> UIImage? {
        index = index-1
        if index>=0 {
            if let imgData = UIImagePNGRepresentation(imagesArray[index]) , let img = UIImage.init(data: imgData){
                return img
            }else{
                return nil
            }
        } else {
            index = 0
            return nil
        }
    }
    
    // MARK: 还原图片
    func imageForRedo() -> UIImage? {
        index = index+1
        if index <= imagesArray.count-1 {
            if let imgData = UIImagePNGRepresentation(imagesArray[index]) , let img = UIImage.init(data: imgData){
                return img
            }else{
                return nil
            }
        } else {
            index = imagesArray.count-1 > 0 ? imagesArray.count-1 : 0
            if index != 0 , let imgData = UIImagePNGRepresentation(imagesArray[index]) , let img = UIImage.init(data: imgData){
                return img
            }else{
                return nil
            }
        }
    }
    
}
