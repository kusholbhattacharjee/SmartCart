//
//  TableViewController.swift
//  SmartCart
//
//  Created by Kushol Bhattacharjee on 2/18/19.
//  Copyright © 2019 Kushol Bhattacharjee. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(TableViewController.didTapAddItemButton(_:)))
		
		// add observer for scanned item
		NotificationCenter.default.addObserver(self, selector: #selector(onScannedItem(_:)), name: Notification.Name.init(rawValue: "scannedItem"), object: nil)
		
		// Setup a notification to let us know when the app is about to close,
		// and that we should store the user items to persistence. This will call the
		// applicationDidEnterBackground() function in this class
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)),
			name: NSNotification.Name.NSExtensionHostDidEnterBackground,
			object: nil)
		
		do
		{
			// Try to load from persistence
			self.groceryItems = try [ListItem].readFromPersistence()
		}
		catch let error as NSError
		{
			if error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError
			{
				NSLog("No persistence file found, not necesserially an error...")
			}
			else
			{
				let alert = UIAlertController(
					title: "Error",
					message: "Could not load the to-do items!",
					preferredStyle: .alert)
				
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				
				self.present(alert, animated: true, completion: nil)
				
				NSLog("Error loading from persistence: \(error)")
			}
		}
	}
	
	
	// INITIALIZE TABLE WITH MOCK DATA
	private var groceryItems = [ListItem]()
	
	override func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return groceryItems.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier: "cellItem", for: indexPath)
		
		if indexPath.row < groceryItems.count
		{
			let item = groceryItems[indexPath.row]
			cell.textLabel?.text = item.title
			
			let accessory: UITableViewCell.AccessoryType = item.done ? .checkmark : .none
			cell.accessoryType = accessory
		}
		
		return cell
	}
	
	// CHECK MARK WHEN DONE
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		tableView.deselectRow(at: indexPath, animated: true)
		
		if indexPath.row < groceryItems.count
		{
			let item = groceryItems[indexPath.row]
			item.done = !item.done
			
			tableView.reloadRows(at: [indexPath], with: .automatic)
		}
	}
	
	//CHECK MARK WHEN SCANNED
	@objc func onScannedItem(_ notification: Notification) {
		let scannedItem = notification.userInfo!["product"] as! Product
		var index = 0
		var exists = false
		for item in groceryItems {
			if item.title == scannedItem.name {
				exists = true
				break
			} else {
				index += 1
			}
		}
		if exists {
			let indexPath = IndexPath(row: index, section: 0)
			tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
			tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
		}
		
	}
	
	// ADD ITEMS WITH ALERT
	@objc func didTapAddItemButton(_ sender: UIBarButtonItem)
	{
		// Create an alert
		let alert = UIAlertController(
			title: "New grocery item",
			message: "Insert the title new item:",
			preferredStyle: .alert)
		
		// Add a text field to the alert for the new item's title
		alert.addTextField(configurationHandler: nil)
		
		// Add a "cancel" button to the alert. This one doesn't need a handler
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		// Add a "OK" button to the alert. The handler calls addNewToDoItem()
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
			if let title = alert.textFields?[0].text
			{
				self.addNewToDoItem(title: title)
			}
		}))
		
		// Present the alert to the user
		self.present(alert, animated: true, completion: nil)
	}
	
	private func addNewToDoItem(title: String)
	{
		// The index of the new item will be the current item count
		let newIndex = groceryItems.count
		
		// Create new item and add it to the todo items list
		groceryItems.append(ListItem(title: title))
		
		// Tell the table view a new row has been created
		tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .top)
	}
	
	// DELETE ITEMS
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
	{
		if indexPath.row < groceryItems.count
		{
			groceryItems.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .top)
		}
	}
	
	@objc
	public func applicationDidEnterBackground(_ notification: NSNotification)
	{
		do
		{
			try groceryItems.writeToPersistence()
		}
		catch let error
		{
			NSLog("Error writing to persistence: \(error)")
		}
	}
	
}
