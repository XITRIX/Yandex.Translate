//
//  CollectionViewController.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 18/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import UIKit

class TranslateViewController : UICollectionViewController, TranslateView {
    @IBOutlet var textFieldViewHolder: UIView!
    @IBOutlet weak var textField: UITextField!
    
    var presenter: TranslateViewPresenter!
    
    override var inputAccessoryView: UIView? {
        return textFieldViewHolder
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = TranslatePresenter(view: self)
        
        collectionView.setCollectionViewLayout(RevercedCollectionViewFlowLayout(), animated: false)
        navigationItem.titleView = UIImageView(image: UIImage(named: "YandexTitle"))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            if (keyboardRectangle.height != textFieldViewHolder.frame.height),
                presenter.translationsCount > 0 {
                collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        if let text = textField.text,
            !text.isEmpty {
            presenter.translate(text: text)
            textField.text = ""
        }
    }
    
    func handleCollectionUpdate() {
        self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
    }
    
}

extension TranslateViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.translationsCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BubbleCell", for: indexPath) as! BubbleCell
        cell.update(viewModel: presenter.getTranslation(at: indexPath.row), collectionViewWidth: view.frame.width)
        return cell
    }
}

extension TranslateViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let cell = collectionView.cellForItem(at: indexPath) as? BubbleCell {
            cell.setupConstraints(collectionViewWidth: view.frame.width)
        }
        return presenter.getTranslation(at: indexPath.row).calculateCellSize(collectionViewWidth: view.frame.width)
    }
}

protocol TranslateView {
    func handleCollectionUpdate()
}
