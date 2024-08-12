//
//  MarketManager.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/18.
//

import Foundation

protocol MarketManagerDelegate {

    func manager(_ manager: MarketManager, didGet marketingHots: MarketingHotsData)

    func manager(_ manager: MarketManager, didFailWith error: Error)
}

class MarketManager {
    
    let url = URL(string:"https://api.appworks-school.tw/api/1.0/marketing/hots")!
    
    var delegate: MarketManagerDelegate?
    
    func getMarketingHots() {
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.manager(self, didFailWith: error)
                }
            }
            
            if let data {
                let decoder = JSONDecoder()
                do {
                    let marketingHotsData = try decoder.decode(MarketingHotsData.self, from: data)
                    DispatchQueue.main.async {
                        self.delegate?.manager(self, didGet: marketingHotsData)
                    }
                    print(data)
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.manager(self, didFailWith: error)
                    }
                }
            }
        }
        task.resume()
    }
}
