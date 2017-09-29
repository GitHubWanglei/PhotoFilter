//
//  ViewController.swift
//  PhotoFilter
//
//  Created by wanglei on 2017/9/22.
//  Copyright © 2017年 wanglei. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var addImgBtn: NSButton!
    @IBOutlet var photoImgView: NSImageView!
    @IBOutlet var collectionView: NSCollectionView!
    
    var originalImage: NSImage?
    var filterNames: [String]! = ["none", "CIPhotoEffectInstant", "CIPhotoEffectChrome",
                                  "CIPhotoEffectFade",  "CIPhotoEffectMono", "CIPhotoEffectNoir",
                                  "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer"]
    var filterChineseNames = ["无", "怀旧", "铬黄", "褪色", "单色", "黑白", "冲印", "色调", "岁月"]
    var itemSelected = [true, false, false, false, false, false, false, false, false]
    var filterImages: [NSImage] = []
    var clickGesture: NSClickGestureRecognizer!
    
    var openPanel: NSOpenPanel!
    var savePanel: NSSavePanel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // photo imageView
        photoImgView.focusRingType = .none
        photoImgView.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.new, context: nil)
        let gesture = NSClickGestureRecognizer.init(target: self, action: #selector(addImage))
        photoImgView.addGestureRecognizer(gesture)
        clickGesture = gesture
        
        // register item
        collectionView.register(PhotoCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier.init("item"))
        
        // openPanel
        openPanel = NSOpenPanel()
        openPanel.appearance = NSAppearance(named: .vibrantLight)
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = NSImage.imageTypes
        
    }
    
    override func viewWillAppear() {
        self.view.window?.backgroundColor = NSColor(calibratedRed: 29/255.0, green: 29/255.0, blue: 29/255.0, alpha: 1)
        self.view.window?.appearance = NSAppearance(named: .vibrantDark)
        self.view.window?.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden = (originalImage == nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "image" {
            originalImage = change![NSKeyValueChangeKey.newKey] as? NSImage
            if let image = originalImage {
                filterImages = []
                for i in 0..<filterNames.count {
                    let filterName = filterNames[i]
                    if filterName == "none" {
                        filterImages.append(image)
                    }else{
                        if let filterImage = self.filterWithOriginalImage(image: image, filterName: filterName, item: i) {
                            filterImages.append(filterImage)
                        }
                    }
                }
                itemSelected = [true, false, false, false, false, false, false, false, false]
                addImgBtn.isHidden = true
                collectionView.reloadData()
                collectionView.selectItems(at: [IndexPath(item:0, section: 0)], scrollPosition: NSCollectionView.ScrollPosition.top)
                self.view.window?.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden = false
                photoImgView.removeGestureRecognizer(clickGesture)
                
                if let delegate = NSApp.delegate as? AppDelegate {
                    delegate.addSaveAsBtnTarget()
                }
                
            }
        }
    }
    
    @objc public func addImage() {
        openPanel.beginSheetModal(for: self.view.window!) { (response) in
            if response == NSApplication.ModalResponse.OK {
                if let fileUrl = self.openPanel.url {
                    do {
                        let imageData = try Data(contentsOf: fileUrl)
                        self.originalImage = NSImage(data: imageData)
                        self.addImgBtn.isHidden = true
                        self.photoImgView.image = self.originalImage
                    }catch{
                        print("Open image file error: \(error)")
                    }
                }
            }
        }
    }
    
    public func saveImage() {
        
        savePanel = NSSavePanel(contentRect: (self.view.window?.frame)!, styleMask: NSWindow.StyleMask.utilityWindow, backing: NSWindow.BackingStoreType.buffered, defer: true)
        savePanel.nameFieldStringValue = "image.png"
        savePanel.isExtensionHidden = true
        savePanel.allowedFileTypes = NSImage.imageTypes
        savePanel.allowedFileTypes = ["png"]
        savePanel.allowsOtherFileTypes = true
        savePanel.canCreateDirectories = true
        savePanel.beginSheetModal(for: self.view.window!) { (response) in
            if response == NSApplication.ModalResponse.OK {
                if let fileUrl = self.savePanel.url {
                    print("______fileUrl: \(fileUrl)")
                    if let image = self.photoImgView.image {
                        guard let data = image.tiffRepresentation,
                            let rep = NSBitmapImageRep(data: data),
                            let imgData = rep.representation(using: .png, properties: [.compressionFactor : NSNumber(floatLiteral: 1.0)]) else {
                                Swift.print("Error Function '\(#function)' Line: \(#line) No tiff rep found for image writing to \(fileUrl)")
                                return
                        }
                        do {
                            try imgData.write(to: fileUrl)
                        }catch let error {
                            Swift.print("Error Function '\(#function)' Line: \(#line) \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        
    }
    
}

// MARK: NSCollectionViewDataSource
extension ViewController: NSCollectionViewDataSource{
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if originalImage != nil {
            return filterNames.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier.init("item"), for: indexPath) as! PhotoCollectionViewItem
        if filterImages.count == 9 {
            item.photoImgView.image = filterImages[indexPath.item]
            item.filterNameLabel.stringValue = filterChineseNames[indexPath.item]
            item.filterNameLabel.font = NSFont.systemFont(ofSize: 14, weight: .ultraLight)
        }
        item.view.wantsLayer = true
        if itemSelected[indexPath.item] == true {
            item.isSelected = true
            item.view.layer?.borderWidth = 1
            item.view.layer?.cornerRadius = 8;
            item.view.layer?.borderColor = NSColor(calibratedRed: 17/255.0, green: 108/255.0, blue: 214/255.0, alpha: 1).cgColor
        }else{
            item.isSelected = false
            item.view.layer?.borderWidth = 0
        }
        return item
    }
    
}

// MARK: NSCollectionViewDelegate
extension ViewController: NSCollectionViewDelegate{
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.scrollToItems(at: indexPaths, scrollPosition: NSCollectionView.ScrollPosition.centeredVertically)
        let item = collectionView.item(at: (indexPaths.first?.item)!) as! PhotoCollectionViewItem
        itemSelected[(indexPaths.first?.item)!] = true
        item.view.wantsLayer = true
        item.view.layer?.borderWidth = 1
        item.view.layer?.cornerRadius = 8;
        item.view.layer?.borderColor = NSColor(calibratedRed: 17/255.0, green: 108/255.0, blue: 214/255.0, alpha: 1).cgColor
        photoImgView.removeObserver(self, forKeyPath: "image", context: nil)
        photoImgView.image = item.photoImgView.image
        photoImgView.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.new, context: nil)
        
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        let item = collectionView.item(at: (indexPaths.first?.item)!) as? PhotoCollectionViewItem
        itemSelected[(indexPaths.first?.item)!] = false
        item?.view.wantsLayer = true
        item?.view.layer?.borderWidth = 0
    }
    
}

extension ViewController{
    func filterWithOriginalImage(image: NSImage, filterName: String, item: NSInteger) -> NSImage? {
        
        let inputImage = CIImage(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
        let filter = CIFilter(name: filterNames[item])
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        let resultCIImage = filter?.outputImage
        
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(resultCIImage!, from: (resultCIImage?.extent)!)
        
        return NSImage(cgImage: cgImage!, size: CGSize(width: (resultCIImage?.extent)!.width, height: (resultCIImage?.extent)!.height))
    }
    
}





