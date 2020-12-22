import UIKit
import CoreBluetooth

protocol FetchTextDelegate {
    func fetchText(_ text: String)
}

class HomeVC: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var deviceList = [String]()
    var delegate: FetchTextDelegate?
    var deviceScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "bleDevice") as! bleDeviceVC
    var centralManager: CBCentralManager?
    var peripheralMonitor: CBPeripheral?
    
    @IBOutlet weak var connectingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var brandNameTextField: UITextField!
    @IBOutlet weak var beatsPerMinuteLabel: UILabel!
    @IBOutlet weak var bluetoothOffLabel: UILabel!
    @IBOutlet weak var chooseDeviceBtn: UIButton!
    @IBOutlet weak var VANATEKLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectingActivityIndicator.backgroundColor = UIColor.white
        connectingActivityIndicator.startAnimating()
        bluetoothOffLabel.alpha = 0.0
        //chooseDeviceBtn.alpha = 0.0
        VANATEKLogo.alpha = 0.3
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
        cleanText()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
                self.view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func SwitchDeviceList(_ sender: Any) {
            self.present(deviceScreen, animated: true, completion: nil)
            self.delegate = deviceScreen
            self.delegate?.fetchText("123321")
        }
    
    //Get bluetooth status
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .unknown:
                print("Bluetooth status is UNKNOWN")
                bluetoothOffLabel.alpha = 1.0
                cleanText()
            case .resetting:
                print("Bluetooth status is RESETTING")
                bluetoothOffLabel.alpha = 1.0
                cleanText()
            case .unsupported:
                print("Bluetooth status is UNSUPPORTED")
                bluetoothOffLabel.alpha = 1.0
                cleanText()
            case .unauthorized:
                print("Bluetooth status is UNAUTHORIZED")
                bluetoothOffLabel.alpha = 1.0
                cleanText()
            case .poweredOff:
                print("Bluetooth status is POWERED OFF")
                bluetoothOffLabel.alpha = 1.0
                cleanText()
            case .poweredOn:
                print("Bluetooth status is POWERED ON")
                //use main thread to update UI
                DispatchQueue.main.async { () -> Void in
                    self.bluetoothOffLabel.alpha = 0.0
                    self.connectingActivityIndicator.startAnimating()
                }
                scanBLEDevice()
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
        }
        let DeviceList = deviceList.removingDuplicates()
        print(DeviceList)
        //print("Characteristic ID: ", BLE_Temp_Measurement_Characteristic_CBUUID)
        //self.bluetoothList.reloadData()
        //decodePeripheralState(peripheralState: peripheral.state)
        //暫時不使用-----------------------------------------------------------
        /*peripheralMonitor = peripheral
        peripheralMonitor?.delegate = self
        print("Device List: \(String(describing: peripheralMonitor))")
        if(peripheral.name == "AMICCOM_Demo" || peripheral.name == "VANATEK DEMO"){
            //設為代表後才能抓取資料
            peripheral.delegate = self
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
        DispatchQueue.main.async { () -> Void in
            self.brandNameTextField.text = peripheral.name!
            self.beatsPerMinuteLabel.text = "----"
            self.connectingActivityIndicator.stopAnimating()
        }
        peripheralMonitor?.discoverServices([BLE_Temp_Service_CBUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected!")
        
        DispatchQueue.main.async { () -> Void in
            self.brandNameTextField.text = "----"
            self.beatsPerMinuteLabel.text = "----"
            self.connectingActivityIndicator.startAnimating()
        }
        centralManager?.scanForPeripherals(withServices: [BLE_Temp_Service_CBUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if((error != nil)){
            print("Error: \(error!.localizedDescription)")
            return
        }
        //Check the founded services list
        /*guard let services = peripheral.services else{
            print("Error: No services")
            return
        }
        print("Discover Services: \(services)")*/
        
        for service in peripheral.services! {
            print("test print all service \(service)")
            if service.uuid == BLE_Temp_Service_CBUUID {
                print("Serv Name: \(service)")
                
                //peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if((error != nil)){
            print("Error: \(error!.localizedDescription)")
            return
        }
        //check the founded characteristices list
        /*guard let characteristics = service.characteristics else{
            print("Error: No characteristics")
            return
        }
        print("characteristics: \(characteristicss)")*/
        
        for characteristic in service.characteristics! {
            if characteristic.uuid == BLE_Temp_Measurement_Characteristic_CBUUID {
                print("CH Name: \(characteristic)")

                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == BLE_Temp_Measurement_Characteristic_CBUUID {
            let tempValue = String(format: "%.2f", deriveBeatsPerMinute(using: characteristic))
            DispatchQueue.main.async { () -> Void in
                UIView.animate(withDuration: 1.0, animations: {
                    self.beatsPerMinuteLabel.text = String(tempValue)
                    print(tempValue)
                }, completion: { (true) in
                })
            }
        }
    }
    
    func deriveBeatsPerMinute(using TempCharacteristic: CBCharacteristic) ->  Float{
        let TempValue = TempCharacteristic.value!
        /*print("TempValue.type: \(type(of: TempValue))")
        print("TempValue.value: \(TempValue)")*/
        let buffer = [UInt8](TempValue)
        print("buffer: \(buffer)")
        /*for byte in buffer{
            print("test convert to hex value: \(String(format: "%2X", byte))")
        }
        print("test: \(String(format: "%2X", 20))")*/

        if ((buffer[0] & 0x01) == 0) {
            var temp = Float(Int(buffer[2]) << 8)
            temp += Float(buffer[1])
            print("Celsius:")
            return (temp / 100)
        } else {
            var temp = Float(Int(buffer[2]) << 8)
            temp += Float(buffer[1])
            print("Fahrenheit")
            return (temp / 100)
        }
    }
    
    func decodePeripheralState(peripheralState: CBPeripheralState) {
        switch peripheralState {
            case .disconnected:
                print("Peripheral state: disconnected")
            case .disconnecting:
                print("Peripheral state: disconnecting")
            case .connected:
                print("Peripheral state: connected")
            case .connecting:
                print("Peripheral state: connecting")
        @unknown default:
            print("Error")
        }
    }
    
    func scanBLEDevice(){
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
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
    
    //init all text
    func cleanText(){
        brandNameTextField.text = "----"
        beatsPerMinuteLabel.text = "----"
    }
}

extension Array where Element: Hashable {
  func removingDuplicates() -> [Element] {
      var addedDict = [Element: Bool]()
      return filter {
        addedDict.updateValue(true, forKey: $0) == nil
      }
   }
   mutating func removeDuplicates() {
      self = self.removingDuplicates()
   }
}
