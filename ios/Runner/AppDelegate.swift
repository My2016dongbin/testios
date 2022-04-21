import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,VSGServiceDelegate {
    
    var service = VSGService();
    @objc dynamic var status = VSGVPNStatus.invalid;
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    service.addObserver(self, forKeyPath: "status", options: [.new, .old] , context: nil);
    
        
    service = VSGService.init(address: "222.173.76.34", port: 443, delegate: self);
    service.auth(withParam: "admin20G", paramKey: VSGAuthPassWordkUserName);
    service.auth(withParam: "Hh123456@", paramKey: VSGAuthPassWordkPassword);
    service.startAuth(with: .ncResource, callBack: nil);
    
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        print("SVG：111111111111");
    }
    
    func vsgService(_ service: VSGService!, authResult result: VSGAuthResult, param: [AnyHashable : Any]!) {
           
           switch result {
           case .VSGAUTH_SUCCESS:
               print("VSG：success")
           default:
               break;
           }
        print("VSG认证等链接状态：\(result)");
       }
    func vsgService(_ service: VSGService!, logoutResult result: VSGAuthResult) {
        if result != .VSGAUTH_SUCCESS {
            print("VSG注销失败!")
        }
    }
    
    //添加vpn出错，重新添加配置
    func vsgService(_ service: VSGService!, saveNCConfigerationFailed errorMsg: String!) {
        print("VSG添加vpn出错，重新添加配置")
        service.deleteTheNCConfigeration();
    }
}
