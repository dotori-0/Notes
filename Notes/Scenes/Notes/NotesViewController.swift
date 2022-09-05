//
//  NotesViewController.swift
//  Notes
//
//  Created by SC on 2022/09/01.
//

import UIKit

import RealmSwift

final class NotesViewController: BaseViewController {
    // MARK: - Properties
    
    private let notesView = NotesView()
    private let repository = NotesRepository()

    private var allNotes: Results<Note>! {
        didSet {
            print("Notes Changed")
            notesView.tableView.reloadData()
        }
    }
    private var pinnedNotes: Results<Note>!
    private var unpinnedNotes: Results<Note>!
    private var foundNotes: Results<Note>!
    
    private var isSearchBarEmpty: Bool {
        return notesView.searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var isFiltering: Bool {
        return notesView.searchController.isActive && !isSearchBarEmpty
    }
    
    private var searchText = ""
    
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        let spaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: NotesViewController.self, action: nil)
        let writeBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(writeButtonClicked))
        // writeBarButtonItem에서 target을 NotesViewController.self로 하면 아래의 런타임 에러가 나는 이유?
        // Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '+[Notes.NotesViewController writeButtonClicked]: unrecognized selector sent to class 0x10253f048'
        toolbar.setItems([spaceBarButtonItem, writeBarButtonItem], animated: true)
        toolbar.isTranslucent = false
