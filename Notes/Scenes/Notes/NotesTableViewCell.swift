//
//  NotesTableViewCell.swift
//  Notes
//
//  Created by SC on 2022/09/01.
//

import UIKit

final class NotesTableViewCell: BaseTableViewCell {
    // MARK: - Properties
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    let dateAndTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    let contentsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    
    private let dateAndTimeAndContentsView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, dateAndTimeAndContentsView])
        view.spacing = 4
        view.distribution = .fillEqually
        view.axis = .vertical
        view.alignment = .leading
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
        [dateAndTimeLabel, contentsLabel].forEach {
            dateAndTimeAndContentsView.addSubview($0)
        }
        
        contentView.addSubview(stackView)
    }
    
    override func setConstraints() {
        dateAndTimeLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        dateAndTimeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        contentsLabel.snp.makeConstraints { make in
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
    }
}
