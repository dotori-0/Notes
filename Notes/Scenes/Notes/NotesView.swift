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
        let controller = UISearchController(searchResultsController: nil)
        // By initializing UISearchController with a nil value for searchResultsController, you’re telling the search controller that you want to use the same view you’re searching to display the results.
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
    
    @objc var writeButtonHandler: (() -> Void)?
    
    let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        let spaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: NotesViewController.self, action: nil)
        let writeBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: NotesViewController.self, action: #selector(getter: writeButtonHandler))
        toolbar.setItems([spaceBarButtonItem, writeBarButtonItem], animated: true)
        return toolbar
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
        addSubview(toolbar)
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        toolbar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
//            make.height.equalTo(44)
        }
        toolbar.updateConstraintsIfNeeded()  // 실행하면 LayoutConstraints 오류가 2개에서 1개로 줄어드는 이유? 오류를 없앨 수 있는 방법?
    }
}
