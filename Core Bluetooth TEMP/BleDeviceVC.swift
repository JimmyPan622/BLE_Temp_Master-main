//
//  bleDeviceVC.swift
//  BLE_Temp
//
//  Created by Jimmy Pan on 2020/12/8.
//
import UIKit
import CoreBluetooth

protocol FetchTargetDelegate {
    func fetchText(_ text: String)
}

class BleDeviceVC: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var deviceTable: UITableView!
    var centralManager: CBCentralManager?
    var peripheralMonitor: CBPeripheral?
    var delegate: FetchTargetDelegate?
    
    var HomePage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomePage") as! HomeVC
    var deviceList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Into device Page")
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            scanBLEDevice()
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
            stopScanBLEDevice()
        case .unknown:
            print("Bluetooth status is POWERED UNKNOW")
        case .resetting:
            print("Bluetooth status is RESETTING")
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
        @unknown default:
            print("Error")
        }
    }
    
    //Scan compliant service and connect it
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //if no device nearby, stop the scanner
        if(peripheral.name == nil){
            return
        }
        else{
            deviceList.append(String(peripheral.name!))
            deviceList = deviceList.removingDuplicates()
            deviceTable.reloadData()
        }
        print("print! \(deviceList)")
        
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
    //insert data into list for animate
    //How to call:
    //addData(String(peripheral.name!))
    func addData(_ data: String){
        let index = 0
        deviceList.insert(data, at: index)

        let indexPath = IndexPath(row: index, section: 0)
        deviceTable.insertRows(at: [indexPath], with: .top)
    }
    
    func scanBLEDevice(){
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanBLEDevice(){
        centralManager?.stopScan()
        print("stop scan")
    }
    
    @IBAction func clickDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

extension BleDeviceVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = deviceList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        stopScanBLEDevice()
        let targetDevice = deviceList[indexPath.row]
        print("Your selected is: \(deviceList[indexPath.row])")
        self.dismiss(animated: true, completion: nil)
        self.delegate = HomePage
        self.delegate?.fetchText(targetDevice)
    }
}
