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
    
    let walkthroughBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        return view
    }()
    
    let walkthroughPopUp: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 30
        return view
    }()
    
    let walkthroughLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Strings.walkthrough
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    let okButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 12
        button.backgroundColor = .systemOrange
        button.setTitle("확인", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        return button
    }()
    
    //    @objc var writeButtonHandler: (() -> Void)?
    //
    //    let toolbar: UIToolbar = {
    //        let toolbar = UIToolbar()
    //        let spaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: NotesViewController.self, action: nil)
    //        let writeBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: NotesViewController.self, action: #selector(getter: writeButtonHandler))
    //        toolbar.setItems([spaceBarButtonItem, writeBarButtonItem], animated: true)
    //        return toolbar
    //    }()
    
    
    
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
//        addSubview(toolbar)
        
        if !UserDefaultsHelper.standard.isExistingUser {
            setWalkthroughPopUp()
        }
    }
    
    override func setConstraints() {
        // NotesView에서 레이아웃 잡은 후 NotesViewController에서 updateConstraints 하면 Updated constraint could not find existing matching constraint to update 런타임 에러
//        tableView.snp.makeConstraints { make in
//            make.edges.equalTo(safeAreaLayoutGuide)
//        }
//
//        toolbar.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
//        }
//        toolbar.updateConstraintsIfNeeded()  // 실행하면 LayoutConstraints 오류가 2개에서 1개로 줄어드는 이유? 오류를 없앨 수 있는 방법?
    }
    
    func setWalkthroughPopUp() {
        [walkthroughLabel, okButton].forEach {
            walkthroughPopUp.addSubview($0)
        }
        walkthroughBackground.addSubview(walkthroughPopUp)
        
        walkthroughLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.equalTo(240)
        }
        
        okButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(okButton.snp.width).multipliedBy(0.2)
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        
        walkthroughPopUp.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(walkthroughPopUp.snp.width)
            make.center.equalToSuperview()
        }
        
        okButton.addTarget(self, action: #selector(okButtonClicked), for: .touchUpInside)
    }
    
    @objc func okButtonClicked() {
        walkthroughBackground.removeFromSuperview()
        UserDefaultsHelper.standard.isExistingUser = true
    }
}
