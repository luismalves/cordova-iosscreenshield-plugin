//
//  ScreenShield.swift
//  ScreenShield Plugin
//
//  Created by Andre Grillo on 12/07/2024.
//

import UIKit

@objcMembers public class ScreenShield: NSObject {

    public static let shared = ScreenShield()
    private var blurView: UIVisualEffectView?
    private var recordingObservation: NSKeyValueObservation?

    // Protect the app's main window from screenshots
    public func protect(window: UIWindow) {
        DispatchQueue.main.async {
            guard let secureView = SecureField().secureContainer else { return }
            window.addSubview(secureView)
            secureView.pinEdges(to: window)
        }
    }

    // Protect a specific view (e.g., WKWebView) from screenshots
    public func protect(view: UIView) {
        DispatchQueue.main.async {
            guard let secureView = SecureField().secureContainer else { return }
            view.addSubview(secureView)
            secureView.pinEdges(to: view)
        }
    }

    // Detect screen recording and overlay a blur when active
    public func protectFromScreenRecording(message: String, fontSize: CGFloat = 20, fontColor: String = "000000") {
        recordingObservation = UIScreen.main.observe(\.isCaptured, options: [.new]) { [weak self] screen, change in
            guard let self = self else { return }
            let isRecording = change.newValue ?? false
            print("Screen is being captured: \(isRecording)")
            if isRecording {
                self.addBlurView(message: message, fontSize: fontSize, fontColor: hexStringToUIColor(hex: fontColor) ?? .black)  // Add blur when recording starts
            } else {
                self.removeBlurView()  // Remove blur when recording stops
            }
        }
    }

    // Detect screen recording and overlay a blur when active
    public func removeProtectFromScreenRecording() {
        deactivateProtection()
    }
    
    private func hexStringToUIColor(hex: String) -> UIColor? {
        var cleanedHexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Remove '#' if present
        if cleanedHexString.hasPrefix("#") {
            cleanedHexString.remove(at: cleanedHexString.startIndex)
        }
        
        // Ensure valid length (6 or 8 characters)
        if cleanedHexString.count != 6 && cleanedHexString.count != 8 {
            return nil  // Invalid hex string
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanedHexString).scanHexInt64(&rgbValue)
        
        if cleanedHexString.count == 6 {
            // RGB format: RRGGBB
            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else if cleanedHexString.count == 8 {
            // ARGB format: AARRGGBB
            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            )
        }

        return nil  // Invalid hex string
    }

    // Add a blur effect when screen recording is active
    private func addBlurView(message: String, fontSize: CGFloat, fontColor: UIColor) {
        guard blurView == nil else { return }
        let blurEffect = UIBlurEffect(style: .regular)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView?.frame = UIScreen.main.bounds

        // Add a label to indicate screen recording is not allowed
        let label = UILabel()
        label.text = message //"Screen recording not allowed"
        label.font = UIFont.boldSystemFont(ofSize: fontSize)//20)
        label.textColor = fontColor //.red
        label.translatesAutoresizingMaskIntoConstraints = false
        blurView?.contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: blurView!.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: blurView!.contentView.centerYAnchor)
        ])

        // Add the blur view to the key window
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(blurView!)
        }
    }

    // Remove the blur effect after screen recording stops
    private func removeBlurView() {
        blurView?.removeFromSuperview()
        blurView = nil
    }

    public func deactivateProtection() {
        // Stop the recording observation
        recordingObservation?.invalidate()
        recordingObservation = nil

        // Remove the blur view, if present
        removeBlurView()
    }
}

