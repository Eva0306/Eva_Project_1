//
//  ProductListDataModel.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/22.
//

import UIKit

enum Category: String {
    case women = "women"
    case men = "men"
    case accessories = "accessories"
}

struct ProductListDataModel: Codable {
    var data: [Product]
    var nextPaging: Int?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextPaging = "next_paging"
    }
}

struct Product: Codable {
    let id: Int
    let category: String
    let title: String
    let description: String
    let price: Int
    let texture: String
    let wash: String
    let place: String
    let note: String
    let story: String
    let mainImage: String
    let images: [String]
    let variants: [Variant]
    let colors: [Color]
    let sizes: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, category, title, description, price, texture, wash, place, note, story
        case mainImage = "main_image"
        case images, variants, colors, sizes
    }
}

struct Variant: Codable {
    let colorCode: String
    let size: String
    let stock: Int
    
    enum CodingKeys: String, CodingKey {
        case colorCode = "color_code"
        case size, stock
    }
}

struct Color: Codable {
    let code: String
    let name: String
}

class SharedData {
    static let shared = SharedData()
    var product: [Product] = []
    
    var cache: [Category: ProductListDataModel] = [:]
    
    private init() {}
}
