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


    override func setUI() {
        print(#function)
        
        title = "1234개의 메모"
        
        guard navigationController != nil else {
            print("no navigation controller")
            return
        }
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = notesView.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func setConstraints() {
        
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
//            label.text = section == 0 ? "고정된 메모" : "메모"
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
            cell.titleLabel.text = filteredNotes[indexPath.row].title
            cell.contentsLabel.text = filteredNotes[indexPath.row].contents
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
