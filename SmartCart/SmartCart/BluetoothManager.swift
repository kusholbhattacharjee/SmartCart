//
//  BluetoothManager.swift
//  SmartCart
//
//  Created by Kushol Bhattacharjee on 2/19/19.
//  Copyright © 2019 Kushol Bhattacharjee. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

let hmCBUUID = CBUUID(string: "0XFFE0")
let hmCharacteristicCBUUID = CBUUID(string: "0xFFE1")

class BluetoothManager: NSObject {
	
	static let shared = BluetoothManager()
	
	var mode:Character = "b"
	var products = [Product]()
	
	var cardNumber: String = "XXXX XXXX XXXX XXXX"
	var expDate: String = "MM/YY"
	var csv: String = "XXX"
	var count: Int = 0
	var temp: String = ""
	
	//MARK: Bluetooth variables
	var centralManager: CBCentralManager!
	var hmPeripheral: CBPeripheral!
	var hmCharacteristic: CBCharacteristic!
	
	override init() {
		super.init()
		centralManager = CBCentralManager(delegate: self, queue: nil)
	}
}

extension BluetoothManager: CBCentralManagerDelegate {
	
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
		//print(peripheral)
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

extension BluetoothManager: CBPeripheralDelegate {
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		guard let services = peripheral.services else { return }
		
		for service in services {
			//print(service)
			peripheral.discoverCharacteristics(nil, for: service)
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
					error: Error?) {
		guard let characteristics = service.characteristics else { return }
		for characteristic in characteristics {
			//print(characteristic)
			hmCharacteristic = characteristic
			if characteristic.properties.contains(.read) {
				//print("\(characteristic.uuid): properties contains .read")
				peripheral.readValue(for: characteristic)
			}
			if characteristic.properties.contains(.notify) {
				//print("\(characteristic.uuid): properties contains .notify")
				peripheral.setNotifyValue(true, for: characteristic)
			}
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
					error: Error?) {
		switch characteristic.uuid {
			case hmCharacteristicCBUUID:
				let productID = String(decoding: characteristic.value!, as: UTF8.self)
				print("received: " + productID)
				if self.mode == "p" { // PAY
					if count == 0 {
						self.cardNumber = productID
					} else if count == 1 {
						self.csv = productID
					} else if count == 2 {
					} else if count == 3 {
						self.expDate = productID
						NotificationCenter.default.post(name: Notification.Name.init(rawValue: "receivedPayment"), object: nil)
					}
					count += 1
					
				} else if self.mode == "w" { // WEIGHT
					NotificationCenter.default.post(name:Notification.Name.init(rawValue:"receivedWeight"), object: nil, userInfo: ["weight":Double(productID)!])
					self.mode = "a"
					
				} else if Database.keys.contains(productID) && self.mode == "a" { // PRODUCT
					if Database[productID]?.weigh == true {
						hmPeripheral.writeValue("w".data(using: .utf8)!, for: hmCharacteristic, type: .withoutResponse)
						self.mode = "w"
						print("sent a w to micro")
					} else {
						self.mode = "a"
					}
					products.append(Database[productID]!)
					NotificationCenter.default.post(name: Notification.Name.init(rawValue: "scannedItem"), object: nil, userInfo: ["product":Database[productID]] as! [String:Product])
					
				} else if self.mode == "a"{ // RANDO PRODUCT
					let unknownProduct = Product(name: "Unkown product", id: productID, price: 3.21, weigh: false)
					products.append(unknownProduct)
					NotificationCenter.default.post(name: Notification.Name.init(rawValue: "scannedItem"), object: nil, userInfo: ["product":unknownProduct] as [String:Product])
				} else {
					self.mode = "a"
				}
			default:
				print("Unhandled Characteristic UUID: \(characteristic.uuid)")
			}
	}
	
	func callForPayment() {
		hmPeripheral.writeValue("p".data(using: .utf8)!, for: hmCharacteristic, type: .withoutResponse)
		self.mode = "p"
		print("sent p to micro")
	}
	
	func scanNewItem() {
		hmPeripheral.writeValue("a".data(using: .utf8)!, for: hmCharacteristic, type: .withoutResponse)
		print("sent a to micro")
		self.mode = "a"
	}
	
}
