//
//  NotesTableViewCell.swift
//  Notes
//
//  Created by SC on 2022/09/01.
//

import UIKit

class NotesTableViewCell: BaseTableViewCell {
    
    // MARK: - Properties
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
//        label.backgroundColor = .systemGray4
        return label
    }()
    
    let dateAndTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
//        label.backgroundColor = .systemIndigo
//        label.sizeToFit()
        return label
    }()
    
    let contentsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
//        label.backgroundColor = .systemBrown
        label.numberOfLines = 1
        return label
    }()
    
    // 기존 [{(Label and another Label) in UIView} and the other Label] in StackView 시도
    let dateAndTimeAndContentsView: UIView = {
        let view = UIView()
//        view.backgroundColor = .systemGreen
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, dateAndTimeAndContentsView])
        view.spacing = 4
        view.distribution = .fillEqually
        view.axis = .vertical
        view.alignment = .leading
//        view.backgroundColor = .systemGreen
        return view
    }()
     
    
    // MARK: - Functions

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUI() {
        // 기존 [{(Label and another Label) in UIView} and the other Label] in StackView 시도
        [dateAndTimeLabel, contentsLabel].forEach {
            dateAndTimeAndContentsView.addSubview($0)
        }
        
        contentView.addSubview(stackView)
        
        
        // 3 Labels in contentView 시도
        /*
         [titleLabel, dateAndTimeLabel, contentsLabel].forEach {
             contentView.addSubview($0)
         }
         */
    }
    
    override func setConstraints() {
        // 기존 [{(Label and another Label) in UIView} and the other Label] in StackView 시도
        dateAndTimeLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        dateAndTimeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        contentsLabel.snp.makeConstraints { make in
//            make.trailing.lessThanOrEqualToSuperview().priority(199)  // 적용 X
//            make.trailing.lessThanOrEqualTo(stackView.snp.trailing)  // 적용 X
//            make.trailing.equalTo(stackView)
            make.leading.equalTo(dateAndTimeLabel.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        
        
        // 3 Labels in contentView 시도
        /*
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
            make.bottom.equalTo(contentView.snp.centerY).offset(-2)
        }
        
        dateAndTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.top.equalTo(contentView.snp.centerY).offset(2)
        }
        dateAndTimeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        contentsLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateAndTimeLabel.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
            make.centerY.equalTo(dateAndTimeLabel)
        }
        */
    }
}
