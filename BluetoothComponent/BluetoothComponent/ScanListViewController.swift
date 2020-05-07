//
//  ScanListViewController.swift
//  BluetoothComponent
//
//  Created by Mehul Jadav on 12/11/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanListViewController: UIViewController {

    @IBOutlet weak var tblBCList : UITableView!

    var parentView:ViewController? = nil
    let objBC = MyBluetooth.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblBCList.tableFooterView = UIView()
        //self.manager = CBCentralManager(delegate: self, queue: nil)
        
        objBC.delegate = self
        if objBC.isConnected == true {
            print(objBC.connectionStatus ?? "")
            print(objBC.getConnectedPeripheral() ?? "")
            print(objBC.connectedPeripheral?.name ?? "")
            objBC.disConnect()
        }
        //objBC.disConnect()
        objBC.intialize()
        
        
    }

    /*override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.objBC.scanBLEDevices()
    }*/
    
    @IBAction func clickOnSend(_ sender: Any) {
        
        if objBC.isConnected == true {
            self.objBC.sendMessage(message: "hello world...") { (success, error) in
                if success == true {
                    print("Successfully send a message...")
                } else {
                    print(error?.localizedDescription ?? "")
                }
            }
        }
    }
    
}

//MARK: - Table view data source
extension ScanListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return objBC.peripherals.count //peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scanTableCell", for: indexPath)
        let peripheral = objBC.peripherals[indexPath.row] //peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = objBC.peripherals[indexPath.row] //peripherals[indexPath.row]
        self.objBC.manager?.connect(peripheral, options: nil)
    }
}

//MARK:- MyBluetoothDelegate Methods
extension ScanListViewController: MyBluetoothDelegate {
    
    func receivePeripherals(peripherals: [CBPeripheral]) {
        //print(peripherals)
        self.tblBCList.reloadData()
        objBC.connectToPeripheral(peripheral: peripherals[0])
        if objBC.isConnected == true {
            print(objBC.connectionStatus ?? "")
            print(objBC.getConnectedPeripheral() ?? "")
            print(objBC.connectedPeripheral?.name ?? "")
        }
        
    }
    
    func dataRecieved(message:String) {
        print("Recieved : \(message)")
    }
}
