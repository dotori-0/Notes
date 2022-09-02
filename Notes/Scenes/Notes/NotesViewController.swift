//
//  NotesViewController.swift
//  Notes
//
//  Created by SC on 2022/09/01.
//

import UIKit

class NotesViewController: BaseViewController {
    
    // MARK: - Properties
    
    let notesView = NotesView()
    var allNotes = [Notes(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))"),
                    Notes(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))"),
                    Notes(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))"),
                    Notes(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))"),
                    Notes(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))"),
                    Notes(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))"),
                    Notes(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))")]
    var filteredNotes: [Notes] = []
    
    var isSearchBarEmpty: Bool {
        return notesView.searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return notesView.searchController.isActive && !isSearchBarEmpty
    }
    
    var searchText = ""
    
    let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        let spaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: NotesViewController.self, action: nil)
        let writeBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(writeButtonClicked))
        // writeBarButtonItem에서 target을 NotesViewController.self로 하면 아래의 런타임 에러가 나는 이유?
        // Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '+[Notes.NotesViewController writeButtonClicked]: unrecognized selector sent to class 0x10253f048'
        toolbar.setItems([spaceBarButtonItem, writeBarButtonItem], animated: true)
        toolbar.isTranslucent = false
//        toolbar.barTintColor = .systemGray6
//        toolbar.clipsToBounds = true  // separator 없애기 위해 추가했지만 툴바 높이 44를 제외한 인디케이터 영역을 채우지 못함
        
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .systemGray6
        
        if #available(iOS 15.0, *) {
//            toolbar.scrollEdgeAppearance = appearance
            toolbar.standardAppearance = appearance
        }
        
        
        
        return toolbar
    }()
    
    
    // MARK: - Functions
    
    override func loadView() {
        view = notesView
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        notesView.tableView.dataSource = self
        notesView.tableView.delegate = self
        
//        view.addSubview(notesView.toolBar)
//        notesView.toolBar.delegate = self
        notesView.searchController.searchResultsUpdater = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = true
    }


    override func setUI() {
        title = "1234개의 메모"
        
        guard navigationController != nil else {
            print("no navigation controller")
            return
        }
//        navigationController?.navigationBar.prefersLargeTitles = true  // viewWillAppear로 옮김(WriteViewController에 false로 지정되어 있어 WriteViewController로 갔다가 돌아 오면 네비게이션 타이틀이 작아져 있음)
        navigationItem.searchController = notesView.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemGray6
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        notesView.addSubview(toolbar)
    }
    
    
    override func setConstraints() {
        toolbar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(notesView.safeAreaLayoutGuide)
        }
        toolbar.updateConstraintsIfNeeded()  // NotesView가 아니라 여기에서는 실행해도 LayoutConstraints 오류가 2개에서 1개로 줄어들지 않는 이유? 오류를 없앨 수 있는 방법?
    }
    
    
    override func setActions() {
        // NotesView에 toolbar 선언 후 handler를 뷰컨으로부터 bar button item의 action으로 넘기기
        let handler: () -> Void = { self.transition(to: WriteViewController(), transitionStyle: .push) }
        notesView.writeButtonHandler = handler
        // 런타임 에러
        // Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '+[Notes.NotesViewController writeButtonHandler]: unrecognized selector sent to class 0x104417008'
    }
    
        
    @objc func writeButtonClicked() {
        transition(to: WriteViewController(), transitionStyle: .push)
    }

    
    func filterNotesForSearchText(searchText: String) {
        filteredNotes = allNotes.filter({ note in
            return note.title.contains(searchText) || note.contents.contains(searchText)
        })
        
        notesView.tableView.reloadData()
    }
}


extension NotesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isFiltering ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let headerTitleLabel: UILabel = {
            let label = UILabel()
            label.font = .boldSystemFont(ofSize: 22)
            return label
        }()
        
        if isFiltering {
            headerTitleLabel.text = "\(filteredNotes.count) 개 찾음"
        } else {
            headerTitleLabel.text = section == 0 ? "고정된 메모" : "메모"
        }
        
        headerView.addSubview(headerTitleLabel)
        
        headerTitleLabel.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        print("🐹 \(UIScreen.main.bounds.height)")  // 🐹 896.0
        return 50  // 약 0.18배
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isFiltering {
            return section == 0 ? 2 : allNotes.count
        } else {
            return filteredNotes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotesTableViewCell.reuseIdentifier) as? NotesTableViewCell else {
            print("Cannot find NotesTableViewCell")
            return UITableViewCell()
        }
        
//        cell.titleLabel.text = "타이틀\(indexPath.row)"
//        cell.dateAndTimeLabel.text = "2022.09.01"
//        cell.contentsLabel.text = "\(Int.random(in: 1...5))"
        
        cell.dateAndTimeLabel.text = "2022.09.01"
           
        if isFiltering {
//            cell.titleLabel.text = filteredNotes[indexPath.row].title
//            cell.contentsLabel.text = filteredNotes[indexPath.row].contents
            
//            var tintColor: UIColor
//            if #available(iOS 15.0, *) {  // 'tintColor' is only available in iOS 15.0 or newer
//                tintColor = .tintColor
//            } else {
//                // Fallback on earlier versions
//                tintColor = UIColor.systemOrange
//            }
            
            guard !filteredNotes.isEmpty else { return UITableViewCell() }
            
            let filteredNoteTitle = filteredNotes[indexPath.row].title
//            let attributedTitle = NSMutableAttributedString(string: filteredNoteTitle)
//            attributedTitle.addAttribute(.foregroundColor, value: tintColor, range: (filteredNoteTitle as NSString).range(of: searchText))
            
            let filteredNoteContents = filteredNotes[indexPath.row].contents
//            let attributedContents = NSMutableAttributedString(string: filteredNoteContents)
//            attributedContents.addAttribute(.foregroundColor, value: tintColor, range: (filteredNoteContents as NSString).range(of: searchText))
            
            cell.titleLabel.attributedText = filteredNoteTitle.addAttribute(to: searchText)
            cell.contentsLabel.attributedText = filteredNoteContents.addAttribute(to: searchText)
        } else {
            cell.titleLabel.text = allNotes[indexPath.row].title
            cell.contentsLabel.text = allNotes[indexPath.row].contents
        }

        return cell
    }
}


extension NotesViewController: UISearchBarDelegate {
    
}

extension NotesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            print("no text")
            return
        }
        
        searchText = text
        filterNotesForSearchText(searchText: text)
    }
}


extension NotesViewController: UISearchControllerDelegate {
    
}


//extension NotesViewController: UIToolbarDelegate {
//    func position(for bar: UIBarPositioning) -> UIBarPosition {
//        return .bottom
//    }
//}
