//
//  ViewController.swift
//  SmartCart
//
//  Created by Kushol Bhattacharjee on 1/31/19.
//  Copyright © 2019 Kushol Bhattacharjee. All rights reserved.
//
/*
import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    //MARK: Bluetooth vars
    var centralManager: CBCentralManager!
    var hmPeripheral: CBPeripheral!
	var hmCharacteristics: [CBCharacteristic] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        itemTextField.delegate = self
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        itemLabel.text = textField.text
		textField.text = ""
		var value: UInt8 = 1
		let data = NSData(bytes: &value, length: MemoryLayout<UInt8>.size)
		for characteristic in hmCharacteristics as [CBCharacteristic] {
			if(characteristic.uuid.uuidString == "FFE1") {
				hmPeripheral?.writeValue(data as Data, for: characteristic,type: CBCharacteristicWriteType.withoutResponse)
				print("Hello I sent a 1")
			}
		}
    }
    
    
    //MARK: Actions
    @IBAction func setDefaultLabelText(_ sender: UIButton) {
        itemLabel.text = "Default Text"
    }
    
}

extension ViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .unknown:
                print("central.state is .unknown")
            case .resetting:
                print("central.state is .resetting")
            case .unsupported:
                print("central.state is .unsupported")
            case .unauthorized:
                print("central.state is .unauthorized")
            case .poweredOff:
                print("central.state is .poweredOff")
            case .poweredOn:
                print("central.state is .poweredOn")
                centralManager.scanForPeripherals(withServices: [hmCBUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        hmPeripheral = peripheral
        hmPeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(hmPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        hmPeripheral.discoverServices([hmCBUUID])
    }
    
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let hmCharacteristics = service.characteristics else { return }
        
        for characteristic in hmCharacteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        switch characteristic.uuid {
        case hmCharacteristicCBUUID:
            print(characteristic.value ?? "no value")
            itemLabel.text = String(decoding: characteristic.value!, as: UTF8.self)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }


}
*/
