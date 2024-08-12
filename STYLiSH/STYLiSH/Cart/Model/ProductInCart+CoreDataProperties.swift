//
//  ProductInCart+CoreDataProperties.swift
//  
//
//  Created by 楊芮瑊 on 2024/8/1.
//
//

import Foundation
import CoreData


extension ProductInCart {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductInCart> {
        return NSFetchRequest<ProductInCart>(entityName: "ProductInCart")
    }

    @NSManaged public var title: String?
    @NSManaged public var price: Int32
    @NSManaged public var size: String?
    @NSManaged public var colorCode: String?
    @NSManaged public var colorName: String?
    @NSManaged public var image: String?
    @NSManaged public var stock: Int32
    @NSManaged public var amount: Int32
    @NSManaged public var id: Int64

}
