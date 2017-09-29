//
//  AppDelegate.swift
//  PhotoFilter
//
//  Created by wanglei on 2017/9/22.
//  Copyright © 2017年 wanglei. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var windowNumber = 0
    @IBOutlet weak public var saveAsBtn: NSMenuItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let window = NSApp.mainWindow {
            windowNumber = window.windowNumber
        }
        saveAsBtn.target = nil
        saveAsBtn.action = nil
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let mainWindow = NSApp.window(withWindowNumber: windowNumber) {
            mainWindow.makeKeyAndOrderFront(self)
            return true
        }
        return flag
    }
    
    @IBAction func openAction(_ sender: Any) {
        let vc = NSApp.mainWindow?.contentViewController as! ViewController
        vc.addImage()
    }
    
    public func addSaveAsBtnTarget(){
        saveAsBtn.target = self
        saveAsBtn.action = #selector(saveAsAction(_:))
    }
    
    @IBAction func saveAsAction(_ sender: NSMenuItem) {
        let vc = NSApp.mainWindow?.contentViewController as! ViewController
        vc.saveImage()
    }
    
}

