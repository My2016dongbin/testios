import 'dart:math';

class AllUtils{
  final String BUGLY_APPID_ANDROID = "91c90c0246";//bugly appid Android
  final String BUGLY_APPID_IOS = "ed96239f50";//bugly appid IOS
  ///微信支付结果码

  final int WX_PAY_OK = 0;//交易成功

  final int WX_PAY_ERR = -1;//交易失败

  final int WX_PAY_CANCLE = -2;//交易取消

  ///支付宝支付结果码

   final String ALI_PAY_OK = "9000";// 支付成功

   final String ALI_PAY_WAIT_CONFIRM = "8000";// 交易待确认

  final String ALI_PAY_NET_ERR = "6002";// 网络出错

  final String ALI_PAY_CANCLE = "6001";// 交易取消

   final String ALI_PAY_FAILED = "4000";// 交易失败



  final String cameraError = "设备状态异常";
  final String playRtsp = "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov";
  final String playRtmp = "rtmp://117.132.5.139:12041/live/0003eda1-6e1c-4ef4-b0be-958a524hk003?streamType=2&manufacturer=2";

  /// 对比版本号
  String judgeVersion(String now,String lasted){
    List nowList = now.split(".");
    List lastedList = lasted.split(".");
    print("nowList.toString() = " + nowList.toString());
    print("lastedList.toString() = " + lastedList.toString());
    if(nowList.length!=3 || lastedList.length!=3 ){
      return "JudgeVersionException";
    }
    if(lastedList[0] == nowList[0]){

      if(lastedList[1] == nowList[1]){

        if(lastedList[2] == nowList[2]){
          return "no";
        }else{
          return (int.parse(lastedList[2]) > int.parse(nowList[2]))?"yes":"no";
        }

      }else{
        return (int.parse(lastedList[1]) > int.parse(nowList[1]))?"yes":"no";
      }

    }else{
      return (int.parse(lastedList[0]) > int.parse(nowList[0]))?"yes":"no";
    }
  }

  /// 填0格式化
  String parseZero(int oldStr){
    String newStr = "";
    if(oldStr > 9){
      newStr = oldStr.toString();
    }else{
      newStr = "0${oldStr.toString()}";
    }

    return newStr;
  }

  /// double 转 int
  int  parseDtoInt(double old){
    String newStr = "";
    String oldStr = old.toString();
    newStr = oldStr.substring(0,oldStr.indexOf("."));

    return int.parse(newStr);
  }

  /// 获取自适应fontSize
  double fixedFontSize(double width,int defaultSize, String str){
    int number = str.length;
    for(int i = defaultSize; i > 0; i --){
      if((number * i * 1.5) <= width){
//        print(" str=$str  defaultSize=$defaultSize  width=$width  number=$number  i=$i  fontSize=$i   ${(number * i)}  $width   ${(number * i) <= width}");
        return i*1.0;
      }
    }
    return 1;
  }

  /// 数字添加分隔
  String toDBC(String input) {
    String output = "";
    for(int i = 0;i < input.length;i++){
      if(i>0 && "0123456789".contains(input.substring(i,i+1)) && "0123456789".contains(input.substring(i-1,i))){
        output += " ";
      }
      output += input.substring(i,i+1);
    }
    return output;
  }

  ///地图-资源类型列表
  static List mapFireResourceList = [
    {
      "title": "消防专业队",
      "resourceType": "team",
      "state": false,
    },
    {
      "title": "危险源",
      "resourceType": "dangerSource",
      "state": false,
    },
    {
      "title": "物资储备库",
      "resourceType": "foreastRoom",
      "state": false,
    },
    {
      "title": "水源地",
      "resourceType": "waterSource",
      "state": false,
    },
    {
      "title": "墓地",
      "resourceType": "cemetery",
      "state": false,
    },
    {
      "title": "瞭望塔",
      "resourceType": "watchTower",
      "state": false,
    },
    {
      "title": "护林检查站",
      "resourceType": "checkStation",
      "state": false,
    },
    {
      "title": "视频监控点",
      "resourceType": "monitor",
      "state": false,
    },
    {
      "title": "森林防火监测中心",
      "resourceType": "foreastCenter",
      "state": false,
    },
  ];
  ///地图-火情查询
  static List mapFireSearchFilterList = [
    {
      "title": "当前时间",
      "id": 0,
    },
    {
      "title": "1小时内",
      "id": 1,
    },
    {
      "title": "3小时内",
      "id": 2,
    },
    {
      "title": "1天内",
      "id": 3,
    },
    {
      "title": "3天内",
      "id": 4,
    },
    {
      "title": "5天内",
      "id": 5,
    },
    {
      "title": "高级",
      "id": 6,
    },
  ];

  static String cloudUrl = "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwww.cma.gov.cn%2F2011xwzx%2F2011xqxxw%2F2011xtpxw%2F202006%2FW020200613478058521605.jpg&refer=http%3A%2F%2Fwww.cma.gov.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628732043&t=7f582fd60cdcd6c2e174eede00dae1dd";
  static List<String> AllRepairResult = ["已修复","未修复","部分修复"];
  static List<String> AllProvince = [
    "北京",
    "上海",
    "广东",
    "天津",
    "山东",
    "江苏",
    "河北",
    "山西",
    "内蒙古",
    "辽宁",
    "吉林",
    "黑龙江",
    "浙江",
    "安徽",
    "福建",
    "江西",
    "河南",
    "湖北",
    "湖南",
    "广西",
    "海南",
    "重庆",
    "四川",
    "贵州",
    "云南",
    "西藏",
    "陕西",
    "甘肃",
    "青海",
    "宁夏",
    "新疆",
    "台湾",
    "香港特别行政区",
    "澳门",
  ];
  String randomNumber(int len) {
    String scopeF = "123456789";//首位
    String scopeC = "0123456789";//中间
    String result = "";
    for (int i = 0; i < len+1; i++) {
      if (i == 1) {
        result = scopeF[Random().nextInt(scopeF.length)];
      } else {
        result = result + scopeC[Random().nextInt(scopeC.length)];
      }
    }
    return result;
  }
}