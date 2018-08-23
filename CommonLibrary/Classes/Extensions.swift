//
//  Extensions.swift
//  Common Library
//
//  Created by Marcella Tanzil on 08/24/18.
//  Copyright © 2018. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    @nonobjc public class func fromNib(_ nibNameOrNil: String? = nil) -> Self {
        return fromNib(nibNameOrNil, type: self)
    }
    
    @nonobjc public class func fromNib<T : UIView>(_ nibNameOrNil: String? = nil, type: T.Type) -> T {
        let v: T? = fromNib(nibNameOrNil, type: T.self)
        return v!
    }
    
    @nonobjc public class func fromNib<T : UIView>(_ nibNameOrNil: String? = nil, type: T.Type) -> T? {
        var view: T?
        let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = nibName
        }
        if let nibViews = Bundle.main.loadNibNamed(name, owner: nil, options: nil) {
            for v in nibViews {
                if let tog = v as? T {
                    view = tog
                }
            }
        }
        
        return view
    }
    
    @nonobjc public class var nibName: String {
        let name = "\(self)".components(separatedBy: ".").first ?? ""
        return name
    }
    
    @nonobjc public class var nib: UINib? {
        if let _ = Bundle.main.path(forResource: nibName, ofType: "nib") {
            return UINib(nibName: nibName, bundle: nil)
        } else {
            return nil
        }
    }
}

extension String {
    
    func encodeUriComponent() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-_.!~*'()")
        
        return self.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)
    }
    
    func safelyLimitedTo(length n: Int)->String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
}

extension UIViewController {

    func showSimpleAlert(title: String, message: String, button: String, actionBlock: (() -> ())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: button, style: .default, handler: { _ in
            if let actionBlock = actionBlock {
                actionBlock()
            }
        }))
        
        // A workaround for apple bug for having a delay in opening the alertcontroller the second time
        DispatchQueue.main.async {
            // alertController.view.tintColor = Profile.shared.currentTintColor()
            self.present(alertController, animated: true)
        }
    }
    
    func showErrorAlert(message: String, actionBlock: (() -> ())? = nil) {
        self.showSimpleAlert(title: "Error", message: message, button: "OK", actionBlock: actionBlock)
    }
    
    func showAlert(title: String?, message: String?, firstButtonTitle: String, secondButtonTitle: String, firstBlock: (() -> ())?, secondBlock: (() -> ())?) {
        let alertController = UIAlertController(title: title ?? "", message: message ?? "", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: firstButtonTitle, style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let firstBlock = firstBlock {
                firstBlock()
            }
        })
        let secondAction = UIAlertAction(title: secondButtonTitle, style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            if let secondBlock = secondBlock {
                secondBlock()
            }
        })
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        
        // A workaround for apple bug for having a delay in opening the alertcontroller the second time
        DispatchQueue.main.async {
            //alertController.view.tintColor = Profile.shared.currentTintColor()
            self.present(alertController, animated: true)
        }
    }
    
    func topViewController() -> UIViewController {
        var topViewController = self
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}

extension UIColor {
    static var dukeTeal: UIColor = UIColor(red: 0/255, green: 139/255, blue: 176/255, alpha: 1)
    static var dukeLightTeal: UIColor = UIColor(red: 95/255, green: 173/255, blue: 196/255, alpha: 1)
    static var dukeLighterTeal: UIColor = UIColor(red: 73/255, green: 202/255, blue: 223/255, alpha: 1)
    static var dukeDarkTeal: UIColor = UIColor(red: 57/255, green: 113/255, blue: 143/255, alpha: 1)
    static var dukeBlue: UIColor = UIColor(red: 0/255, green: 89/255, blue: 132/255, alpha: 1)
    static var dukeYellow: UIColor = UIColor(red: 255/255, green: 210/255, blue: 0/255, alpha: 1)
    static var dukeDarkGray: UIColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
    static var dukeLightGray: UIColor = UIColor(red: 202/255, green: 201/255, blue: 202/255, alpha: 1)
    static var dukeGreen: UIColor = UIColor(red: 109/255, green: 235/255, blue: 131/255, alpha: 1)
    static var dukeRed: UIColor = UIColor(red: 255/255, green: 87/255, blue: 20/255, alpha: 1)
}

extension UISearchBar {
    var backgroundView: UIView? {
        if let textfield = self.value(forKey: "searchField") as? UITextField {
            if let view = textfield.subviews.first {
                // Rounded corner
                view.layer.cornerRadius = 10
                view.clipsToBounds = true
                return view
            }
        }
        return nil
    }
}

private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return Int.max
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
}

extension Data {
    mutating func append(string: String) {
        let data = string.data(using: String.Encoding.utf8)
        append(data!)
    }
}

extension DispatchQueue {
    class func dispatchSyncToMain(_ block: () -> Void) {
        // This is to ensure there wont be any deadlock situation in case it is already on main thread
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync { () -> Void in
                block()
            }
        }
    }
}

