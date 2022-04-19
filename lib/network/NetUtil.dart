import 'dart:developer';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:fireprevention/model/CustomerModel.dart';
import 'package:fireprevention/model/EventBusModel.dart';
import 'package:fireprevention/settings/CommonConfig.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'dart:convert';

//要查网络请求的日志可以使用过滤<net>
class NetUtil {
  static const String GET = "get";
  static const String POST = "post";
  static const String PUT = "put";

  //get请求
  static void get(String url,Function callBack,
      {Map<String, dynamic> params, Function errorCallBack}) async {
    _request(url, callBack,
        method: GET, params: params, errorCallBack: errorCallBack);
  }

  //post请求
  static void post(String url, Function callBack,
      {Map<String, dynamic> params, Function errorCallBack}) async {
    _request(url, callBack,
        method: POST, params: params, errorCallBack: errorCallBack);
  }
  //put请求
  static void put(String url, Function callBack,
      {Map<String, dynamic> params, Function errorCallBack}) async {
    _request(url, callBack,
        method: PUT, params: params, errorCallBack: errorCallBack);
  }

  //post请求
  static void postForm(String url, Function callBack,
      {FormData params, Function errorCallBack}) async {
    _requestForm(url, callBack,
        method: POST, params: params, errorCallBack: errorCallBack);
  }

  //具体的还是要看返回数据的基本结构
  //公共代码部分
  static void _requestForm(String url, Function callBack,
      {String method, FormData params, Function errorCallBack}) async {
    print("<net> url :<" + method + ">" + url);

    String token = CustomerModel.token;
    if (CustomerModel.token == null) {
      CustomerModel.token = "";
    }

    print("<net> token :" + CustomerModel.token == null
        ? ""
        : CustomerModel.token);

    String errorMsg = "";
    int statusCode;

    BaseOptions options = BaseOptions(headers: {
    "Authorization":"bearer ${CustomerModel.token??""}",
      // "Content-Type": "application/x-www-form-urlencoded",
      "Content-Type": "multipart/form-data",
    });

    try {
      Response response;
      Dio dio = new Dio(options);
      var cookieJar=CookieJar();
      dio.interceptors.add(PrivateCookieManager(cookieJar));
      //强制忽略证书
      DefaultHttpClientAdapter adapter = dio.httpClientAdapter;
      adapter.onHttpClientCreate = (HttpClient client){
        client.badCertificateCallback = (X509Certificate cert ,String host ,int port){
          return true;
        };
      };
      if (params != null) {
        response = await dio.post(url, data: params);
      } else {
        response = await dio.post(url);
      }

      if(response!=null){
        statusCode = response.statusCode;

        //处理错误部分
        if (statusCode < 0) {
          errorMsg = "网络请求错误,状态码:" + statusCode.toString();
          _handError(errorCallBack, errorMsg);
          return;
        }

        log("respence.data = " + response.data.toString());
      }
      /*judgeTokenDown(response);//NEW*/

      if (callBack != null && response!=null) {
        callBack(response.data);//NEW
      }
    } catch (exception) {
      EventBusUtil.getInstance().fire(Todismiss());
      _handError(errorCallBack, exception.toString());
    }
  }

