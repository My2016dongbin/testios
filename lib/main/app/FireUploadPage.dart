import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/base/YGSBehavior.dart';
import 'package:fireprevention/main/map/MapLocationPage.dart';
import 'package:fireprevention/model/EventBusModel.dart';
import 'package:fireprevention/network/Api.dart';
import 'package:fireprevention/network/NetUtil.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/CustomRoute.dart';
import 'package:fireprevention/utils/CustomerLayout.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:fireprevention/utils/PictureShow.dart';
import 'package:fireprevention/utils/VideoScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';

class FireUploadPage extends StatefulWidget {
  @override
  _FireUploadPageState createState() => _FireUploadPageState();
}

class _FireUploadPageState extends State<FireUploadPage> {
  TextEditingController fireNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController reporterController = TextEditingController();
  List<File> images = [];
  List<String> imagesForPost = [];
  File video;
  String videoForPost = "";
  int imagePostTag = 0;
  String date;
  DateTime choosedDate;

  @override
  void initState() {
    super.initState();
    getAreaData();
  }
  @override
  void dispose() {
    super.dispose();
    EventBusUtil.getInstance().fire(VideoStatus(true));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: BaseScaffold(
        title: "火情上报",
        titleSize: 30.sp,
        backgtoundColor: CXColors.lineColor_f8,
        leftImage: "assets/images/common/ic_back.png",
        leftImageSize: 40.w,
        leftCallback: (){Navigator.pop(context);},
        body: Builder(builder: (BuildContext context) {
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 130.w),
                child: ScrollConfiguration(
                  behavior: YGSBehavior(),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///添加图片
                        Container(
                          margin: EdgeInsets.all(20.w),
                          child: Text("添加图片",style: TextStyle(color: CXColors.titleColor_55,fontSize: 30.sp),),
                        ),
                        Wrap(
                          children: getWrapChildren(),
                        ),
                        ///添加视频
                        Container(
                          margin: EdgeInsets.all(20.w),
                          child: Row(
                            children: [
                              Text("上传视频: ",style: TextStyle(color: CXColors.titleColor_55,fontSize: 30.sp),),
                              InkWell(
                                  child: Image.asset("assets/images/main/app/video_play_normal1.png",width: 45.w,height: 45.w,fit: BoxFit.fill,),
                                onTap: (){
                                    //视频预览
                                  if(video==null){
                                    Fluttertoast.showToast(msg: "您还没有选择视频");
                                    return;
                                  }
                                  Navigator.push(context,
                                      MaterialPageRoute<void>(builder: (BuildContext context) {
                                        return VideoScreen(url: video.path,);
                                      }));
                                },
                              ),
                              InkWell(child: Text("  视频选择",style: TextStyle(color: CXColors.titleColor_55,fontSize: 28.sp),),onTap: () async {
                                EventBusUtil.getInstance().fire(FocusHide());
                                var videoGet = await ImagePicker().getVideo(source: ImageSource.gallery);
                                print("videoGet.path = ${videoGet.path}");
                                if(videoGet!=null){
                                  EventBusUtil.getInstance().fire(Toloading(title: "视频处理中..."));
                                  video = File(videoGet.path);
                                }
                                EventBusUtil.getInstance().fire(Todismiss());
                              },),
                            ],
                          ),
                        ),
                        ///其它
                        Container(
                            color: CXColors.WhiteColor,
                            padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //省市区
                                Container(
                                  height: 60.w,
                                  child: Row(
                                    children: [
                                      InkWell(child: Text("$provinceStr",style: TextStyle(color: CXColors.titleColor_cc,fontSize: 28.sp),),onTap: chooseProvince,),
                                      Container(margin: EdgeInsets.fromLTRB(5.w, 3.w, 10.w, 0),child: Image.asset("assets/images/main/app/ic_down.png",width: 20.w,height: 20.w,fit: BoxFit.fill,)),
                                      InkWell(child: Text("$cityStr",style: TextStyle(color: CXColors.titleColor_cc,fontSize: 28.sp),),onTap: chooseCity,),
                                      Container(margin: EdgeInsets.fromLTRB(5.w, 3.w, 10.w, 0),child: Image.asset("assets/images/main/app/ic_down.png",width: 20.w,height: 20.w,fit: BoxFit.fill,)),
                                      InkWell(child: Text("$areaStr",style: TextStyle(color: CXColors.titleColor_cc,fontSize: 28.sp),),onTap: chooseArea,),
                                      Container(margin: EdgeInsets.fromLTRB(5.w, 3.w, 10.w, 0),child: Image.asset("assets/images/main/app/ic_down.png",width: 20.w,height: 20.w,fit: BoxFit.fill,)),
                                      Expanded(child: Container(
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.only(right: 20.w),
                                        child: InkWell(child: Container(
                                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                            child: Image.asset("assets/images/main/app/ic_tomap.png",width: 35.w,height: 45.w,fit: BoxFit.fill,)),onTap: mapLocation,
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                                LineCell(margin: EdgeInsets.only(top: 18.w),),
                                EditCell(fireNameController,"火点名称"),
                                LineCell(),
                                EditCell(addressController,"地址"),
                                LineCell(),
                                EditCell(longitudeController,"经度",inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]")),],keyboardType: TextInputType.number,),
                                LineCell(),
                                EditCell(latitudeController,"纬度",inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]")),],keyboardType: TextInputType.number,),
                                LineCell(),
                                InkWell(child: Container(alignment: Alignment.centerLeft,height:90.w,child: Text("${date!=null?date.substring(0,16).replaceAll("T", " "):"时间"}",style: TextStyle(color: CXColors.titleColor_cc,fontSize: 28.sp),)),onTap: chooseDate,),
                                LineCell(),
                                EditCell(areaController,"面积(公顷)",inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]")),],keyboardType: TextInputType.number,),
                                LineCell(),
                                EditCell(reporterController,"上报人"),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: CommonButton(
                  text: "保存",
                  fontSize: 32.sp,
                  backgroundColor: CXColors.maintab,
                  margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 30.w),
                  borderRadius: 60.w,
                  onPressed: (){
                    EventBusUtil.getInstance().fire(FocusHide());
                    if(images==null || images.length==0){
                      Fluttertoast.showToast(msg: "请先添加图片");
                      return;
                    }
                    if(provinceStr.contains("请选择")||cityStr.contains("请选择")||areaStr.contains("请选择")){
                      Fluttertoast.showToast(msg: "请选择省市区");
                      return;
                    }
                    if(choosedDate==null){
                      Fluttertoast.showToast(msg: "请选择时间");
                      return;
                    }
                    imagesForPost.clear();
                    imagePostTag = 0;
                    EventBusUtil.getInstance().fire(Toloading(title: "正在提交..."));
                    for(File image in images){
                      commitPicture(image);
                    }
                  },
                ),
              ),
            ],
          );
        },),
      ),
    );
  }

  void chooseProvince() {
    EventBusUtil.getInstance().fire(FocusHide());
    if(provinceList==null || provinceList.isEmpty){
      Fluttertoast.showToast(msg: "数据加载未完成,请稍后重试");
      return;
    }
    showModalBottomSheet(context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ), builder: (BuildContext context) {
        scrollControllerP = FixedExtentScrollController(initialItem: provinceIndex);
        int index = provinceIndex;
        return Container(
          height:200,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: EdgeInsets.only(top: 12),
                      child: Text("请选择省",style: TextStyle(color: CXColors.BlackColor,fontSize: 16),)
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ScrollConfiguration(
                    behavior: YGSBehavior(),
                    child: CupertinoPicker(
                      scrollController: scrollControllerP,
                      itemExtent: 45,
                      children: getProvince(),
                      onSelectedItemChanged: (int value) {
                        index = value;
                      },

                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(15,10,0,15),child: Icon(Icons.clear,color: CXColors.titleColor_99,)),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(0,10,15,15),child: Icon(Icons.check,color: CXColors.titleColor_99,)),
                    onTap: (){
                      setState(() {
                        provinceIndex = index;
                        provinceStr = provinceList[provinceIndex]["name"];
                      });
                      Navigator.pop(context);
                      ///更新市列表
                      currentCityList.clear();
                      cityStr = "请选择市";
                      currentAreaList.clear();
                      areaStr = "请选择区";
                      for(dynamic model in cityList){
                        if(model["parentId"] == provinceList[provinceIndex]["id"]){
                          currentCityList.add(model);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },);
  }
  getProvince() {
    List<Widget> list = [];
    for(int i = 0;i < provinceList.length;i++){
      list.add(
          Container(
            child: Center(child: Text(provinceList[i]["name"],style: TextStyle(color: CXColors.BlackColor,fontSize: provinceList[i]["name"].length>3?14:15),)),
          )
      );
    }
    return list;
  }
  void chooseCity() {
    EventBusUtil.getInstance().fire(FocusHide());
    if(currentCityList.isEmpty){
      Fluttertoast.showToast(msg: "请先选择省");
      return;
    }
    showModalBottomSheet(context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ), builder: (BuildContext context) {
        scrollControllerC = FixedExtentScrollController(initialItem: cityIndex);
        int index = cityIndex;
        return Container(
          height:200,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: EdgeInsets.only(top: 12),
                      child: Text("请选择市",style: TextStyle(color: CXColors.BlackColor,fontSize: 16),)
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ScrollConfiguration(
                    behavior: YGSBehavior(),
                    child: CupertinoPicker(
                      scrollController: scrollControllerC,
                      itemExtent: 45,
                      children: getCity(),
                      onSelectedItemChanged: (int value) {
                        index = value;
                      },

                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(15,10,0,15),child: Icon(Icons.clear,color: CXColors.titleColor_99,)),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(0,10,15,15),child: Icon(Icons.check,color: CXColors.titleColor_99,)),
                    onTap: (){
                      setState(() {
                        cityIndex = index;
                        cityStr = currentCityList[cityIndex]["name"];
                      });
                      Navigator.pop(context);
                      ///更新区列表
                      currentAreaList.clear();
                      areaStr = "请选择区";
                      for(dynamic model in areaList){
                        if(model["parentId"] == currentCityList[cityIndex]["id"]){
                          currentAreaList.add(model);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },);
  }
  getCity() {
    List<Widget> list = [];
    for(int i = 0;i < currentCityList.length;i++){
      list.add(
          Container(
            child: Center(child: Text(currentCityList[i]["name"],style: TextStyle(color: CXColors.BlackColor,fontSize: provinceList[i]["name"].length>3?14:15),)),
          )
      );
    }
    return list;
  }
  void chooseArea() {
    EventBusUtil.getInstance().fire(FocusHide());
    if(currentAreaList.isEmpty){
      Fluttertoast.showToast(msg: "请先选择市");
      return;
    }
    showModalBottomSheet(context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ), builder: (BuildContext context) {
        scrollControllerA = FixedExtentScrollController(initialItem: areaIndex);
        int index = areaIndex;
        return Container(
          height:200,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: EdgeInsets.only(top: 12),
                      child: Text("请选择区",style: TextStyle(color: CXColors.BlackColor,fontSize: 16),)
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ScrollConfiguration(
                    behavior: YGSBehavior(),
                    child: CupertinoPicker(
                      scrollController: scrollControllerA,
                      itemExtent: 45,
                      children: getArea(),
                      onSelectedItemChanged: (int value) {
                        index = value;
                      },

                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(15,10,0,15),child: Icon(Icons.clear,color: CXColors.titleColor_99,)),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(0,10,15,15),child: Icon(Icons.check,color: CXColors.titleColor_99,)),
                    onTap: (){
                      setState(() {
                        areaIndex = index;
                        areaStr = currentAreaList[areaIndex]["name"];
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },);
  }
  getArea() {
    List<Widget> list = [];
    for(int i = 0;i < currentAreaList.length;i++){
      list.add(
          Container(
            child: Center(child: Text(currentAreaList[i]["name"],style: TextStyle(color: CXColors.BlackColor,fontSize: provinceList[i]["name"].length>3?14:15),)),
          )
      );
    }
    return list;
  }


  void mapLocation() {
    EventBusUtil.getInstance().fire(FocusHide());
    EventBusUtil.getInstance().fire(VideoStatus(false));
    //选择定位
    Navigator.push(
        context,
        CustomRoute(
            MapLocationPage(),timer: 200)).then((value) {
      print("location return -> $value");
      latitudeController.text = "${value["latitude"]??''}";
      longitudeController.text = "${value["longitude"]??''}";

      // NetUtil.get("http://api.map.baidu.com/geocoder/v2/?mcode=sha1:com.haohai.fireprevention&callback=renderReverse&location=30.68093376455154,104.06552381979525&output=json&pois=1&ak=GTgjOvUP9u4GaIrszKeqqDF9zB8GK2Fr", (data){
      // NetUtil.get("http://api.map.baidu.com/geocoder/v2/?ak=GTgjOvUP9u4GaIrszKeqqDF9zB8GK2Fr&location=29.07812,119.64759&output=json&pois=1", (data){
      NetUtil.get("http://api.map.baidu.com/reverse_geocoding/v3/?ak=GTgjOvUP9u4GaIrszKeqqDF9zB8GK2Fr&mcode=4E:E0:54:19:7F:52:00:FA:9A:C6:54:C3:71:1E:EA:24:25:47:82:34;com.haohai.fireprevention&output=json&coordtype=wgs84ll&location=${value["latitude"]??''},${value["longitude"]??''}", (data){
        print("baiduApi --> data = $data");
        provinceStr = jsonDecode(data)["result"]["addressComponent"]["province"];
        cityStr = jsonDecode(data)["result"]["addressComponent"]["city"];
        areaStr = jsonDecode(data)["result"]["addressComponent"]["district"];
        addressController.text = jsonDecode(data)["result"]["formatted_address"];
        //省
        for(int i = 0;i < provinceList.length;i++){
          if(provinceList[i]["name"] == provinceStr){
            provinceIndex = i;
          }
        }
        ///更新市列表
        currentCityList.clear();
        currentAreaList.clear();
        for(dynamic model in cityList){
          if(model["parentId"] == provinceList[provinceIndex]["id"]){
            currentCityList.add(model);
          }
        }
        //市
        for(int i = 0;i < currentCityList.length;i++){
          if(currentCityList[i]["name"] == cityStr){
            cityIndex = i;
          }
        }
        ///更新区列表
        currentAreaList.clear();
        for(dynamic model in areaList){
          if(model["parentId"] == currentCityList[cityIndex]["id"]){
            currentAreaList.add(model);
          }
        }
        //区
        for(int i = 0;i < currentAreaList.length;i++){
          if(currentAreaList[i]["name"] == areaStr){
            areaIndex = i;
          }
        }
        setState(() {
        });

      },errorCallBack: (e){
        print("e ==> $e");
        Fluttertoast.showToast(msg: "系统异常");
      });
    });
  }

  void chooseDate() {
    DateTime now = DateTime.now();
    EventBusUtil.getInstance().fire(FocusHide());
    showDatePicker(context: context, initialDate: now, firstDate: now.subtract(Duration(days: 365)), lastDate: now.add(Duration(days: 365))).then((value) {
      DateTime dateTime = value;
      showTimePicker(context: context, initialTime: TimeOfDay(hour: now.hour, minute: now.minute)).then((value) {
        setState(() {
          choosedDate = DateTime(dateTime.year,dateTime.month,dateTime.day,value.hour,value.minute);
          date = choosedDate.toIso8601String();
        });
      });
    });
  }

  Future _getImageFromGallery(context,int num) async {
    List<Asset> resultList = <Asset>[];
    List<File> fileList = <File>[];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: num,
        enableCamera: true,
        selectedAssets: /*images*/[],
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          statusBarColor: "#212C64",
          actionBarColor: "#212C64",
          startInAllView: true,
          selectionLimitReachedText: "最多上传$num张图片",
          actionBarTitle: "选择图片",
          allViewTitle: "所有图片",
          useDetailsView: true,
          selectCircleStrokeColor: "#000000",
        ),
      );
      if(resultList==null || resultList.length==0){
        return;
      }
      EventBusUtil.getInstance().fire(Toloading(title: "图片处理中..."));
      // for(Asset assetModel in resultList){
      for(int i = 0; i < resultList.length;i++){
        Directory dir = await getApplicationDocumentsDirectory();
        var directory = Directory("${dir.path}/haohai");
        if(!directory.existsSync()){
          directory.createSync();
        }
        ByteData byteData = await resultList[i].getByteData();
        File file = await File("${directory.path}/fileName${DateTime.now().microsecondsSinceEpoch+Random().nextInt(99)}.png").writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),flush: true);
        fileList.add(file);
      }
    } on Exception catch (e) {
    }

    if (!mounted) return;

    setState(() {
      images.addAll(fileList);
      EventBusUtil.getInstance().fire(Todismiss(delays: 300));
    });
  }

  getWrapChildren() {
    List<Widget> listW = [];
    for(File imageModel in images){
      listW.add(
        InkWell(
          child: Container(
            width: 170.w,
            margin: EdgeInsets.only(left: 26.w),
            child: Stack(
              children: [
                Image.file(imageModel,width: 170.w,height: 170.w,fit: BoxFit.fill,),
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(child: Image.asset("assets/images/main/app/ic_delete.png",width: 30.w,height: 30.w,fit: BoxFit.fill,),onTap: (){
                    ///删除图片
                    setState(() {
                      images.remove(imageModel);
                    });
                  },),
                ),
              ],
            ),
          ),
          onTap: (){
            EventBusUtil.getInstance().fire(FocusHide());
            ///查看图片
            Navigator.push(context,
                MaterialPageRoute<void>(builder: (BuildContext context) {
                  return PictureShow(imageModel,null);
                }));
          },
        ),
      );
    }
    if(images.length < 2){
      listW.add(
        InkWell(
          child: Container(
            margin: EdgeInsets.only(left: 26.w),
            child: Image.asset("assets/images/main/app/ic_add_photo.png",width: 170.w,height: 170.w,fit: BoxFit.fill,),
          ),
          onTap: (){
            ///添加图片
            EventBusUtil.getInstance().fire(FocusHide());
            _getImageFromGallery(context,2-images.length);
          },
        ),
      );
    }

    return listW;
  }

  Future<void> commitPicture(File image) async {
    NetUtil.postForm("http://api.ehaohai.com:10100/oa/api/workReport/fileUploadAnByNotToken", (data){
      print("FireUpload --> data = $data");
      if(data!=null && data["code"] == 200){
        for(dynamic img in data["data"]["img"]??[]){
          imagesForPost.add("$img");
        }
        imagePostTag++;
        if(imagePostTag == images.length){
          //图片上传完成
          if(video!=null){
            // - 上传视频
            commitVideo();
          }else{
            // - 全部提交
            commit();
          }
        }
      }else{
        EventBusUtil.getInstance().fire(Todismiss());
        if(data!=null && data["message"] != null){
          Fluttertoast.showToast(msg: "${data["message"]}");
        }
      }
    },params: FormData.fromMap({
      "file" : await MultipartFile.fromFile(image.path,filename: "fileName.png"),
    }),errorCallBack: (e){
      EventBusUtil.getInstance().fire(Todismiss());
      Fluttertoast.showToast(msg: "系统异常");
    });
  }

  Future<void> commitVideo() async {
    NetUtil.postForm("http://api.ehaohai.com:10100/oa/api/workReport/fileUploadAnByNotToken", (data){
      print("FireUpload --> data = $data");
      if(data!=null && data["code"] == 200){
        for(dynamic img in data["data"]["img"]??[]){
          videoForPost = "$img";
        }
        // - 全部提交
        commit();
      }else{
        EventBusUtil.getInstance().fire(Todismiss());
        if(data!=null && data["message"] != null){
          Fluttertoast.showToast(msg: "${data["message"]}");
        }
      }
    },params: FormData.fromMap({
      "file" : await MultipartFile.fromFile(video.path,filename: "fireName.mp4"),
    }),errorCallBack: (e){
      EventBusUtil.getInstance().fire(Todismiss());
      Fluttertoast.showToast(msg: "系统异常");
    });
  }

  void commit() {
    NetUtil.post(Api.FireUpload, (data){
      print("FireUpload --> data = $data");
      EventBusUtil.getInstance().fire(Todismiss());
      if(data!=null && data["code"] == 200){
        Fluttertoast.showToast(msg: "上传成功");
        if(mounted){
          Navigator.pop(context);
        }
      }else if(data!=null && data["message"]!=null){
        Fluttertoast.showToast(msg: "${data["message"]}");
      }
    },params: {
      "address" : addressController.text,
      "cityCode" : currentCityList[cityIndex]["id"],
      "cityName" : cityStr,
      "provinceCode" : provinceList[provinceIndex]["id"],
      "provinceName" : provinceStr,
      "longitude" : longitudeController.text,
      "latitude" : latitudeController.text,
      "discoverTime" : "${choosedDate.toIso8601String()}",
      "fireName" : fireNameController.text,
      "fireNo" : "",
      "status" : 0,
      "countyName" : areaStr,
      "countyCode" : currentAreaList[areaIndex]["id"],
      "fireArea" : areaController.text,
      "videoPath1" : "${videoForPost??''}",
      "reporter" : reporterController.text,
      "picPath1" : imagesForPost.length>0?imagesForPost[0]:"",
      "picPath2" : imagesForPost.length>1?imagesForPost[1]:"",
    },errorCallBack: (e){
      EventBusUtil.getInstance().fire(Todismiss());
      Fluttertoast.showToast(msg: "系统异常");
    });
  }

  ///省份总列表（无需筛选）
  List provinceList = [];
  ///市总列表
  List cityList = [];
  ///区总列表
  List areaList = [];
  ///当前省对应是列表
  List currentCityList = [];
  ///当前市对应区列表
  List currentAreaList = [];
  String provinceStr = "请选择省";
  String cityStr = "请选择市";
  String areaStr = "请选择区";
  FixedExtentScrollController scrollControllerP;
  int provinceIndex = 0;
  FixedExtentScrollController scrollControllerC;
  int cityIndex = 0;
  FixedExtentScrollController scrollControllerA;
  int areaIndex = 0;
  void getAreaData() {
    NetUtil.get(Api.AreaData, (data){
      print("AreaData --> data = $data");
      if(data!=null && data["code"] == 200){
        for(dynamic model in data["data"]){
          if(model["level"]==1){
            provinceList.add(model);
          }
          if(model["level"]==2){
            cityList.add(model);
          }
          if(model["level"]==3){
            areaList.add(model);
          }
        }
      }
    });
  }

}

class EditCell extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;

  EditCell(this.controller, this.hint,{this.inputFormatters,this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: 1,
      cursorColor: CXColors.titleColor_99,
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding:
        EdgeInsets.fromLTRB(0.w, 0, 0, 3),
        border: InputBorder.none,
        hintText: '${hint??""}',
        hintStyle: TextStyle(
            color: CXColors.titleColor_cc,
            fontSize: 28.sp),
      ),
      style: TextStyle(
          color: CXColors.titleColor_77,
          fontSize: 28.sp),
    );
  }
}
class LineCell extends StatelessWidget {
  final EdgeInsets margin;

  LineCell({this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CXColors.lineColor_ec,
      height: 1.w,
      width: 1.sw,
      margin: margin,
    );
  }
}

