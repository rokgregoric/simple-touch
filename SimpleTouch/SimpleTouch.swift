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
            case let x where x == .Error(.PasscodeNotSet): return x
            case let x where x == .Error(.TouchIDNotAvailable): return x
            default: return .Success
        }
    }

    public static var isTouchIDOrPasscodeEnabled: TouchIDResponse {
        return evaluateTouchIDOrPasscodePolicy
    }

    private static var evaluateTouchIDOrPasscodePolicy: TouchIDResponse {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            return .Success
        }
        if #available(iOS 9.0, *), context.canEvaluatePolicy(.DeviceOwnerAuthentication, error: &error) {
            return .SuccessPasscode
        }
        return .Error(TouchIDError.createError(error))
    }

    private static func presentAuthentication(type: LAPolicy, reason: String, fallbackTitle: String, callback: TouchIDPresenterCallback) {
        guard #available(iOS 9.0, *) else { return }
        let context = LAContext()
        context.localizedFallbackTitle = fallbackTitle
        context.evaluatePolicy(type, localizedReason: reason) { _, error in
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    callback(.Error(TouchIDError.createError(error)))
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                callback(.Success)
            })
        }
    }

    public static func presentTouchID(reason: String, fallbackTitle: String, callback: TouchIDPresenterCallback) {
        presentAuthentication(.DeviceOwnerAuthenticationWithBiometrics, reason: reason, fallbackTitle: fallbackTitle, callback: callback)
    }

    public static func presentPasscode(reason: String, fallbackTitle: String, callback: TouchIDPresenterCallback) {
        presentAuthentication(.DeviceOwnerAuthentication, reason: reason, fallbackTitle: fallbackTitle, callback: callback)
    }
}
