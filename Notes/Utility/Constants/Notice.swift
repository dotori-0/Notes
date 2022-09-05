//
//  Notice.swift
//  Notes
//
//  Created by SC on 2022/09/05.
//

import Foundation

enum Notice {
    static let walkthrough = """
                            처음 오셨군요!
                            환영합니다 :)
                            
                            당신만의 메모를 작성하고
                            관리해 보세요!
                            """
    static let ok = "확인"
    static let cancel = "취소"
    static let search = "검색"
    static let done = "완료"
    static let notes = "메모"
    static let pinnedNotes = "고정된 메모"
    static let newNote = "새로운 메모"
    static let noAdditionalTexts = "추가 텍스트 없음"
    
    static let pinnedNotesLimitTitle = "고정 개수 제한 안내"
    static let pinnedNotesLimitMessage = "고정 메모 개수는 5개로 제한됩니다."
    static let deleteWarningTitle = "정말 삭제하시겠습니까?"
    static let deleteWarningMessage = "삭제된 메모는 복구가 불가합니다."
    
    static func numberOfNotes(count: String) -> String {
        return "\(count)개의 메모"
    }
    
    static func numberOfFoundNotes(count: String) -> String {
        return "\(count)개 찾음"
    }
}
