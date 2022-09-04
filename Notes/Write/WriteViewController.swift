//
//  WriteViewController.swift
//  Notes
//
//  Created by SC on 2022/09/02.
//

import UIKit

class WriteViewController: BaseViewController {
    
    // MARK: - Properties
    
    let writeView = WriteView()
    let repository = NotesRepository()
    
    var isExistingNote = false
    var note: Note?
    
    
    // MARK: - Functions
    
    override func loadView() {
        view = writeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("selected note: \(note)")
        if isExistingNote {
            showExistingNote()
        } else {
            writeView.textView.becomeFirstResponder()
        }
    }
    
    override func setUI() {
        super.setUI()
        navigationItem.largeTitleDisplayMode = .never
        
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonClicked))
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonClicked))
        navigationItem.rightBarButtonItems = [doneButton, shareButton]
        navigationItem.backButtonTitle = "메모"
    }
    
    func showExistingNote() {
        writeView.textView.text = note?.title
        
        if let contents = note?.contents {
            writeView.textView.text += contents
        }
//        writeView.textView.text += note?.contents
    }
    
    @objc func shareButtonClicked() {
        
    }
    
    @objc func doneButtonClicked() {
        if isExistingNote {
            checkChangesAndUpdateNoteToRealm()
        } else {
            saveNoteToRealm()
        }
        
        writeView.endEditing(true)
//        navigationController?.popViewController(animated: true)
    }
    
    func saveNoteToRealm() {
        guard let text = writeView.textView.text else {
            print("Cannot find text in Text View")
            return
        }
        
        // 리턴키를 기준으로 타이틀 구별하기
        let titleAndContentsArraySeparatedByNewLines = writeView.textView.text.components(separatedBy: .newlines)
        print(titleAndContentsArraySeparatedByNewLines)

        // 타이틀에도 스페이스 하나 조차 없이 아예 비어 있다면 저장하지 않도록
        guard let firstElementOfTitleAndContentsArraySeparatedByNewLines = titleAndContentsArraySeparatedByNewLines.first else {
            print("Cannot find the first element of titleAndContentsArraySeparatedByNewLines")
            return
        }
        
        if titleAndContentsArraySeparatedByNewLines.count == 1 && firstElementOfTitleAndContentsArraySeparatedByNewLines.isEmpty {
            return
        }
        print("💚 titleAndContentsArraySeparatedByNewLines: \(titleAndContentsArraySeparatedByNewLines)")
        
        
        // 처음으로 적는 텍스트가 제목이 되도록
        var realTextsArray: [String] = []
        
        for text in titleAndContentsArraySeparatedByNewLines {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedText.isEmpty {
                realTextsArray.append(trimmedText)
            }
        }
        
        guard let firstRealText = realTextsArray.first else {
            print("No real text at all")
            return
        }
        
        print("💙 firstRealText: \(firstRealText)")
        let titleAndContentsArraySeparatedByFirstRealText = writeView.textView.text.components(separatedBy: firstRealText)
        print("💜", titleAndContentsArraySeparatedByFirstRealText)
        
        guard let whiteSpacesAndNewLinesBeforeTheFirstRealText = titleAndContentsArraySeparatedByFirstRealText.first else {
            print("Cannot find whiteSpacesAndNewLinesBeforeTheFirstRealText")
            return
        }
        
        let title = "\(whiteSpacesAndNewLinesBeforeTheFirstRealText)\(firstRealText)"
        

        print("text.hasPrefix(title): \(text.hasPrefix(title))")
        
        let contentsSubsequence = text.dropFirst(title.count)  // Type: String.SubSequence
        let contents = String(contentsSubsequence)             // Non-optional
        
        let note = Note(title: title, contents: contents)
        print(note)
        repository.writeNote(note)
    }
    
    func checkChangesAndUpdateNoteToRealm() {
        guard let text = writeView.textView.text else {
            print("Cannot find text in Text View")
            return
        }
        
        let titleAndContentsArray = writeView.textView.text.components(separatedBy: .newlines)
        
        guard let title = titleAndContentsArray.first else {
            print("Cannot find title")
            return
        }

        print("text.hasPrefix(title): \(text.hasPrefix(title))")
        
        let contentsSubsequence = text.dropFirst(title.count)  // Type: String.SubSequence
        let contents = String(contentsSubsequence)             // Non-optional
        
        let editedNote = Note(title: title, contents: contents)
        print(editedNote)
        
        guard let originalNote = note else { return }
        
        if originalNote.title != editedNote.title || originalNote.contents != editedNote.contents  {
            repository.updateNote(from: originalNote, to: editedNote)
        }
    }
}
