//
//  ReusableView.swift
//  Notes
//
//  Created by SC on 2022/09/01.
//

import UIKit

public protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UIViewController: ReusableView { }

extension UIView: ReusableView { }
