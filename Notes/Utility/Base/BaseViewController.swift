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
}
