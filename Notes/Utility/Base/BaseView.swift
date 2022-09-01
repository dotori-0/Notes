//
//  BaseView.swift
//  Notes
//
//  Created by SC on 2022/09/01.
//

import UIKit

class BaseView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        backgroundColor = .systemBackground
    }
    
    func setConstraints() {
        
    }
    
}
