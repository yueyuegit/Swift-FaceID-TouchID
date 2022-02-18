//
//  FaceIDTouchIDHelper.swift
//  LocalAuthentication
//
//  Created by yjl on 2022/2/16.
//  Copyright © 2022 yjl. All rights reserved.
//

import LocalAuthentication

class FaceAndTouchIDHelper: NSObject {

    /// 生体認証の属性を返す
    enum IdCase: Int {
        case success
        case failure
        case passwordNoSet
        case touchIdNoSet
        case touchIdNoAvailable
        case systemCancle
        case userCancel
        case inputPassword
    }
    
    // 生体認証に関するカテゴリ
    enum BiometryType: Int {
        case none
        case touchID
        case faceID
    }
        
    // システムの生体認証を呼び出す
    public class func open(toast: String, completion: @escaping(_ _result: IdCase) -> Void) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: toast, reply: { (success, error) in
                DispatchQueue.main.async {
                    if success {
                        completion(.success)
                    } else {
                        let laError = error as! LAError
                        self.errorData(laError: laError, completion: completion)
                    }
                }
            })
        } else {
            let laError = error as! LAError
            errorData(laError: laError, completion: completion)
        }
    }

    // 生体認証カテゴリを判断する
    class func faceId() -> BiometryType {
        // このパラメータは「canEvaluatePolicy」メソッドの後に値を持つ必要がある
        let authContent = LAContext()
        var error: NSError?
        if authContent.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error) {
            if #available(iOS 11.0, *) {
                if authContent.biometryType == .faceID {
                    return .faceID
                } else if authContent.biometryType == .touchID {
                    return .touchID
                }
            } else {
                guard let laError = error as? LAError else {
                    return .none
                }
                if laError.code != .touchIDNotAvailable {
                    return .touchID
                }
            }
        }
        return .none
    }

    // エラーメッセージ
    class func errorData(laError: LAError, completion: @escaping (_ result: IdCase) -> Void) {
        switch laError.code {
        case LAError.authenticationFailed:
            completion(.failure)
        case LAError.userCancel:
            completion(.userCancel)
        case LAError.userFallback:
            completion(.inputPassword)
        case LAError.systemCancel:
            completion(.systemCancle)
        case LAError.passcodeNotSet:
            completion(.passwordNoSet)
        default: break
        }
    }
    
    class func authFaceOrTouchID(clouser: @escaping ((Bool, NSError?) -> Void)) {
        let context = LAContext()
        var error: NSError?
        let result = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let laError = error as? LAError {
            clouser(result, laError as NSError)
        } else {
            clouser(result, nil)
        }
    }
    
    class func authSystemFaceOrTouchID(clouser: @escaping ((Bool, NSError?) -> Void)) {
        let context = LAContext()
        var error: NSError?
        let result = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let laError = error as? LAError {
            clouser(result, laError as NSError)
        } else {
            clouser(result, nil)
        }
    }

}
