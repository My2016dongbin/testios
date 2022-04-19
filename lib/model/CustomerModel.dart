import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show json;

class CustomerModel {

  ///用户信息
  static String token = "";
  static String id = "";
  static String userCode = "";
  static String fullName = "";
  static String email = "";
  static String phone = "";
  static String sex = "";
  static String entryTime = "";
  static String birthday = "";
  static String type = "";
  static String isSuperAdmin = "";
  static String comment = "";
  static String groupId = "";
  static String gridNo = "";
  static String bkchar2 = "";
  static String money = "";
  static String lockMoney = "";
  static String groupName = "";
  static String headUrl = "";
  static String state = "";
  static double latitude ;
  static double longitude ;
  static bool keepLogin = false ;
  ///设置
  static bool isShangChuan = false;
  static bool isYuYin = false;//是否播放
  ///地图
  static bool appmap = false;//    首页地图
  static bool appvideo = false;//    首页视频
  static bool appapplication = false;//    首页应用
  static bool appsetting = false;//    首页我的

  static bool appMapBtnSatelliteFirealarm = false; //    卫星
  static bool appSatelliteFirealarmBtnList = false; //    火情列表
  static bool satelliteFirealarmBtnQuery = false;//    火情查询
  static bool appSatelliteFirealarmBtnSetting = false;//    卫星设置
  static bool appMapBtnResource = false;//    资源
  static bool appMapBtnFirealarm = false;//    报警
  static bool appMapBtnTask = false;//    任务
  static bool appVideoBtnDirectionControl = false;//    方向控制
  static bool appVideoBtnZoomControl = false;//    拉进拉远聚焦
  static bool appApplicationBtnReport = false;//    火情上报
  static bool appReportBtnAdd = false;//    保存
  static bool appApplicationBtnDangerCheck = false;//    隐患排查
  static bool appDangerCheckBtnAdd = false;    //    保存
  static bool appApplicationBtnTask = false;//    调度任务
  static bool appSettingBtnPosition = false;//    实时位置上传


  static String account = "";
  static String passWord = "";
  static bool isLogin = false;
  static String shareUrl = "";
}

//清除所有信息
void deleteAllCache() async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs = await _prefs;
  prefs.clear();
}
//保存数据String
void saveToCache(String key, String value) async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs = await _prefs;
  prefs.setString(key, value);
}
//保存数据int
void saveIntToCache(String key, int value) async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs = await _prefs;
  prefs.setInt(key, value);
}
//保存数据double
void saveDoubleToCache(String key, double value) async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs = await _prefs;
  prefs.setDouble(key, value);
}
//保存数据bool
void saveBoolToCache(String key, bool value) async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs = await _prefs;
  prefs.setBool(key, value);
}
//保存数据list<String>
void saveListStringToCache(String key, List<String>  value) async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs = await _prefs;
  prefs.setStringList(key, value);
}

//获取数据 ( String bool int StringList )
getFromCacheByType(String key, String type) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (type == "String") {
    return prefs.getString(key);
  }
  if (type == "bool") {
    return prefs.getBool(key);
  }
  if (type == "int") {
    return prefs.getInt(key);
  }
  if (type == "StringList") {
    return prefs.getStringList(key);
  }
}

class SelectModel {
  String id;
  String name;

  SelectModel.fromParams({this.id, this.name});

  factory SelectModel(jsonStr) => jsonStr == null
      ? null
      : jsonStr is String
          ? new SelectModel.fromJson(json.decode(jsonStr))
          : new SelectModel.fromJson(jsonStr);

  SelectModel.fromJson(jsonRes) {
    id = jsonRes['id'];
    name = jsonRes['name'];
  }

  @override
  String toString() {
    return '{"id": ${id != null ? '${json.encode(id)}' : 'null'},"name": ${name != null ? '${json.encode(name)}' : 'null'}}';
  }
}