  //具体的还是要看返回数据的基本结构
  //公共代码部分
  static void _request(String url, Function callBack,
      {String method,
      Map<String, dynamic> params,
      Function errorCallBack}) async {
    print("<net> url :<" + method + ">" + url);

    if (params != null && params.isNotEmpty) {
      print("<net> params :" + params.toString());
    }

    String token = CustomerModel.token;
    if (CustomerModel.token == null) {
      CustomerModel.token = "";
    }

    print("<net> token :" + CustomerModel.token == null
        ? ""
        : CustomerModel.token);

    String errorMsg = "";
    int statusCode;

    BaseOptions options = BaseOptions(headers: {"Authorization":"bearer ${CustomerModel.token??""}"},connectTimeout: 30000);

    try {
      Response response;
      if (method == GET) {
        //组合GET请求的参数
        if (params != null && params.isNotEmpty) {
          StringBuffer sb = new StringBuffer("?");
          params.forEach((key, value) {
            sb.write("$key" + "=" + "$value" + "&");
          });
          String paramStr = sb.toString();
          paramStr = paramStr.substring(0, paramStr.length - 1);
          url += paramStr;
        }
        Dio dio = new Dio(options);
        var cookieJar=CookieJar();
        dio.interceptors.add(PrivateCookieManager(cookieJar));
        //强制忽略证书
        DefaultHttpClientAdapter adapter = dio.httpClientAdapter;
        adapter.onHttpClientCreate = (HttpClient client){
          client.badCertificateCallback = (X509Certificate cert ,String host ,int port){
            return true;
          };
        };
        response = await dio.get(url).catchError((e){
          log("get error $e");
          if(errorCallBack!=null){
            _handError(errorCallBack,"$e");
          }
        });
      } else if (method == POST) {
        Dio dio = new Dio(options);
        var cookieJar=CookieJar();
        dio.interceptors.add(PrivateCookieManager(cookieJar));
        //强制忽略证书
        DefaultHttpClientAdapter adapter = dio.httpClientAdapter;
        adapter.onHttpClientCreate = (HttpClient client){
          client.badCertificateCallback = (X509Certificate cert ,String host ,int port){
            return true;
          };
        };
        if (params != null && params.isNotEmpty) {
          String json = jsonEncode(params);
          print("<net> json :" + json.toString());
          response = await dio.post(url, data: json).catchError((e){
            log("post error $e");
            if(errorCallBack!=null){
              _handError(errorCallBack,"$e");
            }
          });
        } else {
          response = await dio.post(url).catchError((e){
            log("post error $e");
            if(errorCallBack!=null){
              _handError(errorCallBack,"$e");
            }
          });
        }
      } else {
        Dio dio = new Dio(options);
        var cookieJar=CookieJar();
        dio.interceptors.add(PrivateCookieManager(cookieJar));
        //强制忽略证书
        DefaultHttpClientAdapter adapter = dio.httpClientAdapter;
        adapter.onHttpClientCreate = (HttpClient client){
          client.badCertificateCallback = (X509Certificate cert ,String host ,int port){
            return true;
          };
        };
        if (params != null && params.isNotEmpty) {
          String json = jsonEncode(params);
          print("<net> json :" + json.toString());
          response = await dio.put(url, data: json).catchError((e){
            log("put error $e");
            if(errorCallBack!=null){
              _handError(errorCallBack,"$e");
            }
          });
        } else {
          response = await dio.put(url).catchError((e){
            log("put error $e");
            if(errorCallBack!=null){
              _handError(errorCallBack,"$e");
            }
          });
        }
      }

      if(response!=null){
        log("response.data = " + response.data.toString());
        statusCode = response.statusCode;

        //处理错误部分
        if (statusCode < 0) {
          errorMsg = "网络请求错误,状态码:" + statusCode.toString();
          _handError(errorCallBack, errorMsg);
          return;
        }
      }


      /*if (judgeTokenDown(response)) {
        return;
      }*/

      if (callBack != null && response!=null) {
        callBack(response.data);
      }
    } catch (exception) {
      EventBusUtil.getInstance().fire(Todismiss());
      _handError(errorCallBack, exception.toString());
    }
  }

  //处理异常
  static void _handError(Function errorCallback, String errorMsg) {
    if (errorCallback != null) {
      errorCallback(errorMsg);
    }
    EventBusUtil.getInstance().fire(Todismiss());
  }

  static bool judgeTokenDown(Response response) {
    if (jsonDecode(response.data)["code"] == "510" /*&& CustomerModel.isLogin*/) {
      CustomerModel.isLogin = false;
      /*Fluttertoast.showToast(msg: CommonConfig.string_Tokendown);*/
     /* CustomNavigatorObserver.getInstance().navigator.pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => route == null);*/
      Future.delayed(Duration(milliseconds: 500),(){
        EventBusUtil.getInstance().fire(ShowToast(CommonConfig.string_Tokendown));
      });
      return true;
    }
    return false;
  }
}


/* 修改Cookie */
class PrivateCookieManager extends CookieManager  {
  /// Cookie manager for http requests。Learn more details about
  /// CookieJar please refer to [cookie_jar](https://github.com/flutterchina/cookie_jar)
  final CookieJar cookieJar;

  PrivateCookieManager(this.cookieJar) : super(cookieJar);

  @override
  Future onRequest(RequestOptions options) async {
    var cookies = cookieJar.loadForRequest(options.uri);
    cookies.removeWhere((cookie) {
      if (cookie.expires != null) {
        return cookie.expires.isBefore(DateTime.now());
      }
      return false;
    });
    String cookie = getCookies(cookies);
    if (cookie.isNotEmpty) options.headers[HttpHeaders.cookieHeader] = cookie;
  }

  @override
  Future onResponse(Response response) async => _saveCookies(response);

  @override
  Future onError(DioError err) async => _saveCookies(err.response);

  _saveCookies(Response response) {
    if (response != null && response.headers != null) {
      List<String> cookies = response.headers[HttpHeaders.setCookieHeader];
      if (cookies != null) {
        cookieJar.saveFromResponse(
          response.request.uri,
          cookies.map((str) => _Cookie.fromSetCookieValue(str)).toList(),
        );
      }
    }
  }

  static String getCookies(List<Cookie> cookies) {
    return cookies.map((cookie) => "${cookie.name}=${cookie.value}").join('; ');
  }
}

/* 修改Cookie */
 class _Cookie implements Cookie{
  String name;

  String value;

  DateTime expires;

  int maxAge;

  String domain;

  String path;

  bool secure;


  bool httpOnly;


  factory _Cookie(String name, String value) => new _Cookie(name, value);


  factory _Cookie.fromSetCookieValue(String value) {
    return new _Cookie.fromSetCookieValue(value);
  }

  void _validate() {
    const separators = const [
      "(",
      ")",
      "<",
      ">",
      "@",
      ",",
      ";",
      ":",
      "\\",
      '"',
      "/",
//******* [] is valid in this application ***********
      "[",
      "]",
      "?",
      "=",
      "{",
      "}"
    ];
  }

  String toString();
}
