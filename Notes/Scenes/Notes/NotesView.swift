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
        return controller
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
    }

    override func setConstraints() {
        
    }
}
