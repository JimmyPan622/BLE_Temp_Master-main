import UIKit
import CoreBluetooth
//git
let BLE_Temp_Service_CBUUID = CBUUID(string: "0x1809")
let BLE_Temp_Measurement_Characteristic_CBUUID = CBUUID(string: "0x2A1C")

class HeartRateMonitorViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager?
    var peripheralMonitor: CBPeripheral?
    
    @IBOutlet weak var connectingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectionStatusView: UIView!
    @IBOutlet weak var brandNameTextField: UITextField!
    @IBOutlet weak var beatsPerMinuteLabel: UILabel!
    @IBOutlet weak var bluetoothOffLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectingActivityIndicator.backgroundColor = UIColor.white
        connectingActivityIndicator.startAnimating()
        connectionStatusView.backgroundColor = UIColor.red
        brandNameTextField.text = "----"
        beatsPerMinuteLabel.text = "---"
        bluetoothOffLabel.alpha = 0.0
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        
        case .unknown:
            print("Bluetooth status is UNKNOWN")
            bluetoothOffLabel.alpha = 1.0
        case .resetting:
            print("Bluetooth status is RESETTING")
            bluetoothOffLabel.alpha = 1.0
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
            bluetoothOffLabel.alpha = 1.0
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
            bluetoothOffLabel.alpha = 1.0
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
            bluetoothOffLabel.alpha = 1.0
            connectionStatusView.backgroundColor = UIColor.red
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            
            DispatchQueue.main.async { () -> Void in
                self.bluetoothOffLabel.alpha = 0.0
                self.connectingActivityIndicator.startAnimating()
            }
            centralManager?.scanForPeripherals(withServices: [BLE_Temp_Service_CBUUID], options: nil)
        @unknown default:
            print("Error")
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheral.delegate = self
        print(peripheral.name!)
        print("Characteristic ID:", BLE_Temp_Measurement_Characteristic_CBUUID)
        decodePeripheralState(peripheralState: peripheral.state)
        peripheralMonitor = peripheral
        peripheralMonitor?.delegate = self
        centralManager?.stopScan()
        print("stop scan")
        centralManager?.connect(peripheralMonitor!)
        print("connect: \(String(describing: peripheralMonitor))")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async { () -> Void in
            self.brandNameTextField.text = peripheral.name!
            self.connectionStatusView.backgroundColor = UIColor.green
            self.beatsPerMinuteLabel.text = "---"
            self.connectingActivityIndicator.stopAnimating()
        }
        peripheralMonitor?.discoverServices([BLE_Temp_Service_CBUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected!")
        
        DispatchQueue.main.async { () -> Void in
            self.brandNameTextField.text = "----"
            self.connectionStatusView.backgroundColor = UIColor.red
            self.beatsPerMinuteLabel.text = "---"
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
            if service.uuid == BLE_Temp_Service_CBUUID {
                print("Serv Name: \(service)")
                
                peripheral.discoverCharacteristics(nil, for: service)
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
            let tempValue = deriveBeatsPerMinute(using: characteristic)
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
        print("TempValue.type: \(type(of: TempValue))")
        print("TempValue.value: \(TempValue)")
        print("TempCharacteristic.value: \(TempCharacteristic.value!)")
        let buffer = [UInt8](TempValue)
        print("buffer: \(buffer)")
        /*for byte in buffer{
            print("test convert to hex value: \(String(format: "%2X", byte))")
        }
        print("test: \(String(format: "%2X", 20))")*/

        if ((buffer[0] & 0x01) == 0) {
            var num = Float(Int(buffer[2]) << 8)
            num += Float(buffer[1])
            print("Celsius")
            return (num / 100)
        } else {
            print("Fahrenheit")
            return -1
        }
    }
    
    func decodePeripheralState(peripheralState: CBPeripheralState) {
        switch peripheralState {
            case .disconnected:
                connectionStatusView.backgroundColor = UIColor.red
                print("Peripheral state: disconnected")
            case .connected:
                connectionStatusView.backgroundColor = UIColor.green
                print("Peripheral state: connected")
            case .connecting:
                print("Peripheral state: connecting")
            case .disconnecting:
                print("Peripheral state: disconnecting")
        @unknown default:
            print("Error")
        }
    }
}

