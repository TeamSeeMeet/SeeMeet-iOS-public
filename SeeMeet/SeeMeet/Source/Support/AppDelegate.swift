import AuthenticationServices
import UIKit
import Firebase
import KakaoSDKCommon
import UserNotifications
import FirebaseCore
import FirebaseMessaging


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        sleep(1)
        KakaoSDK.initSDK(appKey: "")
        FirebaseApp.configure()
        removeKeychainAtFirstLaunch()
        
        if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.isLogin) {
            if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.isAppleLogin) {
                // 애플 로그인으로 연동되어 있을 때, -> 애플 ID와의 연동상태 확인 로직
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                appleIDProvider.getCredentialState(forUserID: UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.userAppleID) ?? "") { (credentialState, error) in
                    switch credentialState {
                    case .authorized:
                        print("해당 ID는 연동되어있습니다.")
                        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKey.isLogin)
                    case .revoked:
                        print("해당 ID는 연동되어있지않습니다.")
                        UserDefaults.standard.set(false, forKey: Constants.UserDefaultsKey.isLogin)
                    case .notFound:
                        print("해당 ID를 찾을 수 없습니다.")
                        UserDefaults.standard.set(false, forKey: Constants.UserDefaultsKey.isLogin)
                    default:
                        break
                    }
                }
            }
            
            PostRefreshAccessTokenService.shared.tokenRefresh { response in
                switch response {
                case .success(let data):
                    guard let tokenData = data as? TokenRefreshData else { return }
                    TokenUtils.shared.create(account: "accessToken", value: tokenData.accessToken)
                    TokenUtils.shared.create(account: "refreshToken", value: tokenData.refreshToken)
                case .requestErr:
                    UserDefaults.deleteUserValue() // 만료시켜서 재 로그인 유도
                    NotificationCenter.default.post(name: NSNotification.Name.DidLogout, object: nil) // 마이페이지 뷰에서 받는다
                case .serverErr:
                    print("serverError")
                case .networkFail:
                    print("networkFail")
                case .pathErr:
                    print("path error: tokenRefresh")
                }
            }
        }
            
            // 앱 실행 중 애플 ID 강제로 연결 취소 시
            NotificationCenter.default.addObserver(forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil, queue: nil) { (Notification) in
                print("Revoked Notification")
                UserDefaults.standard.set(false, forKey: Constants.UserDefaultsKey.isLogin)
            }
        
        // Register for remote notifications.
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
                PostPushNotificationSetService.shared.pushSet(isNotificationOn: granted) { result in
                    print("푸시 알림 설정 완료")
                    NotificationCenter.default.post(name: NSNotification.Name.PushNotificationDidSet, object: granted)
                    UserDefaults.standard.set(granted, forKey: Constants.UserDefaultsKey.isPushNotificationOn)
                }
            }
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        
        return true
    }
    
    private func removeKeychainAtFirstLaunch() {
        guard UserDefaults.isFirstLaunch() else { return }
        TokenUtils.shared.delete(account: "accessToken")
        TokenUtils.shared.delete(account: "refreshToken")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            
            // 세로방향 고정
            return UIInterfaceOrientationMask.portrait
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,willPresent notification: UNNotification,withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
        if let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window {
            if let rootViewController = window.rootViewController {
                if let tabBarController = rootViewController as? TabbarVC {
                    tabBarController.selectedIndex = 1
                    if let navigationVC = tabBarController.selectedViewController as? UINavigationController,
                       let calendarVC = navigationVC.topViewController as? CalendarVC {
                        calendarVC.calendar.select(Date().nextDate())
                        calendarVC.displayPlansCollectionView(at: Date().nextDate())
                    }
                    window.rootViewController = tabBarController
                    window.makeKeyAndVisible()
                }
            }
        }
        
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //서버로 보낼 fcmToken값
        print("FCM Token: \(fcmToken)")
        guard let fcmToken = fcmToken else { return }

        UserDefaults.standard.set(fcmToken, forKey: "fcmToken") //우선 userdefaults에 담아두고 로그인시 꺼내서 사용
    }
}
