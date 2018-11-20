//
//  TranslateAPI.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 18/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import UIKit

class TranslateAPI {
    enum Language: String {
        case first = "ru"
        case second = "en"
        
        var opposit: Language {
            if self == .first {
                return .second
            } else {
                return .first
            }
        }
        
        var color: UIColor {
            if self == .first {
                return UIColor(red: 0.93, green: 0.3, blue: 0.36, alpha: 1)
            } else {
                return UIColor(red: 0, green: 0.49, blue: 0.91, alpha: 1)
            }
        }
        
        var title: String {
            if self == .first {
                return "Русский"
            } else {
                return "Английский"
            }
        }
        
        var locale: Locale {
            if self == .first {
                return Locale.init(identifier: "ru_RU")
            } else {
                return Locale.init(identifier: "en-US")
            }
        }
    }
    
    static func recogniseLanguage(text: String, completion: @escaping (Language?)->()) {
        let url = "https://translate.yandex.net/api/v1.5/tr.json/detect"
        var request = URLRequest(url: URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
        request.httpMethod = "POST"
        let postString = "key=\(ApiKeys.apiKey)&text=\(text.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)&hint=\(Language.first.rawValue),\(Language.second.rawValue)"
        request.httpBody = postString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard let data = data else { return }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                guard let json = jsonResponse as? [String: Any],
                    let code = json["code"] as? Int,
                    let lang = json["lang"] as? String
                else { return }
                
                switch (code) {
                case 200:
                    DispatchQueue.main.async {
                        completion(Language(rawValue: lang))
                    }
                    break
                default:
                    break
                }
            } catch let error {
                print("Error", error)
            }
        }.resume()
    }
    
    static func translateText(_ text: String, from: Language, completion: @escaping (String?, Language?, Language?)->()) {
        recogniseLanguage(text: text) { (fromLang) in
            let fromLang = fromLang ?? from
            let toLang = fromLang.opposit
            
            let lang = "\(fromLang.rawValue)-\(toLang.rawValue)"
            let url = "https://translate.yandex.net/api/v1.5/tr.json/translate"
            var request = URLRequest(url: URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
            request.httpMethod = "POST"
            let postString = "key=\(ApiKeys.apiKey)&text=\(text.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)&lang=\(lang)"
            request.httpBody = postString.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }
                guard let data = data else { return }
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let json = jsonResponse as? [String: Any],
                        let code = json["code"] as? Int,
//                        let lang = json["lang"] as? String,
                        let text = json["text"] as? [String]
                        else { return }
                    
                    switch (code) {
                    case 200:
                        DispatchQueue.main.async {
                            completion(text.first, fromLang, toLang)
                        }
                        break
                    default:
                        break
                    }
                } catch let error {
                    print("Error", error)
                }
                }.resume()
        }
    }
}
