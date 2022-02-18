# Swift-FaceID-TouchID

以登录为例:  
1.开启指纹登录:首次登陆使用密码登录,登录后,可以设置一个FaceID和TouchID。  
2.验证:验证设备是否支持生体認証。  
3.可以选择生成设备账号/密码:TouchID/FaceID验证通过后，根据当前已登录appId和deviceToken，生成所需账号/密码，并保存在keychain。  
4.绑定：生成设备账号/密码后，将原账号及设备账号/密码，加密后（题主使用的是RSA加密）发送到服务端进行绑定。  
5.成功：验证原账号及设备账号有效后，返回相应状态，绑定成功则完成整个TouchID（设备）绑定流程。  
6.失败：当验证失败5次后，TouchID/FaceID被锁定，会触发设备密码页面进行验证。  


- 1.添加权限

打开`<Info.plist>` 追加`Privacy - Face ID Usage Description`key，并为其赋予值`Face IDへのアクセスを求めています。`。

- 2.添加头文件

```

#import <LocalAuthentication/LocalAuthentication.h>

```

- 3.主逻辑
 *  1.创建LAContext实例，这使我们可以查询生物识别状态并执行身份验证检查。
 *  2.询问上下文是否能够执行生物特征认证——这很重要，因为iPod touch 既没有 Touch ID 也没有 Face ID。
 *  3.如果可以进行生物识别，那么我们将启动实际的身份验证请求，并传递一个闭包以在身份验证完成时运行。
 *  4.当用户通过身份验证或未通过身份验证时，我们的完成关闭将被调用并告诉我们它是否有效，如果不是，那么错误是什么。该闭包将从主线程中调用，因此我们需要将所有与UI相关的工作推回主线程。

```

func authenticate() {
    let context = LAContext()
    var error: NSError?

    // 检查生物特征认证是否可用
    if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        // 可用，所以继续使用它
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: toast, reply: { (success, error) in
            // 身份验证现已完成
            DispatchQueue.main.async {
                if success {
                    // 认证成功
                    completion(.success)
                } else {
                    // 发生的异常
                    let laError = error as! LAError
                    self.errorData(laError: laError, completion: completion)
                }
            }
        }
    } else {
        // 没有生物识别
        let laError = error as! LAError
        errorData(laError: laError, completion: completion)
    }
}

```

- 4.调用权限认证处理

```
    func getFaceOrTouchAuth() {
        FaceAndTouchIDHelper.authFaceOrTouchID { (result, _) in
            if result {
                
            } else {
                
            }
        }
    }
  
```

- 5.使用

```        
    func getFaceOrTouch() {
        if FaceAndTouchIDHelper.faceId() == .faceID {
            FaceAndTouchIDHelper.open(toast: LocalizedString("labels.title.faceIDMessage")) { (faceId) in
                if faceId == FaceAndTouchIDHelper.IdCase.success {
                    self.isUnlocked = true
                }
            }
        }
        if FaceAndTouchIDHelper.faceId() == .touchID {
            FaceAndTouchIDHelper.open(toast: LocalizedString("labels.title.touchIDMessage")) { (touchId) in
                if touchId == FaceAndTouchIDHelper.IdCase.success {
                    self.isUnlocked = true
                }
            }
        }
    }

```
