//
//  CollectionViewController.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 18/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import UIKit

class TranslateViewController : UICollectionViewController, TranslateView {
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
        
        translationInputView.delegate = self
        collectionView.setCollectionViewLayout(RevercedCollectionViewFlowLayout(), animated: false)
        navigationItem.titleView = UIImageView(image: UIImage(named: "YandexTitle"))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            if (keyboardRectangle.height != translationInputView.frame.height),
                presenter.translationsCount > 0 {
                collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
            }
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
              cell.setupConstraints(collectionViewWidth: view.safeAreaLayoutGuide.layoutFrame.width)
        }
        return presenter.getTranslation(at: indexPath.row).calculateCellSize(collectionViewWidth: view.safeAreaLayoutGuide.layoutFrame.width)
    }
}

extension TranslateViewController: TranslateInputViewDelegate {
    func translate(_ text: String, completion: ((TranslateAPI.Language?) -> Void)?) {
        presenter.translate(text: text, from: translationInputView.primaryLanguage) { fromLang in
            completion?(fromLang)
        }
    }
}

protocol TranslateView {
    func handleCollectionUpdate()
}