//        toolbar.clipsToBounds = true  // separator 없애기 위해 추가했지만 툴바 높이 44를 제외한 인디케이터 영역을 채우지 못함
        
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        
        if #available(iOS 15.0, *) {
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
        
        notesView.searchController.searchResultsUpdater = self
        
        print("Realm is located at:", repository.realm.configuration.fileURL!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        
        fetchRealm()
        setTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = true
        
        // Realm DB에 Create/Update 하는 시간 문제로 인한 처리 - 개선 필요
        // 긴 메모일 경우 시간이 더 오래 걸리기 때문에 0.2 초 이상 걸릴 수 있음 -> 아래 코드로는 리스트의 변화를 볼 수 없음
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.notesView.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        navigationController?.navigationBar.prefersLargeTitles = false  // prefersLargeTitles = false는 뷰 전환 후에도 Large Title이 잠시 남아 있는 문제 있음
    }

    override func setUI() {
        super.setUI()
        
        guard navigationController != nil else {
            print("No navigation controller")
            return
        }
//        navigationController?.navigationBar.prefersLargeTitles = true  // viewWillAppear로 옮김(WriteViewController에 false로 지정되어 있어 WriteViewController로 갔다가 돌아 오면 네비게이션 타이틀이 작아져 있음)
        navigationItem.searchController = notesView.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemGray6
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        notesView.addSubview(toolbar)
        
        if !UserDefaultsHelper.standard.isExistingUser {
            showWalkthroughPopUp()
        }
        
        notesView.tableView.keyboardDismissMode = .onDrag
    }
    
    override func setConstraints() {
        toolbar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(notesView.safeAreaLayoutGuide)
        }
        toolbar.updateConstraintsIfNeeded()  // NotesView가 아니라 여기에서는 실행해도 LayoutConstraints 오류가 2개에서 1개로 줄어들지 않는 이유? 오류를 없앨 수 있는 방법?
        
        notesView.tableView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(notesView.safeAreaLayoutGuide)
            make.bottom.equalTo(toolbar.snp.top)
        }  // NotesView에서 레이아웃 잡은 후 NotesViewController에서 updateConstraints 하면 Updated constraint could not find existing matching constraint to update 런타임 에러
    }
    
    override func setActions() {
        // NotesView에 toolbar 선언 후 handler를 뷰컨으로부터 bar button item의 action으로 넘기기
//        let handler: () -> Void = { self.transition(to: WriteViewController()) }
//        notesView.writeButtonHandler = handler
        // 런타임 에러
        // Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '+[Notes.NotesViewController writeButtonHandler]: unrecognized selector sent to class 0x104417008'
    }
    
    private func formatNumber(_ number: Int) -> String? {
        let numberFomatter = NumberFormatter()
        numberFomatter.numberStyle = .decimal
        
        return numberFomatter.string(for: number)
    }
    
    private func setTitle() {
        if let formattedNotesCount = formatNumber(allNotes.count) {
            title = Notice.numberOfNotes(count: formattedNotesCount)
        } else {
            title = Notice.notes
        }
    }
    
    private func showWalkthroughPopUp() {
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.addSubview(notesView.walkthroughBackground)
        
        notesView.walkthroughBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
        
    @objc private func writeButtonClicked() {
        transition(to: WriteViewController())
    }
    
    private func fetchRealm() {
        print(#function)
        allNotes = repository.fetch()
        pinnedNotes = repository.fetchPinnedNotes()
        unpinnedNotes = repository.fetchUnpinnedNotes()
        notesView.tableView.reloadData()
    }
    
    private func findNotes(with searchText: String) {
        foundNotes = repository.findNotes(with: searchText)
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
            guard let formattedFilterNotesCount = formatNumber(foundNotes.count) else { return UIView() }
            headerTitleLabel.text = Notice.numberOfFoundNotes(count: formattedFilterNotesCount)
        } else {
            if section == Section.pinnedNotes {
                guard pinnedNotes != nil else { return nil }
                if pinnedNotes.isEmpty { return nil }
                headerTitleLabel.text = Notice.pinnedNotes
            } else {
                guard unpinnedNotes != nil else { return nil }
                if unpinnedNotes.isEmpty { return nil }
                headerTitleLabel.text = Notice.notes
            }
        }
        
        headerView.addSubview(headerTitleLabel)
        
        headerTitleLabel.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !isFiltering {
            if section == Section.pinnedNotes {
                guard pinnedNotes != nil else { return 0 }
                if pinnedNotes.isEmpty { return 0 }
            } else {
                guard unpinnedNotes != nil else { return 0 }
                if unpinnedNotes.isEmpty { return 0 }
            }
        }

        return UIScreen.main.bounds.height * 0.06
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return foundNotes.count
        } else {
            if section == Section.pinnedNotes {
                guard pinnedNotes != nil else { return 0 }
                return pinnedNotes.count
            } else {
                guard unpinnedNotes != nil else { return 0 }
                return unpinnedNotes.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotesTableViewCell.reuseIdentifier) as? NotesTableViewCell else {
            print("Cannot find NotesTableViewCell")
            return UITableViewCell()
        }
        
        var note: Note
           
        if isFiltering {
            guard !foundNotes.isEmpty else { return UITableViewCell() }
            note = foundNotes[indexPath.row]
            
            let filteredNoteTitleTrimmed = note.title.trimAllWhiteSpacesAndNewlines()
            guard let filteredNoteContentsTrimmed = note.contents?.trimAllWhiteSpacesAndNewlines() else {
                return UITableViewCell()
            }

            // 추후 develop 시 아이폰 메모 앱처럼 white space나 new lines만 있더라도 메모가 저장되도록 구현하기 위해 "새로운 메모"로 보이도록 미리 구현
            // 현재는 white space나 new lines만 작성할 시 메모가 아예 저장되지 않도록 구현되어 있기 때문에 "새로운 메모"가 테이블 뷰에 보일 일이 X
  
            // "새로운 메모" 및 "추가 텍스트 없음"에서 텍스트 컬러 변경이 일어나지 않도록
            if filteredNoteTitleTrimmed.isEmpty {
                cell.titleLabel.text = Notice.newNote
            } else {
                cell.titleLabel.attributedText = filteredNoteTitleTrimmed.addAttribute(to: searchText)
            }

            if filteredNoteContentsTrimmed.isEmpty {
                cell.contentsLabel.text = Notice.noAdditionalTexts
            } else {
                cell.contentsLabel.attributedText = filteredNoteContentsTrimmed.addAttribute(to: searchText)
            }
        } else {
            if indexPath.section == Section.pinnedNotes {
                guard !pinnedNotes.isEmpty else { return UITableViewCell() }
                note = pinnedNotes[indexPath.row]
            } else {
                guard !unpinnedNotes.isEmpty else { return UITableViewCell() }
                note = unpinnedNotes[indexPath.row]
            }
            
            let titleTrimmed = note.title.trimAllWhiteSpacesAndNewlines()
            guard let contentsTrimmed = note.contents?.trimAllWhiteSpacesAndNewlines() else { return UITableViewCell() }
            
            let titleLabelText = titleTrimmed.isEmpty ? Notice.newNote : titleTrimmed
            let contentsLabelText = contentsTrimmed.isEmpty ? Notice.noAdditionalTexts : contentsTrimmed
            // 내용으로 엔터만 쳤을 경우 note.contents가 Optional("\n\n\n\n\n\n\n")이기 때문에
            
            cell.titleLabel.text = titleLabelText
            cell.contentsLabel.text = contentsLabelText
        }
        
        let formatter = setDateFormatter(with: note.editDate)
        
        cell.dateAndTimeLabel.text = formatter.string(from: note.editDate)

        return cell
    }
    
    private func setDateFormatter(with date: Date) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LocalizationSettings.korea)
        let calendar = Calendar.current
        
        let editDateComponent = calendar.dateComponents(in: .current, from: date)
        let weekOfEditDate = editDateComponent.weekOfYear
        
        let currentDateComponent = calendar.dateComponents(in: .current, from: Date())
        let weekOfToday = currentDateComponent.weekOfYear
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = DateFormat.today
        } else if weekOfEditDate == weekOfToday {
            formatter.dateFormat = DateFormat.thisWeek
        } else {
            formatter.dateFormat = DateFormat.other
        }
        
        return formatter
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WriteViewController()
        vc.isExistingNote = true
        
        if isFiltering {
            vc.note = foundNotes[indexPath.row]
            vc.isFromSearch = true
        } else {
            if indexPath.section == Section.pinnedNotes {
                vc.note = pinnedNotes[indexPath.row]
            } else {
                vc.note = unpinnedNotes[indexPath.row]
            }
        }
        
        transition(to: vc)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var note: Note
            
        if isFiltering {
            note = foundNotes[indexPath.row]
        } else {
            if indexPath.section == Section.pinnedNotes {
                note = pinnedNotes[indexPath.row]
            } else {
                note = unpinnedNotes[indexPath.row]
            }
        }
        
        let pin = UIContextualAction(style: .normal, title: nil) { action, view, completion in
            if !note.isPinned && self.pinnedNotes.count == PinnedNotes.max {
                self.showAlert(title: Notice.pinnedNotesLimitTitle, message: Notice.pinnedNotesLimitMessage)
            } else {
                self.repository.updatePinned(of: note)
            }
            
            tableView.reloadData()
        }
        
        let image = note.isPinned ? SymbolName.unpin : SymbolName.pin
        pin.image = UIImage(systemName: image)
        pin.backgroundColor = .systemOrange
        
        return UISwipeActionsConfiguration(actions: [pin])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var note: Note
            
        if isFiltering {
            note = foundNotes[indexPath.row]
        } else {
            if indexPath.section == Section.pinnedNotes {
                note = pinnedNotes[indexPath.row]
            } else {
                note = unpinnedNotes[indexPath.row]
            }
        }
        
        let delete = UIContextualAction(style: .normal, title: nil) { action, view, completion in
            self.showAlert(title: Notice.deleteWarningTitle,
                           message: Notice.deleteWarningMessage,
                           style: .destructive,
                           allowsCancel: true) { _ in
                self.repository.deleteNote(note)

                tableView.reloadData()
                self.setTitle()
            }
        }
        
        delete.image = UIImage(systemName: SymbolName.trash)
        delete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}


extension NotesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            print("no text")
            return
        }
        
        searchText = text.lowercased()
        findNotes(with: searchText)
    }
}


//extension NotesViewController: UIToolbarDelegate {
//    func position(for bar: UIBarPositioning) -> UIBarPosition {
//        return .bottom
//    }
//}
