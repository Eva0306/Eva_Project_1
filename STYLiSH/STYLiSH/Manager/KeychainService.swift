//
//  KeychainService.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/8/7.
//

import Security
import KeychainAccess

class KeychainService {
    
    let keychain = Keychain(service: "com.Ruintelligence.STYLiSH")
    
    func saveToken(token: String) {
        do {
            try keychain.set(token, key: "accessToken")
            print("Token successfully saved.")
        } catch let error {
            print("Error saving token: \(error)")
        }
    }
    
    func getToken() -> String? {
        do {
            let token = try keychain.get("accessToken")
            return token
        } catch let error {
            print("Error retrieving token: \(error)")
            return nil
        }
    }
    
    func deleteToken() {
        do {
            try keychain.remove("accessToken")
            print("Token successfully deleted.")
        } catch let error {
            print("Error deleting token: \(error)")
        }
    }
}
