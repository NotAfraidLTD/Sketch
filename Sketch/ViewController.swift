//
//  ViewController.swift
//  Sketch
//
//  Created by 刘旦 on 2018/4/11.
//  Copyright © 2018年 YLT. All rights reserved.
//

import UIKit
import TZImagePickerController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(sketchButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func pushSketchViewController(_ button : UIButton){
        
        // 相册多选
        let imagePicker = TZImagePickerController(maxImagesCount: 1, columnNumber: 4, delegate: self)
        self.present(imagePicker!, animated: true, completion: nil)
        
    }

    fileprivate lazy var  sketchButton : UIButton = {
        let button = UIButton.init(type: .custom)
        button.frame = CGRect.init(x: (KScreenWidth-120)/2, y: (KScreenHeight-30)/2, width: 120, height: 30)
        button.setTitle("SKETCH", for: .normal)
        button.backgroundColor = UIColor.blue
        button.addTarget(self, action:#selector(pushSketchViewController(_:)) , for: .touchUpInside)
        return button
    }()
    
}

//MARK:  批量选取图片
extension ViewController : TZImagePickerControllerDelegate{
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable : Any]]!) {
        let viewController = TDSketchViewController()
        viewController.editImage = photos[0]
        self.navigationController?.pushViewController(viewController , animated: false)
    }
}

