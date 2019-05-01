//
//  ProductTableViewCell.swift
//  SmartCart
//
//  Created by Kushol Bhattacharjee on 3/5/19.
//  Copyright © 2019 Kushol Bhattacharjee. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var idLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
