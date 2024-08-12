//
//  LocalizationManager.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/8/8.
//

import UIKit

enum Language: String {
        case english = "en-US"
        case chineseT = "zh-Hant"
        case system = "system"
}

class LocalizationManager {
    
    static let shared = LocalizationManager()
    
    private init() {}
    
    var languageForBundle: Language = {
        if let systemLanguage = Locale.preferredLanguages.first {
            if systemLanguage.hasPrefix("zh") {
                return .chineseT
            }
        }
        return .english
    }()
    
    var language: Language = {
        // read saved language
        let languageString = UserDefaults.standard.string(forKey: "language")
        if let language = Language(rawValue: languageString ?? "") {
            return language
        }
        // no saved so read system
        return .system
    }(){
        didSet {
            UserDefaults.standard.setValue(language.rawValue, forKey: "language")
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    
    func strWithKey(key: String) -> String? {
        var resource: String
        
        if self.language == .system {
            resource = self.languageForBundle.rawValue
        } else {
            resource = self.language.rawValue
        }
        
        guard let path = Bundle.main.path(forResource: resource, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            print("Bundle not found for resource: \(resource)")
            return key
        }
        
        let str = bundle.localizedString(forKey: key, value: "", table: nil)
        
        if str == key {
            print("Key \(key) not found in \(resource)")
        }
        
        return str
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
