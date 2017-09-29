//
//  PhotoCollectionViewItem.swift
//  PhotoFilter
//
//  Created by wanglei on 2017/9/22.
//  Copyright © 2017年 wanglei. All rights reserved.
//

import Cocoa

class PhotoCollectionViewItem: NSCollectionViewItem {

    @IBOutlet var photoImgView: NSImageView!
    @IBOutlet var filterNameLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
