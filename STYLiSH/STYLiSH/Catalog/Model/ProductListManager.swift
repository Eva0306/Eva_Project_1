//
//  ProductListManager.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/23.
//

import Foundation
import Alamofire

protocol ProductListDelegate {

    func manager(_ manager: ProductListManager, didGet productList: ProductListDataModel, isRefresh: Bool, isLoadMore: Bool)

    func manager(_ manager: ProductListManager, didFailWith error: Error)
}

class ProductListManager {
    
    let url = "https://api.appworks-school.tw/api/1.0/products/"
    
    var delegate: ProductListDelegate?
    
    func getProductList(for category: Category, in page: Int, isRefresh: Bool, isLoadMore: Bool, completion: ((Result<ProductListDataModel, Error>) -> Void)? = nil) {
        
        if !isLoadMore && !isRefresh {
            if let cachedProducts = SharedData.shared.cache[category] {
                DispatchQueue.main.async {
                    self.delegate?.manager(self, didGet: cachedProducts, isRefresh: isRefresh, isLoadMore: isLoadMore)
                    completion?(.success(cachedProducts))
                }
                return
            }
        }
        
        let URLString = "\(url)\(category.rawValue)?paging=\(String(page))"
        
        AF.request(URLString).responseDecodable(of: ProductListDataModel.self) { response in
            switch response.result {
            case .success(let data):
                if isLoadMore {
                    SharedData.shared.cache[category]?.data.append(contentsOf: data.data)
                    SharedData.shared.cache[category]?.nextPaging = data.nextPaging
                } else {
                    SharedData.shared.cache[category] = data
                }
                DispatchQueue.main.async {
                    self.delegate?.manager(self, didGet: data, isRefresh: isRefresh, isLoadMore: isLoadMore)
                    completion?(.success(data))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.manager(self, didFailWith: error)
                    completion?(.failure(error))
                }
            }
        }
    }
    
    
    
}
