//
//  NotesViewController.swift
//  Notes
//
//  Created by SC on 2022/09/01.
//

import UIKit
import RealmSwift

class NotesViewController: BaseViewController {
    
    // MARK: - Properties
    
    let notesView = NotesView()
    
    let repository = NotesRepository()
    
    var allDummyNotes = [NotesModel(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))"),
                    NotesModel(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))"),
                    NotesModel(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))"),
                    NotesModel(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))"),
                    NotesModel(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))"),
                    NotesModel(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))"),
                    NotesModel(title: "타이틀\(Int.random(in: 1...5))", contents: "\(Int.random(in: 1...100))")]
    var allNotes: Results<Note>! {
        didSet {
            print("Notes Changed")
            notesView.tableView.reloadData()
        }
    }
    var filteredNotes: [Note] = []
//    var filteredNotes: Results<Note>!
    
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
        
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        fetchRealm()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        navigationController?.navigationBar.prefersLargeTitles = false  // prefersLargeTitles = false는 뷰 전환 후에도 Large Title이 잠시 남아 있는 문제 있음
    }


    override func setUI() {
        print("💙", #function)
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
        let handler: () -> Void = { self.transition(to: WriteViewController()) }
        notesView.writeButtonHandler = handler
        // 런타임 에러
        // Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '+[Notes.NotesViewController writeButtonHandler]: unrecognized selector sent to class 0x104417008'
    }
    
        
    @objc func writeButtonClicked() {
        transition(to: WriteViewController())
    }
    
    
    func fetchRealm() {
        allNotes = repository.fetch()
    }

    
    func filterNotesForSearchText(searchText: String) {
        filteredNotes = allDummyNotes.filter({ note in
            return note.title.contains(searchText) || note.contents.contains(searchText)
        })
        
        notesView.tableView.reloadData()
    }
}


extension NotesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
//        return isFiltering ? 1 : 2
        return 1
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
//            headerTitleLabel.text = section == 0 ? "고정된 메모" : "메모"
            headerTitleLabel.text = "메모"
        }
        
        headerView.addSubview(headerTitleLabel)
        
        headerTitleLabel.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        print("🐹 \(UIScreen.main.bounds.height)")  // 🐹 896.0
        return 50  // 약 0.18배
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredNotes.count : allNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotesTableViewCell.reuseIdentifier) as? NotesTableViewCell else {
            print("Cannot find NotesTableViewCell")
            return UITableViewCell()
        }
        
//        cell.tag = indexPath.row
        
        cell.dateAndTimeLabel.text = "2022.09.01"
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko-KR")
        let calendar = Calendar.current
        
        print(isFiltering)

           
        if isFiltering {
            guard !filteredNotes.isEmpty else { return UITableViewCell() }
            
            let filteredNoteTitle = filteredNotes[indexPath.row].title
            let filteredNoteContents = filteredNotes[indexPath.row].contents?.trimAllNewLines()
//            let filteredNoteTitle = allNotes[cell.tag].title
//            let filteredNoteContents = allNotes[cell.tag].contents?.trimAllNewLines()
            print("💞 filteredNotes: \(filteredNotes)")
            
            cell.titleLabel.attributedText = filteredNoteTitle.addAttribute(to: searchText)
            cell.contentsLabel.attributedText = filteredNoteContents?.addAttribute(to: searchText)
//            filteredNotes[cell.tag].title = filteredNoteTitle.addAttribute(to: searchText).string
//            filteredNotes[cell.tag].contents = filteredNoteContents?.addAttribute(to: searchText).string
        } else {
//            print("🐤")
            guard !allNotes.isEmpty else { return UITableViewCell() }
            
            let note = allNotes[indexPath.row]
            
            let editDateComponent = calendar.dateComponents(in: .current, from: note.editDate)
            let weekOfEditDate = editDateComponent.weekOfYear
            
            let currentDateComponent = calendar.dateComponents(in: .current, from: Date())
            let weekOfToday = currentDateComponent.weekOfYear
        
            
            if calendar.isDateInToday(note.editDate) {
                formatter.dateFormat = "a hh:mm"
            } else if weekOfEditDate == weekOfToday {
                formatter.dateFormat = "EEEE"
            } else {
                formatter.dateFormat = "yyyy. MM. dd a hh:mm"
            }
            
//            print(note.title)
//            print(note.contents)
            
//            guard note.contents != nil else { return UITableViewCell() }
            
            guard let contentsNewLinesRemoved = note.contents?.trimAllNewLines() else { return UITableViewCell() }
//            print("✂️ \(contentsNewLinesRemoved)")
            
            let contentsLabelText = contentsNewLinesRemoved.isEmpty ? "추가 텍스트 없음" : contentsNewLinesRemoved
            // 내용으로 엔터만 쳤을 경우 note.contents가 Optional("\n\n\n\n\n\n\n")이기 때문에
            
            cell.titleLabel.text = note.title
            cell.dateAndTimeLabel.text = formatter.string(from: note.editDate)
//            cell.contentsLabel.text = note.contents?.trimAllNewLines()
            cell.contentsLabel.text = contentsLabelText
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WriteViewController()
        vc.isExistingNote = true
        vc.note = allNotes[indexPath.row]
        
        transition(to: vc)
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
