import 'dart:io';

import 'package:fireprevention/settings/ChineseCuperionoLocalizations.dart';
import 'package:fireprevention/settings/FallbackCupertinoLocalisationsDelegate.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/screenutil_init.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';

import 'SplashPage.dart';
import 'base/CustomNavigatorObserver.dart';
import 'model/EventBusModel.dart';

void main() {
  //1334*750
  WidgetsFlutterBinding.ensureInitialized();
  //竖屏
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  FlutterError.onError = (FlutterErrorDetails details) {
    /*"<user:'${CustomerModel.phone}'>\n<token:'${CustomerModel.token}'>\n${details.stack}"*/
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    /*FlutterBugly.uploadException(
        message: "${details.toStringShort()}",
        detail:
        "<user:'${CustomerModel.phone}'>\n<token:'${CustomerModel.token}'>\n${details.stack}");*/
  };

  /*///使用flutter异常上报
  FlutterBugly.postCatchedException(() {
    runApp(MyApp());
  });*/

  runApp(MyApp());

  if (Platform.isAndroid) {
    // android沉浸式。
    SystemUiOverlayStyle systemUiOverlayStyle =
    SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  //全局dialog样式配置
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.circle //dualRing chasingDots
    ..loadingStyle = EasyLoadingStyle.custom
    ..userInteractions = false
    ..lineWidth = 4
    ..indicatorSize = 50.0
    ..radius = 10.0
    ..fontSize = 12.0
    ..contentPadding = EdgeInsets.fromLTRB(50, 30, 50, 30)
    ..progressColor = CXColors.maintab_text_se
    ..indicatorColor = CXColors.titleColor_99
    ..textColor = CXColors.titleColor_99
    ..backgroundColor = CXColors.WhiteColor
    ..successWidget = Text("yes")
    ..maskType = EasyLoadingMaskType.black;
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    ///百度地图sdk初始化鉴权
    if (Platform.isIOS) {
      BMFMapSDK.setApiKeyAndCoordType(
          'IN4XWksGH4lvc1GQvbytVIxnIWlwUjcO', BMF_COORD_TYPE.BD09LL);
    } else if (Platform.isAndroid) {
      // Android 目前不支持接口设置Apikey,
      // 请在主工程的Manifest文件里设置，详细配置方法请参考官网(https://lbsyun.baidu.com/)demo
      BMFMapSDK.setCoordType(BMF_COORD_TYPE.BD09LL);
    }
    /*///注册bugly
    FlutterBugly.init(
        androidAppId: "91c90c0246",
        iOSAppId: "ed96239f50");*/
    ///推送注册
    if (Platform.isIOS) {
      XgFlutterPlugin().startXg("1600024367", "IMY2RQ5TVA1E");
    }else{
      XgFlutterPlugin().startXg("1500015815", "AO3YNOCJ0AK2");
    }
    //注册回调
    XgFlutterPlugin().addEventHandler(
      onRegisteredDone: (String msg) async {
        print("HomePage -> onRegisteredDone -> $msg");
      },
    );
    //通知类 Push
    XgFlutterPlugin().addEventHandler(
      onReceiveNotificationResponse: (Map<String, dynamic> msg) async {
        print("HomePage -> onReceiveNotificationResponse -> $msg");
      },
    );
    //通知类消息点击
    XgFlutterPlugin().addEventHandler(
      xgPushClickAction: (Map<String, dynamic> msg) async {
        print("HomePage -> xgPushClickAction -> $msg");
        EventBusUtil.getInstance().fire(PushTouch());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //设置适配尺寸 (单位dp)
    return ScreenUtilInit(
      designSize: Size(750, 1334),
      allowFontScaling: false,
      builder: () {
        return MaterialApp(
          navigatorObservers: [CustomNavigatorObserver.getInstance()],
          title: '即墨区自然卫士',
          theme: ThemeData(
            // bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: CXColors.WhiteColor),
            primarySwatch: MaterialColor(
              0xFF293446,
              <int, Color>{
                50: Color(0xFFE3F2FD),
                100: Color(0xFFBBDEFB),
                200: Color(0xFF90CAF9),
                300: Color(0xFF64B5F6),
                400: Color(0xFF42A5F5),
                500: Color(0xFF67A6F2),
                600: Color(0xFF1E88E5),
                700: Color(0xFF1976D2),
                800: Color(0xFF1565C0),
                900: Color(0xFF0D47A1),
              },
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          builder: (BuildContext context, Widget child) {
            return FlutterEasyLoading(
              child: GestureDetector(
                onTap: () {
                  //全局空白焦点
                  FocusScopeNode focusScopeNode = FocusScope.of(context);
                  if (!focusScopeNode.hasPrimaryFocus &&
                      focusScopeNode.focusedChild != null) {
                    FocusManager.instance.primaryFocus.unfocus();
                  }
                  //easyLoading
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: child,
              ),
            );
          },
          home: SplashPage(),
          //显示debug
          debugShowCheckedModeBanner: true,
          //配置如下两个国际化的参数
          localizationsDelegates: [
            ChineseCupertinoLocalizations.delegate, // 这里加上这个,是自定义的delegate
            /*DefaultCupertinoLocalizations.delegate, // 这个截止目前只包含英文(暂未使用目前强制中文)*/
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            const FallbackCupertinoLocalisationsDelegate(),
          ],
          supportedLocales: [
            const Locale('zh', 'CH'),
            const Locale('en', 'US'),
          ],
        );
      },
    );
  }
}
