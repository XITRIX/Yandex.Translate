//
//  TranslateAPI.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 18/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import Foundation

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
    }
    
    static func recogniseLanguage(text: String, completion: ((Language?)->Void)?) {
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
                        completion?(Language(rawValue: lang))
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
    
    static func translateText(_ text: String, completion: ((String?, Language?, Language?)->Void)?) {
        recogniseLanguage(text: text) { (fromLang) in
            let toLang = fromLang?.opposit
            
            var lang: String = ""
            if let toLang = toLang {
                lang = "\(toLang.opposit.rawValue)-\(toLang.rawValue)"
            } else {
                lang = Language.first.rawValue
            }
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
                            completion?(text.first, fromLang, toLang)
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
