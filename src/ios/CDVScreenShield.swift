//
//  CDVScreenShield.swift
//  ScreenShield Plugin
//
//  Created by Andre Grillo on 12/07/2024.
//

import Foundation
import UIKit
import WebKit

@objc(CDVScreenShield)
class CDVScreenShield: CDVPlugin {
    
    @objc(protectWebView:)
    func protectWebView(command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            let shouldBlockScreenRecording = (command.arguments.first as? Bool) ?? false
            if let webView = self.webView as? WKWebView {
                guard let secureView = SecureField().secureContainer else { return }
                
                // Add WKWebView to the secure container
                secureView.addSubview(webView)
                webView.pinEdges(to: secureView)
                
                // Add the secure container to the main Cordova view
                if let cordovaViewController = self.viewController {
                    cordovaViewController.view.addSubview(secureView)
                    //secureView.pinEdges()
                    secureView.pinEdges(to: cordovaViewController.view)
                }
                
                // Activate screen recording protection (video)
                if shouldBlockScreenRecording {
                    guard let message = command.arguments[1] as? String, let fontSize = command.arguments[2] as? CGFloat, let fontColor = command.arguments[3] as? String else {
                        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Missing input parameters")
                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                        return
                    }
                    ScreenShield.shared.protectFromScreenRecording(message: message, fontSize: fontSize, fontColor: fontColor)
                }
                
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "No WKWebView found")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }


    @objc(removeProtectionFromWebView:)
    func removeProtectionFromWebView(command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            if let webView = self.webView as? WKWebView {
                // Remove the webView from its superview (secure container)
                webView.removeFromSuperview()
                
                // Add the webView back to the main Cordova view
                if let cordovaViewController = self.viewController {
                    cordovaViewController.view.addSubview(webView)
                    webView.pinEdges(to: cordovaViewController.view)
                }
                
                // Deactivate screen recording protection (if needed)
                ScreenShield.shared.stopProtection()
                
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "No WKWebView found")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }
}
