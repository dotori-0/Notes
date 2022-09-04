//
//  WriteView.swift
//  Notes
//
//  Created by SC on 2022/09/02.
//

import UIKit

class WriteView: BaseView {
    let textView: UITextView = {
        let view = UITextView()
        view.font = .boldSystemFont(ofSize: 15)
//        view.becomeFirstResponder()
        return view
    }()
    
    let testLabel: UILabel = {
        let label = UILabel()
        label.text = "Test"
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUI() {
        addSubview(textView)
        addSubview(testLabel)
    }
    
    override func setConstraints() {
        textView.snp.makeConstraints { make in
//            make.edges.equalTo(safeAreaLayoutGuide)
//            make.edges.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(22)
            make.top.bottom.equalToSuperview()
//            make.top.equalToSuperview()
//            make.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        testLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
