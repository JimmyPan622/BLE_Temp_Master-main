//
//  bleDeviceVC.swift
//  BLE_Temp
//
//  Created by Jimmy Pan on 2020/12/8.
//  Copyright © 2020 Andrew Jaffee. All rights reserved.
//

import UIKit
import CoreBluetooth

let BLE_Temp_Service_CBUUID = CBUUID(string: "0x1809")
let BLE_Temp_Measurement_Characteristic_CBUUID = CBUUID(string: "0x2A1C")

class bleDeviceVC: UIViewController, UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager?
    var peripheralMonitor: CBPeripheral?
    let myDevice: [String] = ["Chairman", "MacBook", "iPhone6s", "Monx", "Samsung S2"]
    var deviceList: [String] = []
    
    //Get bluetooth status
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .unknown:
                print("Bluetooth status is UNKNOWN")
            case .resetting:
                print("Bluetooth status is RESETTING")
            case .unsupported:
                print("Bluetooth status is UNSUPPORTED")
            case .unauthorized:
                print("Bluetooth status is UNAUTHORIZED")
            case .poweredOff:
                print("Bluetooth status is POWERED OFF")
            case .poweredOn:
                print("Bluetooth status is POWERED ON")
            @unknown default:
                print("Error")
        }
    }
    
    //Scan compliant service and connect it
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //if no device nearby, stop the scanner
        if(peripheral.name == nil){
            stopScanBLEDevice()
            print("stop scan")
            return
        }
        else{
            deviceList.append(String(peripheral.name!))
        }
        print(deviceList)
        /*peripheral.delegate = self
        print(peripheral.name!)
        print("Characteristic ID: ", BLE_Temp_Measurement_Characteristic_CBUUID)
        //self.bluetoothList.reloadData()
        decodePeripheralState(peripheralState: peripheral.state)
        
        peripheralMonitor = peripheral
        peripheralMonitor?.delegate = self

        if(peripheral.name == "AMICCOM_Demo" || peripheral.name == "VANATEK DEMO"){
            centralManager?.connect(peripheralMonitor!)
            print("connect: \(String(describing: peripheralMonitor))")
            stopScanBLEDevice()
        }
        else{
            centralManager?.cancelPeripheralConnection(peripheral)
            scanBLEDevice()
        }*/
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralMonitor?.discoverServices([BLE_Temp_Service_CBUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected!")
        centralManager?.scanForPeripherals(withServices: [BLE_Temp_Service_CBUUID])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myDevice.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = myDevice[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Your selected is: \(myDevice[indexPath.row])")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func decodePeripheralState(peripheralState: CBPeripheralState) {
        switch peripheralState {
            case .disconnected:
                print("Peripheral state: disconnected")
            case .connected:
                print("Peripheral state: connected")
            case .connecting:
                print("Peripheral state: connecting")
            case .disconnecting:
                print("Peripheral state: disconnecting")
        @unknown default:
            print("Error")
        }
    }
    
    func scanBLEDevice(){
        centralManager?.scanForPeripherals(withServices: [BLE_Temp_Service_CBUUID], options: nil)
    }
    
    func stopScanBLEDevice(){
        centralManager?.stopScan()
        print("stop scan")
    }
    
    func connect(peripheral: CBPeripheral){
        print("Connect")
        print(peripheral)
    }
    
    //close keyboard
    @objc func dismissKeyBoard(){
        self.view.endEditing(true)
    }
    
    @IBAction func clickDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension bleDeviceVC: FetchTextDelegate{
    func fetchText(_ text: String){
        print(text)
    }
}
