//
//  AppDelegate.swift
//  DelanCamUtil
//
//  Created by Matteo Ceruti on 07.10.24.
//

import Cocoa
import AVFoundation

import USBDeviceSwift


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    static let delanCamsUsbInfos:[USBMonitorData] = [
        USBMonitorData(vendorId: 0x0120, productId: 0x1234)
        //,add more devices?
    ]
    
    private let stm32DeviceMonitor = USBDeviceMonitor(AppDelegate.delanCamsUsbInfos)
    private var statusItem: NSStatusItem!
    private var pushSettingsNow: NSMenuItem!
    
 
    
    func setupMenus() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        pushSettingsNow = NSMenuItem(title: "Reapply camera settings now", action: #selector(self.pushSettings), keyEquivalent: "");
        pushSettingsNow.isEnabled = false
        menu.addItem(pushSettingsNow)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About", action: #selector(aboutMenu), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit DelanCamUtil", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        statusItem.menu = menu
     }
    
    @objc func pushSettings(){
        for monitorData in AppDelegate.delanCamsUsbInfos {
            findDelanCamAndPushSttings(vendorId: monitorData.vendorId, productId: monitorData.productId)
        }
    }
    
    @objc func aboutMenu(){
        let url = URL(string: "https://github.com/matatata/delancamutil")!
        NSWorkspace.shared.open(url)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "poweroutlet.type.d", accessibilityDescription: "1")
        }
        setupMenus()
        
        
        let stm32DeviceDaemon = Thread(target: stm32DeviceMonitor, selector:#selector(stm32DeviceMonitor.start), object: nil)
        stm32DeviceDaemon.start()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbConnected), name: .USBDeviceConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbDisconnected), name: .USBDeviceDisconnected, object: nil)
    }
 
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    
    fileprivate func findDelanCamAndPushSttings(device:USBDevice) {
        findDelanCamAndPushSttings(vendorId: device.vendorId, productId: device.productId)
    }

    
    fileprivate func findDelanCamAndPushSttings(vendorId:UInt16, productId:UInt16) {
        let id=String(format: "0x%X:0x%X",vendorId,productId)
        util("-V", "\(id)", "-s", "auto-exposure-mode=minimum", "-s" , "auto-exposure-priority=maximum")
    }

   

    @discardableResult
    func util(_ args: String...) -> Int32 {
        let task = Process()
        task.executableURL = Bundle.main.url(forResource: "uvc-util",withExtension: "")
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    // getting connected device data
    @objc func usbConnected(notification: NSNotification) {
        guard let nobj = notification.object as? NSDictionary else {
            return
        }

        guard let device:USBDevice = nobj["device"] as? USBDevice else {
            return
        }
        
        DispatchQueue.main.async {
            if let button = self.statusItem.button {
                button.image = NSImage(systemSymbolName: "poweroutlet.type.d.fill", accessibilityDescription: "1")
                self.pushSettingsNow.isEnabled = true
                self.findDelanCamAndPushSttings(device: device)
            }
            
        }
        
        
    }

        // getting disconnected device id
    @objc func usbDisconnected(notification: NSNotification) {
        DispatchQueue.main.async {
            if let button = self.statusItem.button {
                button.image = NSImage(systemSymbolName: "poweroutlet.type.d", accessibilityDescription: "1")
            }
            self.pushSettingsNow.isEnabled = false
        }

       
    }
    

}

