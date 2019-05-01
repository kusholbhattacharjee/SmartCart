//
//  CheckOutViewController.swift
//  SmartCart
//
//  Created by Kushol Bhattacharjee on 3/19/19.
//  Copyright © 2019 Kushol Bhattacharjee. All rights reserved.
//

import UIKit

class CheckOutViewController: UIViewController {
	
	@IBOutlet weak var totalPriceLabel: UILabel!
	@IBOutlet weak var scanLabel: UILabel!
	@IBOutlet weak var cardNumberLabel: UILabel!
	@IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var csvLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    
    var totalPrice: Double!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.totalPriceLabel.text = String(format: "$%.02f",totalPrice)
		BluetoothManager.shared.callForPayment()
		completeButton.addTarget(self, action: #selector(completePayment), for: .touchUpInside)
        // Do any additional setup after loading the view.
		// TODO: send a "p" to ble module
		NotificationCenter.default.addObserver(self, selector: #selector(onReceivedPayment(_:)), name: Notification.Name.init(rawValue: "receivedPayment"), object: nil)
    }
    
    @objc func completePayment(sender: UIButton) {
		scanLabel.text = "Thank you for your payment"
		BluetoothManager.shared.cardNumber = "XXXX XXXX XXXX XXXX"
		BluetoothManager.shared.expDate = "MM/YY"
		BluetoothManager.shared.csv = "XXX"
    }
	

	@objc func onReceivedPayment(_ notification: Notification) {
		// Do something now
        scanLabel.text = "Successfully Scanned!"
		cardNumberLabel.text = BluetoothManager.shared.cardNumber
        expiryDateLabel.text = BluetoothManager.shared.expDate
        csvLabel.text = BluetoothManager.shared.csv
		BluetoothManager.shared.products = []
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
