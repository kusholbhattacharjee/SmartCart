//
//  ProductTableViewController.swift
//  SmartCart
//
//  Created by Kushol Bhattacharjee on 3/5/19.
//  Copyright © 2019 Kushol Bhattacharjee. All rights reserved.
//

import UIKit

class ProductTableViewController: UITableViewController {
	
    @IBOutlet weak var scanNewButton: UIBarButtonItem!
    
    private var productList = [Product]()
	let alert = UIAlertController(title: "Weigh to Price", message: "Place item on weight scale", preferredStyle: .alert)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.productList = BluetoothManager.shared.products
		BluetoothManager.shared.count = 0
		scanNewButton.target = self
		scanNewButton.action = #selector(buttonClicked(sender:))
		scanNewButton.isEnabled = false
		
		self.alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
		NotificationCenter.default.addObserver(self, selector: #selector(onScannedItem(_:)), name: Notification.Name.init(rawValue: "scannedItem"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onReceivedWeight(_:)), name: Notification.Name.init(rawValue: "receivedWeight"), object: nil)
	}
	
    
    @objc func buttonClicked(sender: UIBarButtonItem) {
        BluetoothManager.shared.scanNewItem()
    }
    
    
	@objc func onScannedItem(_ notification: Notification) {
		self.productList = BluetoothManager.shared.products
		let item = productList[productList.count-1]
		
		if BluetoothManager.shared.mode == "w" {
			alert.message = String(item.name) + " price: $" + String(item.price) + "/oz"
			// Present the alert.
			self.present(alert, animated: true, completion: nil)
		} else {
			self.tableView.beginUpdates()
			self.tableView.insertRows(at: [NSIndexPath(row: productList.count-1, section: 0) as IndexPath], with:.automatic)
			self.tableView.endUpdates()
			self.scanNewButton.isEnabled = true
		}
	}
	
	@objc func onReceivedWeight(_ notification: Notification) {
		let voltage = notification.userInfo!["weight"] as! Double
		let oz = (2050.0 - voltage) / 17.0
		print(oz)
		alert.message = String(format: "%.2f oz", oz)
		productList[productList.count-1].price *= oz
		self.tableView.beginUpdates()
		self.tableView.insertRows(at: [NSIndexPath(row: productList.count-1, section: 0) as IndexPath], with:.automatic)
		self.tableView.endUpdates()
		self.scanNewButton.isEnabled = true
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return productList.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
		
		if indexPath.row < productList.count
		{
			let item = productList[indexPath.row]
			cell.nameLabel?.text = item.name
			cell.idLabel?.text = item.id
			cell.priceLabel?.text = "$" + String(format: "%.2f", item.price)
		}
		
		return cell
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let vc = segue.destination as! CheckOutViewController
		var totalPrice = 0.0
		for item in self.productList {
			totalPrice = totalPrice + item.price
		}
		vc.totalPrice = totalPrice
	}
	
}
