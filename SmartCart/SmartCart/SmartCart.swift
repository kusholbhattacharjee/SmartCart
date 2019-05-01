//
//  SmartCart.swift
//  SmartCart
//
//  Created by Kushol Bhattacharjee on 2/18/19.
//  Copyright © 2019 Kushol Bhattacharjee. All rights reserved.
//

import Foundation

let Database = ["022000014719":Product(name: "gum", id: "022000014719", price: 1.45, weigh: false),
				"888462500616":Product(name: "iphone", id: "888462500616", price: 0.64, weigh: true),
				"070847811169":Product(name: "monster", id: "888462500616", price: 2.99, weigh: true),
				"083078113131":Product(name: "lip balm", id: "083078113131", price: 5.21, weigh: false),
				"41235454":Product(name: "light bulb", id: "41235454", price: 3.21, weigh: true),
				"31543245":Product(name: "dog food", id: "31543245", price: 3.21, weigh: false)
				]

class Product {
	var name: String
	var id: String
	var price: Double
	var weigh: Bool
	
	init(name: String, id: String, price: Double, weigh: Bool) {
		self.name = name
		self.id = id
		self.price = price
		self.weigh = weigh
	}
}

class ListItem: NSObject, NSCoding {
	
	var title: String
	var done: Bool
	
	public init(title: String) {
		self.title = title
		self.done = false
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		// Try to unserialize the "title" variable
		if let title = aDecoder.decodeObject(forKey: "title") as? String
		{
			self.title = title
		}
		else
		{
			// There were no objects encoded with the key "title",
			// so that's an error.
			return nil
		}
		
		// Check if the key "done" exists, since decodeBool() always succeeds
		if aDecoder.containsValue(forKey: "done")
		{
			self.done = aDecoder.decodeBool(forKey: "done")
		}
		else
		{
			// Same problem as above
			return nil
		}
	}
	
	func encode(with aCoder: NSCoder)
	{
		// Store the objects into the coder object
		aCoder.encode(self.title, forKey: "title")
		aCoder.encode(self.done, forKey: "done")
	}
}

extension ListItem {
	
	public class func getMockData() -> [ListItem] {
		return [
			ListItem(title: "Milk"),
			ListItem(title: "Chocolate"),
			ListItem(title: "Light bulb"),
			ListItem(title: "Dog food")
		]
	}
}


extension String {
	func substring(with nsrange: NSRange) -> String? {
		guard let range = Range(nsrange, in: self) else { return nil }
		return String(self[range])
	}
}


// Creates an extension of the Collection type (aka an Array),
// but only if it is an array of ToDoItem objects.
extension Collection where Iterator.Element == ListItem
{
	// Builds the persistence URL. This is a location inside
	// the "Application Support" directory for the App.
	private static func persistencePath() -> URL?
	{
		let url = try? FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true)
		
		return url?.appendingPathComponent("todoitems.bin")
	}
	
	// Write the array to persistence
	func writeToPersistence() throws
	{
		if let url = Self.persistencePath(), let array = self as? NSArray
		{
			let data = NSKeyedArchiver.archivedData(withRootObject: array)
			try data.write(to: url)
		}
		else
		{
			throw NSError(domain: "com.example.MyToDo", code: 10, userInfo: nil)
		}
	}
	
	// Read the array from persistence
	static func readFromPersistence() throws -> [ListItem]
	{
		if let url = persistencePath(), let data = (try Data(contentsOf: url) as Data?)
		{
			if let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ListItem]
			{
				return array
			}
			else
			{
				throw NSError(domain: "com.example.MyToDo", code: 11, userInfo: nil)
			}
		}
		else
		{
			throw NSError(domain: "com.example.MyToDo", code: 12, userInfo: nil)
		}
	}
}
