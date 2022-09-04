//
//  AttributedString+Extension.swift
//  Notes
//
//  Created by SC on 2022/09/02.
//

import UIKit

extension String {
    func addAttribute(to searchText: String) -> NSMutableAttributedString {
        var tintColor: UIColor
        if #available(iOS 15.0, *) {  // 'tintColor' is only available in iOS 15.0 or newer
            tintColor = .tintColor
        } else {
            // Fallback on earlier versions
            tintColor = UIColor.systemOrange
        }
        
        
        let attributedString = NSMutableAttributedString(string: self)
        
//        attributedString.addAttribute(.foregroundColor, value: tintColor, range: (self as NSString).range(of: searchText))
//        attributedString.addAttribute(.foregroundColor, value: tintColor, range: (self as NSString).range(of: searchText.uppercased()))
        
//        for letter in searchText {
//            attributedString.addAttribute(.foregroundColor, value: tintColor, range: (self as NSString).range(of: String(letter)))
//            attributedString.addAttribute(.foregroundColor, value: tintColor, range: (self as NSString).range(of: letter.uppercased()))
//        }
        

        var rangeToSearch = self.startIndex..<self.endIndex
        while let matchingRange = self.range(of: searchText, options: .caseInsensitive, range: rangeToSearch) {
            attributedString.addAttribute(.foregroundColor, value: tintColor, range: NSRange(matchingRange, in: self))
            rangeToSearch = matchingRange.upperBound..<self.endIndex
        }
        
        return attributedString
    }
    
    func trimAllNewLines() -> String {
        return self.trimmingCharacters(in: .newlines)
    }
}
