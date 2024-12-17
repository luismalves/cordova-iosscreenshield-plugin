//
//  SecureField.swift
//  iOS Screen Shield Sample App
//
//  Created by Andre Grillo on 14/10/2024.
//


import UIKit

class SecureField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.isSecureTextEntry = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Secure container for preventing screenshots
    weak var secureContainer: UIView? {
        let secureView = self.subviews.filter({ subview in
            type(of: subview).description().contains("CanvasView")
        }).first
        secureView?.translatesAutoresizingMaskIntoConstraints = false
        secureView?.isUserInteractionEnabled = true // Enable interaction
        return secureView
    }
    
    override var canBecomeFirstResponder: Bool { false }
    override func becomeFirstResponder() -> Bool { false }
}

extension UIView {
    
    func pinEdges(to superview: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false

        // Disabled because this breaks the StatusBarOverlaysWebView options from cordova-status-barplugin

        // Use safeAreaLayoutGuide to avoid overlapping the status bar
        // if #available(iOS 11.0, *) {
        //     NSLayoutConstraint.activate([
        //         self.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
        //         self.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor),
        //         self.leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor),
        //         self.trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor)
        //     ])
        // } else {
            // Fallback on earlier versions (no safe area, use superview edges)
            NSLayoutConstraint.activate([
                self.topAnchor.constraint(equalTo: superview.topAnchor),
                self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                self.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
            ])
        // }
    }
}
