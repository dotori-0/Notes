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
    
    func setNote() -> Note? {
        guard let text = writeView.textView.text else {
            print("Cannot find text in Text View")
            return nil
        }
        
        // 리턴키를 기준으로 텍스트 분리
        let writtenTextsArraySeparatedByNewLines = writeView.textView.text.components(separatedBy: .newlines)
        print("💛", writtenTextsArraySeparatedByNewLines)

        // 분리된 배열의 첫 번째 요소
        guard let firstElementOfWrittenTextsArraySeparatedByNewLines = writtenTextsArraySeparatedByNewLines.first else {
            print("Cannot find the first element of writtenTextsArraySeparatedByNewLines")
            return nil
        }
        
        // 타이틀에도 스페이스 하나 조차 없이 아예 비어 있다면 저장하지 않도록
        if writtenTextsArraySeparatedByNewLines.count == 1 && firstElementOfWrittenTextsArraySeparatedByNewLines.isEmpty {
            return nil
        }
        print("💚 writtenTextsArraySeparatedByNewLines: \(writtenTextsArraySeparatedByNewLines)")
        
        
        // 실제로 작성하는 텍스트와 그 후의 리턴 키를 기준으로 타이틀을 분리
        var realTextsArray: [String] = []
        
        for text in writtenTextsArraySeparatedByNewLines {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedText.isEmpty {
                realTextsArray.append(trimmedText)
            }
        }
        
        // 실제 텍스트가 아예 없을 시 저장되지 않도록
        guard let firstRealText = realTextsArray.first else {
            print("No real text at all")
            return nil
        }
        
        print("💙 firstRealText: \(firstRealText)")
        let writtenTextsArraySeparatedByFirstRealText = writeView.textView.text.components(separatedBy: firstRealText)
        print("💜", writtenTextsArraySeparatedByFirstRealText)
        
        guard let whiteSpacesAndNewLinesBeforeTheFirstRealText = writtenTextsArraySeparatedByFirstRealText.first else {
            print("Cannot find whiteSpacesAndNewLinesBeforeTheFirstRealText")
            return nil
        }
        
        let title = "\(whiteSpacesAndNewLinesBeforeTheFirstRealText)\(firstRealText)"
        

        print("text.hasPrefix(title): \(text.hasPrefix(title))")
        
        let contentsSubsequence = text.dropFirst(title.count)  // Type: String.SubSequence
        let contents = String(contentsSubsequence)             // Non-optional
        
        let note = Note(title: title, contents: contents)
        
        return note
    }
    
    func saveNoteToRealm() {
//        let note = Note(title: title, contents: contents)
        guard let note = setNote() else { return }
        print(note)
        repository.writeNote(note)
    }
    
    func checkChangesAndUpdateNoteToRealm() {
//        guard let text = writeView.textView.text else {
//            print("Cannot find text in Text View")
//            return
//        }
//
//        let titleAndContentsArray = writeView.textView.text.components(separatedBy: .newlines)
//
//        guard let title = titleAndContentsArray.first else {
//            print("Cannot find title")
//            return
//        }
//
//        print("text.hasPrefix(title): \(text.hasPrefix(title))")
//
//        let contentsSubsequence = text.dropFirst(title.count)  // Type: String.SubSequence
//        let contents = String(contentsSubsequence)             // Non-optional
        
//        let editedNote = Note(title: title, contents: contents)
        guard let editedNote = setNote() else { return }
        print(editedNote)
        
        guard let originalNote = note else { return }
        
        if originalNote.title != editedNote.title || originalNote.contents != editedNote.contents  {
            repository.updateNote(from: originalNote, to: editedNote)
        }
    }
}
