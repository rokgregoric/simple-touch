//
//  SimpleTouch.swift
//  SimpleTouch
//
//  Created by Hamish Rickerby on 19/10/2015.
//  Copyright © 2015 Simple Machines. All rights reserved.
//

import LocalAuthentication

public typealias TouchIDPresenterCallback = (TouchIDResponse) -> Void

public struct SimpleTouch {

    public static var hardwareSupportsTouchIDOrPasscode: TouchIDResponse {
        switch evaluateTouchIDOrPasscodePolicy {
            case let x where x == .error(.passcodeNotSet): return x
            case let x where x == .error(.touchIDNotAvailable): return x
            default: return .success
        }
    }

    public static var isTouchIDOrPasscodeEnabled: TouchIDResponse {
        return evaluateTouchIDOrPasscodePolicy
    }

    fileprivate static var evaluateTouchIDOrPasscodePolicy: TouchIDResponse {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return .success
        }
        if #available(iOS 9.0, *), context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            return .successPasscode
        }
        return .error(TouchIDError.createError(error))
    }

    fileprivate static func presentAuthentication(_ type: LAPolicy, reason: String, fallbackTitle: String, callback: @escaping TouchIDPresenterCallback) {
        guard #available(iOS 9.0, *) else { return }
        let context = LAContext()
        context.localizedFallbackTitle = fallbackTitle
        context.evaluatePolicy(type, localizedReason: reason) { _, error in
            guard error == nil else {
                DispatchQueue.main.async(execute: {
                    callback(.error(TouchIDError.createError(error as NSError?)))
                })
                return
            }
            DispatchQueue.main.async(execute: {
                callback(.success)
            })
        }
    }

    public static func presentTouchID(_ reason: String, fallbackTitle: String, callback: @escaping TouchIDPresenterCallback) {
        presentAuthentication(.deviceOwnerAuthenticationWithBiometrics, reason: reason, fallbackTitle: fallbackTitle, callback: callback)
    }

    public static func presentPasscode(_ reason: String, fallbackTitle: String, callback: @escaping TouchIDPresenterCallback) {
        presentAuthentication(.deviceOwnerAuthentication, reason: reason, fallbackTitle: fallbackTitle, callback: callback)
    }
}
