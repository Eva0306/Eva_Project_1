//
//  MarketingHotsDataModel.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/18.
//

import UIKit

struct MarketingHotsData: Codable {
    let data: [MarketingHots]
}

struct MarketingHots: Codable {
    let title: String
    let products: [Product]
}

enum Size: String, Codable {
    case f = "F"
    case l = "L"
    case m = "M"
    case s = "S"
    case xl = "XL"
}
