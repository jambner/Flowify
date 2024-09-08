//
//  Components.swift
//  Flowify
//
//  Created by Ramon Martinez on 8/7/24.
//

import Foundation
import UIKit


class Components: UIViewController {
    
    lazy var textBar: UITextField = {
        textBar = UITextField()
        textBar.placeholder = "Type here..."
        textBar.borderStyle = .roundedRect
        textBar.backgroundColor = .gray
        return textBar
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
}

extension UITextView: KeyAssociable {
    private struct AssociatedKeys {
        static var key = "key"
    }

    var key: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.key) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UITextField: KeyAssociable {
    private struct AssociatedKeys {
        static var key = "key"
    }
    
    var key: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.key) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func validateEditedField(target: Any?, action: Selector) {
        self.addTarget(target, action: action, for: UIControl.Event.editingChanged)
    }
}
