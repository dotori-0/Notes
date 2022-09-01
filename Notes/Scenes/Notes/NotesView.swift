//
//  NotesView.swift
//  Notes
//
//  Created by SC on 2022/09/01.
//

import UIKit

class NotesView: BaseView {
    
    // MARK: - Properties
    
    let searchController: UISearchController = {
        let controller = UISearchController()
        controller.searchBar.placeholder = "검색"
        controller.searchBar.setValue("취소", forKey: "cancelButtonText")
        controller.searchBar.becomeFirstResponder()
        return controller
    }()
    
    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(NotesTableViewCell.self, forCellReuseIdentifier: NotesTableViewCell.reuseIdentifier)
        return view
    }()
    
    
    
    
    // MARK: - Functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUI() {
        super.setUI()
        
        addSubview(tableView)
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
