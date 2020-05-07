//
//  ViewController.swift
//  BluetoothComponent
//
//  Created by Mehul Jadav on 12/11/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController {
    
    @IBOutlet weak var btnScan: UIBarButtonItem!
    @IBOutlet weak var lblConnectedDevice: UILabel!
    
    let objBC : MyBluetooth = MyBluetooth() //.default
    var scanTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        objBC.intialize()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        scanTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(scaneDevices), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        scanTimer?.invalidate()
    }
    
    @objc func scaneDevices() {
        if self.objBC.connectedPeripheral != nil {
            //print("Peripheral Name : ",self.objBC.connectedPeripheral?.name ?? "")
            self.lblConnectedDevice.text = "Peripheral Name : \(self.objBC.connectedPeripheral?.name ?? "")\nStatus : \(String(describing: objBC.connectionStatus))"
        }
    }
    
    func customiseNavigationBar () {
        
        self.navigationItem.rightBarButtonItem = nil
        
        let rightButton = UIButton()
        
        if (self.objBC.connectedPeripheral == nil) {
            rightButton.setTitle("Scan", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 60, height: 30))
            rightButton.addTarget(self, action: #selector(self.scanButtonPressed), for: .touchUpInside)
        } else {
            rightButton.setTitle("Disconnect", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 30))
            rightButton.addTarget(self, action: #selector(self.disconnectButtonPressed), for: .touchUpInside)
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = rightButton
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    // MARK: Button Methods
    @objc func scanButtonPressed() {
        performSegue(withIdentifier: "scan-segue", sender: nil)
    }
    
    @objc func disconnectButtonPressed() {
        //this will call didDisconnectPeripheral, but if any other apps are using the device it will not immediately disconnect
        if self.objBC.connectedPeripheral != nil {
            self.objBC.manager?.cancelPeripheralConnection(self.objBC.connectedPeripheral!)
        }
    }
    
    @IBAction func clickOnScan(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ScanListViewController") as? ScanListViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

