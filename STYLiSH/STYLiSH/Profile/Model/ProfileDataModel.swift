//
//  ProfileDataModel.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/23.
//

import UIKit

struct SignInResponse: Codable {
    let data: DataResponse
}

struct DataResponse: Codable {
    let accessToken: String
    //let accessExpired: Int
    //let user: User
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        //case accessExpired = "access_expired"
        //case user
    }
}

//struct User: Codable {
//    let id: Int
//    let provider: String
//    let name: String
//    let email: String?
//    let picture: String
//}

class ItemContent {
    let image: UIImage
    var name: String
    
    init(image: UIImage, name: String) {
        self.image = image
        self.name = name
    }
}

struct UserProfileRequest: Codable {
    let data: UserData
}

struct UserData: Codable {
    let provider: String
    let name: String
    let email: String
    let picture: String
}

var myOrder: [ItemContent] = [
    ItemContent(image: UIImage(named: "Icons_24px_AwaitingPayment")!, name: "待付款"),
    ItemContent(image: UIImage(named: "Icons_24px_AwaitingShipment")!, name: "待出貨"),
    ItemContent(image: UIImage(named: "Icons_24px_Shipped")!, name: "待簽收"),
    ItemContent(image: UIImage(named: "Icons_24px_AwaitingReview")!, name: "待評價"),
    ItemContent(image: UIImage(named: "Icons_24px_Exchange")!, name: "退換貨")
]

var moreService: [ItemContent] = [
    ItemContent(image: UIImage(named: "Icons_24px_Starred")!, name: "收藏"),
    ItemContent(image: UIImage(named: "Icons_24px_Notification")!, name: "貨到通知"),
    ItemContent(image: UIImage(named: "Icons_24px_Refunded")!, name: "帳戶退款"),
    ItemContent(image: UIImage(named: "Icons_24px_Address")!, name: "地址"),
    ItemContent(image: UIImage(named: "Icons_24px_CustomerService")!, name: "客服訊息"),
    ItemContent(image: UIImage(named: "Icons_24px_SystemFeedback")!, name: "系統回饋"),
    ItemContent(image: UIImage(named: "Icons_24px_RegisterCellphone")!, name: "手機綁定"),
    ItemContent(image: UIImage(named: "Icons_24px_Settings")!, name: "設定")
]

let localizationMyOrder: [String: String] = [
    "MyOrderItem1": "待付款",
    "MyOrderItem2": "待出貨",
    "MyOrderItem3": "待簽收",
    "MyOrderItem4": "待評價",
    "MyOrderItem5": "退換貨",
]

let localizationMoreService: [String: String] = [
    "MoreService1": "收藏",
    "MoreService2": "貨到通知",
    "MoreService3": "帳戶退款",
    "MoreService4": "地址",
    "MoreService5": "客服訊息",
    "MoreService6": "系統回饋",
    "MoreService7": "手機綁定",
    "MoreService8": "設定",
]
