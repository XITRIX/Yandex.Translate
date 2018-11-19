//
//  TranslatePresenter.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 19/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import Foundation


class TranslatePresenter: TranslateViewPresenter {
    let view: TranslateView
    var translations: [MessageViewModel] = []
    var translationsCount: Int {
        return translations.count
    }
    
    required init(view: TranslateView) {
        self.view = view
    }
    
    func getTranslation(at: Int) -> MessageViewModel {
        return translations[at]
    }
    
    
    func translate(text: String) {
        TranslateAPI.translateText(text, completion: { [weak self] (res, from, to) in
            if let self = self,
                let res = res {
                self.translations.insert(MessageViewModel(isLeft: from != TranslateAPI.Language.first, title: text, message: res), at: 0)
                self.view.handleCollectionUpdate()
            }
        })
    }
}

protocol TranslateViewPresenter {
    init(view: TranslateView)
    var translationsCount: Int { get }
    func getTranslation(at: Int) -> MessageViewModel
    func translate(text: String)
}
