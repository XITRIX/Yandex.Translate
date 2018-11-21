//
//  LanguageSwitcher.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 19/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import UIKit

class TranslateInputView: UIView {
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainFlag: UIImageView!
    @IBOutlet weak var secondaryFlag: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    @IBOutlet weak var languageSwitcher: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(changeLanguageAction))
            languageSwitcher.addGestureRecognizer(tap)
        }
    }
    
    var delegate: TranslateInputViewDelegate?
    var primaryLanguage: TranslateAPI.Language = .second
    
    private var voiceBufferText: String?
    
    @objc func changeLanguageAction() {
        primaryLanguage = primaryLanguage.opposit
        UIView.animate(withDuration: 0.2) {
            self.updateViewToLanguage()
        }
    }
    
    func updateViewToLanguage() {
        let zBuf = self.mainFlag.layer.zPosition
        self.mainFlag.layer.zPosition = self.secondaryFlag.layer.zPosition
        self.secondaryFlag.layer.zPosition = zBuf
        
        let buf = self.mainFlag.frame
        self.mainFlag.frame = self.secondaryFlag.frame
        self.secondaryFlag.frame = buf
        
        self.background.backgroundColor = self.primaryLanguage.color
        
        if self.textField.text?.isEmpty ?? false,
            !self.textField.isEditing {
            self.textField.placeholder = self.primaryLanguage.title
        }
    }
    
    @IBAction func textFieldEdited(_ sender: UITextField) {
        sendButton.setImage((textField.text?.isEmpty ?? true) ? #imageLiteral(resourceName: "Mic") : #imageLiteral(resourceName: "Send"), for: .normal)
    }
    
    @IBAction func sendAction(_ sender: UIButton) {
        if !SpeechRecognition.isRecognising(), // Send text to translate
            let text = textField.text,
            !text.isEmpty {
            delegate?.translate(text) { [weak self = self] lang in
                if let self = self,
                    let lang = lang,
                    self.primaryLanguage != lang {
                    self.primaryLanguage = lang
                    UIView.animate(withDuration: 0.2) {
                        self.updateViewToLanguage()
                    }
                }
            }
            textField.text = ""
            textFieldEdited(textField)
        } else { // Send voice to translate
            if !SpeechRecognition.isRecognising() {
                textField.resignFirstResponder()
                textField.placeholder = "Говорите..."
                textField.isEnabled = false
                sendButton.setImage(#imageLiteral(resourceName: "Send"), for: .normal)
                SpeechRecognition.recordAndRecognizeSpeech(language: primaryLanguage) { [weak self = self] result, error in
                    if let self = self,
                        let result = result {
                        self.voiceBufferText = result
                        self.textField.text = "\(result)..."
                    }
                }
            } else {
                SpeechRecognition.stopRecognition()
                textField.placeholder = primaryLanguage.title
                textField.text = ""
                textField.isEnabled = true
                sendButton.setImage(#imageLiteral(resourceName: "Mic"), for: .normal)
                if let text = voiceBufferText {
                    delegate?.translate(text, completion: nil)
                }
                voiceBufferText = nil
            }
        }
    }
}

extension TranslateInputView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty ?? true) {
            textField.placeholder = "Введите текст"
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty ?? true) {
            textField.placeholder = primaryLanguage.title
        }
    }
}

protocol TranslateInputViewDelegate {
    func translate(_ text: String, completion: ((TranslateAPI.Language?) -> Void)?)
}
