//
//  TranslateViewController.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 26/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import UIKit

class TranslateViewController: UITableViewController {
    @IBOutlet var translationInputView: TranslateInputView!
    var presenter: TranslateViewPresenter!
    
    override var inputAccessoryView: UIView? {
        return translationInputView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = TranslatePresenter(view: self)
        navigationItem.titleView = UIImageView(image: UIImage(named: "YandexTitle"))
        
        translationInputView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            if (keyboardRectangle.height != translationInputView.frame.height),
                presenter.translationsCount > 0 {
                tableView.scrollToRow(at: IndexPath(item: presenter.translationsCount - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
}

extension TranslateViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.translationsCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BubbleCell
        cell.update(viewModel: presenter.getTranslation(at: indexPath.row), tableViewWidth: view.safeAreaLayoutGuide.layoutFrame.width)
        return cell
    }
}

extension TranslateViewController: TranslateInputViewDelegate {
    func translate(_ text: String, completion: ((TranslateAPI.Language?) -> Void)?) {
        presenter.translate(text: text, from: translationInputView.primaryLanguage) { fromLang in
            completion?(fromLang)
        }
    }
}

extension TranslateViewController: TranslateView {
    func handleCollectionUpdate() {
        tableView.insertRows(at: [IndexPath(item: presenter.translationsCount - 1, section: 0)], with: .none)
        tableView.scrollToRow(at: IndexPath(item: presenter.translationsCount - 1, section: 0), at: .bottom, animated: true)
    }
}

protocol TranslateView {
    func handleCollectionUpdate()
}
