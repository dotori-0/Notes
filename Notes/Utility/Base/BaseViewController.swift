//
//  BaseViewController.swift
//  Notes
//
//  Created by SC on 2022/09/01.
//

import UIKit

import SnapKit

class BaseViewController: UIViewController {
    
    // MARK: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        setConstraints()
        setActions()
    }
    
    func setUI() {
        view.backgroundColor = .systemBackground
    }
    
    func setConstraints() { }
    
    func setActions() { }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}
