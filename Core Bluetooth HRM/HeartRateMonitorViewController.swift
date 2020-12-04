import UIKit

// STEP 0.00: MUST include the CoreBluetooth framework
import CoreBluetooth

// STEP 0.0: specify GATT "Assigned Numbers" as
// constants so they're readable and updatable

// MARK: - Core Bluetooth service IDs
let BLE_Temp_Service_CBUUID = CBUUID(string: "0xFFF0")

// MARK: - Core Bluetooth characteristic IDs
let BLE_Temp_Measurement_Characteristic_CBUUID = CBUUID(string: "0x2A1C")

// STEP 0.1: this class adopts both the central and peripheral delegates
// and therefore must conform to these protocols' requirements
class HeartRateMonitorViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: - Core Bluetooth class member variables
    
    // STEP 0.2: create instance variables of the
    // CBCentralManager and CBPeripheral so they
    // persist for the duration of the app's life
    var centralManager: CBCentralManager?
    var peripheralMonitor: CBPeripheral?
    
    // MARK: - UI outlets / member variables
    
    @IBOutlet weak var connectingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectionStatusView: UIView!
    @IBOutlet weak var brandNameTextField: UITextField!
    @IBOutlet weak var beatsPerMinuteLabel: UILabel!
    @IBOutlet weak var bluetoothOffLabel: UILabel!
    
    // HealthKit setup
    
    // MARK: - UIViewController delegate
    
    override func viewDidLoad() {
        print("test print 1")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("test print 2")
        // initially, we're scanning and not connected
        connectingActivityIndicator.backgroundColor = UIColor.white
        connectingActivityIndicator.startAnimating()
        connectionStatusView.backgroundColor = UIColor.red
        brandNameTextField.text = "----"
        beatsPerMinuteLabel.text = "---"
        // just in case Bluetooth is turned off
        bluetoothOffLabel.alpha = 0.0
        print("test print 3")
        // STEP 1: create a concurrent background queue for the central
        /*let centralQueue: DispatchQueue = DispatchQueue(label: "com.iosbrain.centralQueueName", attributes: .concurrent)
        print(centralQueue)*/
        // STEP 2: create a central to scan for, connect to,
        // manage, and collect data from peripherals
        print("test print 4")
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // read heart rate data from HKHealthStore
        // healthKitInterface.readHeartRateData()
        
        // read gender type from HKHealthStore
        // healthKitInterface.readGenderType()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CBCentralManagerDelegate methods

    // STEP 3.1: this method is called based on
    // the device's Bluetooth state; we can ONLY
    // scan for peripherals if Bluetooth is .poweredOn
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("test print 5")
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
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            
            DispatchQueue.main.async { () -> Void in
                self.bluetoothOffLabel.alpha = 0.0
                self.connectingActivityIndicator.startAnimating()
            }
            
            // STEP 3.2: scan for peripherals that we're interested in
            centralManager?.scanForPeripherals(withServices: [BLE_Temp_Service_CBUUID], options: nil)
            
        @unknown default:
            print("Error")
        } // END switch
        
    } // END func centralManagerDidUpdateState
    
    // STEP 4.1: discover what peripheral devices OF INTEREST
    // are available for this app to connect to
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheral.delegate = self
        print(peripheral.name!)
        print("device ID:", BLE_Temp_Measurement_Characteristic_CBUUID)
        print("test print 6")
        decodePeripheralState(peripheralState: peripheral.state)
        // STEP 4.2: MUST store a reference to the peripheral in
        // class instance variable
        peripheralMonitor = peripheral
        // STEP 4.3: since HeartRateMonitorViewController
        // adopts the CBPeripheralDelegate protocol,
        // the peripheralMonitor must set its
        // delegate property to HeartRateMonitorViewController
        // (self)
        peripheralMonitor?.delegate = self
        
        // STEP 5: stop scanning to preserve battery life;
        // re-scan if disconnected
        centralManager?.stopScan()
        print("stop scan")
        // STEP 6: connect to the discovered peripheral of interest
        centralManager?.connect(peripheralMonitor!)
        print("connect: \(String(describing: peripheralMonitor))")
    } // END func centralManager(... didDiscover peripheral
    
    // STEP 7: "Invoked when a connection is successfully created with a peripheral."
    // we can only move forwards when we know the connection
    // to the peripheral succeeded
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("test print 7")
        DispatchQueue.main.async { () -> Void in
            
            self.brandNameTextField.text = peripheral.name!
            self.connectionStatusView.backgroundColor = UIColor.green
            self.beatsPerMinuteLabel.text = "---"
            self.connectingActivityIndicator.stopAnimating()
            
        }
        
        // STEP 8: look for services of interest on peripheral
        peripheralMonitor?.discoverServices([BLE_Temp_Service_CBUUID])

    } // END func centralManager(... didConnect peripheral
    
    // STEP 15: when a peripheral disconnects, take
    // use-case-appropriate action
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("test print 8")
        print("Disconnected!")
        
        DispatchQueue.main.async { () -> Void in
            
            self.brandNameTextField.text = "----"
            self.connectionStatusView.backgroundColor = UIColor.red
            self.beatsPerMinuteLabel.text = "---"
            self.connectingActivityIndicator.startAnimating()
            
        }
        
        // STEP 16: in this use-case, start scanning
        // for the same peripheral or another, as long
        // as they're HRMs, to come back online
        centralManager?.scanForPeripherals(withServices: [BLE_Temp_Service_CBUUID])
        
    } // END func centralManager(... didDisconnectPeripheral peripheral

    // MARK: - CBPeripheralDelegate methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("test print 9")
        if((error != nil)){
            print("Error: \(error!.localizedDescription)")
            return
        }
        
        print(peripheral)
        print("Discover Services: \(peripheral.services!)")
        for service in peripheral.services! {
            print("test print 9.1")
            if service.uuid == BLE_Temp_Service_CBUUID {
                print("test print 9.2")
                print("Service: \(service)")
                
                // STEP 9: look for characteristics of interest
                // within services of interest
                peripheral.discoverCharacteristics(nil, for: service)
            }
            print("test print 9.3")
        }
        print("test print 9.4")
    } // END func peripheral(... didDiscoverServices
    
    // STEP 10: confirm we've discovered characteristics
    // of interest within services of interest
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("test print 10")
        if((error != nil)){
            print("Error: \(error!.localizedDescription)")
            return
        }
        guard let characteristicss = service.characteristics else{
            print("Error: No characteristics")
            return
        }
        print("characteristics: \(characteristicss)")
        for characteristic in service.characteristics! {
            print("test print 10.1")
            print(characteristic)
            print("char ID:", characteristic.uuid)
            if characteristic.uuid == BLE_Temp_Measurement_Characteristic_CBUUID {

                // STEP 11: subscribe to regular notifications
                // for characteristic of interest;
                // "When you enable notifications for the
                // characteristic’s value, the peripheral calls
                // ... peripheral(_:didUpdateValueFor:error:)
                //
                // Notify    Mandatory
                //
                peripheral.setNotifyValue(true, for: characteristic)
                print("test print 10.2")
            }
            print("test print 10.3")
        } // END for
        print("test print 10.4")
    } // END func peripheral(... didDiscoverCharacteristicsFor service
    
    // STEP 12: we're notified whenever a characteristic
    // value updates regularly or posts once; read and
    // decipher the characteristic value(s) that we've
    // subscribed to
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("test print 11")
        print(characteristic.uuid)
        if characteristic.uuid == BLE_Temp_Measurement_Characteristic_CBUUID {
            
            // STEP 13: we generally have to decode BLE
            // data into human readable format
            //define heartRat changed to tempValue
            let tempValue = deriveBeatsPerMinute(using: characteristic)
            print("test print 11.1")
            DispatchQueue.main.async { () -> Void in
                
                UIView.animate(withDuration: 1.0, animations: {
                    self.beatsPerMinuteLabel.alpha = 1.0
                    //define heartRat changed to tempValue
                    self.beatsPerMinuteLabel.text = String(tempValue)
                }, completion: { (true) in
                    self.beatsPerMinuteLabel.alpha = 0.0
                })
                print("test print 11.2")
            } // END DispatchQueue.main.async...
            print("test print 11.3")
        } // END if characteristic.uuid ==...
        print("test print 11.4")
    } // END func peripheral(... didUpdateValueFor characteristic
    
    // MARK: - Utilities
    
    func deriveBeatsPerMinute(using heartRateMeasurementCharacteristic: CBCharacteristic) -> Int {
        print("test print 12")
        let heartRateValue = heartRateMeasurementCharacteristic.value!
        // convert to an array of unsigned 8-bit integers
        let buffer = [UInt8](heartRateValue)

        // UInt8: "An 8-bit unsigned integer value type."
        
        // the first byte (8 bits) in the buffer is flags
        // (meta data governing the rest of the packet);
        // if the least significant bit (LSB) is 0,
        // the heart rate (bpm) is UInt8, if LSB is 1, BPM is UInt16
        if ((buffer[0] & 0x01) == 0) {
            // second byte: "Heart Rate Value Format is set to UINT8."
            print("BPM is UInt8")
            // write heart rate to HKHealthStore
            // healthKitInterface.writeHeartRateData(heartRate: Int(buffer[1]))
            return Int(buffer[1])
        } else { // I've never seen this use case, so I'll
                 // leave it to theoroticians to argue
            // 2nd and 3rd bytes: "Heart Rate Value Format is set to UINT16."
            print("BPM is UInt16")
            return -1
        }
        
    } // END func deriveBeatsPerMinute
    
    func decodePeripheralState(peripheralState: CBPeripheralState) {
        print("test print 13")
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
        
    } // END func decodePeripheralState(peripheralState

} // END class HeartRateMonitorViewController

