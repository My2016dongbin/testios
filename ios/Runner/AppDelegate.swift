import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,VSGServiceDelegate {
    
    var service = VSGService();
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    service.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue) , context: nil);
    service = VSGService.init(address: "222.173.76.34", port: 443, delegate: self);
    service.auth(withParam: "admin20G", paramKey: VSGAuthPassWordkUserName);
    service.auth(withParam: "Hh123456@", paramKey: VSGAuthPassWordkPassword);
    service.startAuth(with: VSGResourceType.ncResource, callBack: nil);
    
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //未生效
        print("VSG: \(String(describing: keyPath))")
        
        //观察vpn链接状态
        if keyPath == "status" {
            print("VSGVPN链接状态：\(change!)");
        }
        
    }
    func vsgService(_ service: VSGService!, authResult result: VSGAuthResult, param: [AnyHashable : Any]!) {
           
           switch result {
           case VSGAuthResult.VSGAUTH_SUCCESS:
               print("VSG：success")
           default:
               break;
           }
        print("VSG认证等链接状态：\(result)");
       }
    func vsgService(_ service: VSGService!, logoutResult result: VSGAuthResult) {
        if result != VSGAuthResult.VSGAUTH_SUCCESS {
            print("VSG注销失败!")
        }
    }
    
    //添加vpn出错，重新添加配置
    func vsgService(_ service: VSGService!, saveNCConfigerationFailed errorMsg: String!) {
        print("VSG添加vpn出错，重新添加配置")
        service.deleteTheNCConfigeration();
    }
}
