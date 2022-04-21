import 'dart:io';
import 'dart:math';

import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/base/YGSBehavior.dart';
import 'package:fireprevention/main/map/MapLocationPage.dart';
import 'package:fireprevention/model/CustomerModel.dart';
import 'package:fireprevention/model/EventBusModel.dart';
import 'package:fireprevention/network/Api.dart';
import 'package:fireprevention/network/NetUtil.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/CustomRoute.dart';
import 'package:fireprevention/utils/CustomerLayout.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:fireprevention/utils/PictureShow.dart';
import 'package:fireprevention/utils/VideoScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';

class LiveUploadPage extends StatefulWidget {
  final dynamic arguments;

  LiveUploadPage(this.arguments);

  @override
  _LiveUploadPageState createState() => _LiveUploadPageState();
}

class _LiveUploadPageState extends State<LiveUploadPage> {
  TextEditingController liveController = TextEditingController();
  TextEditingController otherController = TextEditingController();
  List<File> images = [];
  File video;
  List<String> forpostImageList = [];
  List<String> forpostVideoList = [];
  String longitude = "";
  String latitude = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: BaseScaffold(
        title: "现场上报",
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
                          child: Text("添加图片",style: TextStyle(color: CXColors.titleColor_55,fontSize: 28.sp),),
                        ),
                        Wrap(
                          children: getWrapChildren(),
                        ),
                        ///添加视频
                        Container(
                          margin: EdgeInsets.all(20.w),
                          child: Row(
                            children: [
                              Text("上传视频: ",style: TextStyle(color: CXColors.titleColor_55,fontSize: 28.sp),),
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
                              InkWell(child: Text("  视频选择",style: TextStyle(color: CXColors.titleColor_55,fontSize: 26.sp),),onTap: () async {
                                EventBusUtil.getInstance().fire(FocusHide());
                                var videoGet = await ImagePicker().getVideo(source: ImageSource.gallery,);
                                if(videoGet!=null){
                                  EventBusUtil.getInstance().fire(Toloading(title: "视频处理中..."));
                                  print("path = ${videoGet.path}");
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
                            padding: EdgeInsets.fromLTRB(20.w, 5.w, 20.w, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  child: Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.only(right: 5.w),
                                    height: 90.w,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("经纬度   $longitude $latitude",style: TextStyle(color: CXColors.titleColor_99,fontSize: 26.sp),),
                                        Image.asset("assets/images/main/app/ic_tomap.png",width: 36.w,height: 36.w,),
                                      ],
                                    ),
                                  ),
                                  onTap: (){
                                    ///选择定位
                                    Navigator.push(
                                        context,
                                        CustomRoute(
                                            MapLocationPage(),timer: 200)).then((value) {
                                      print("location return -> $value");
                                      longitude = "${value["longitude"]??''}";
                                      latitude = "${value["latitude"]??''}";
                                      setState(() {
                                      });
                                    });
                                  },
                                ),
                                LineCell(),
                                EditCell(liveController,"现场情况"),
                                LineCell(),
                                EditCell(otherController,"其他信息"),
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
                  backgroundColor: CXColors.maintab,
                  margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 30.w),
                  borderRadius: 60.w,
                  onPressed: (){
                    EventBusUtil.getInstance().fire(FocusHide());
                    if((images==null || images.length==0) && video==null){
                      Fluttertoast.showToast(msg: "请至少上传一个图片或视频");
                      return;
                    }
                    commit();
                  },
                ),
              ),
            ],
          );
        },),
      ),
    );
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
      for(Asset assetModel in resultList){
        Directory dir = await getApplicationDocumentsDirectory();
        var directory = Directory("${dir.path}/haohai");
        if(!directory.existsSync()){
          directory.createSync();
        }
        ByteData byteData = await assetModel.getByteData();
        File file = await File("${directory.path}/liveUpload${DateTime.now().microsecondsSinceEpoch+Random().nextInt(99)}.png").writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),flush: true);
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

  void commit() {
    EventBusUtil.getInstance().fire(Toloading(title: "正在提交..."));
    if(images!=null && images.length!=0){
      ///上传图片到服务器
      postPic();
    }else{
      ///上传视频到服务器
      postVideo();
    }
  }

  Future<void> postPic() async {
    forpostImageList.clear();
    for(File imgFile in images){
      NetUtil.postForm("http://api.ehaohai.com:10100/oa/api/workReport/fileUploadAnByNotToken", (data){
        print("LiveUploadPic --> data = $data");
        if(data!=null && data["code"] == 200){
          for(String imgStr in data["data"]["img"]){
            forpostImageList.add(imgStr);
            if(forpostImageList.length ==  images.length){
              if(video!=null){
                ///上传视频到服务器
                postVideo();
              }else{
                ///保存提交
                postCommit();
              }
            }
          }
        }else{
          EventBusUtil.getInstance().fire(Todismiss());
          if(data!=null && data["message"] != null){
            Fluttertoast.showToast(msg: "${data["message"]}");
          }
        }
      },params: FormData.fromMap({
        "file" : await MultipartFile.fromFile(imgFile.path,filename: "fireName.png"),
      }),errorCallBack: (e){
        Fluttertoast.showToast(msg: "图片保存失败");
        EventBusUtil.getInstance().fire(Todismiss());
        return;
      });
    }
  }
  Future<void> postVideo() async {
    forpostVideoList.clear();
    NetUtil.postForm("http://api.ehaohai.com:10100/oa/api/workReport/fileUploadAnByNotToken", (data){
      print("LiveUploadVideo --> data = $data");
      if(data!=null && data["code"] == 200){
        for(dynamic videoStr in data["data"]["img"]){
          forpostVideoList.add("${videoStr??""}");
        }
        postCommit();
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
  void postCommit() {
    NetUtil.post(Api.LiveUploadCommit, (data){
      print("LiveUploadCommit --> data = $data");
      EventBusUtil.getInstance().fire(Todismiss());
      if(data!=null && data["code"] == 200){
        Fluttertoast.showToast(msg: "上传成功");
        if(mounted){
          EventBusUtil.getInstance().fire(EndUpload());
          Navigator.pop(context);
        }
      }else{
        Fluttertoast.showToast(msg: "${data["message"]??""}");
      }
    },params: commitParams(),errorCallBack: (e){
      Fluttertoast.showToast(msg: "网络异常，请稍后重试");
      EventBusUtil.getInstance().fire(Todismiss());
    });
  }

  commitParams() {
    String imgUrl = "";
    for(String img in forpostImageList){
      if(imgUrl == ""){
        imgUrl = img;
      }else{
        imgUrl = imgUrl + ',' + img;
      }
    }
    return {
      "siteConditions": liveController.text,
      "otherConditions": otherController.text,
      "groupId": CustomerModel.groupId,
      "videoUrl": forpostVideoList.length>0?forpostVideoList[0]:"",
      "imgUrl": imgUrl,
      "taskId": widget.arguments["taskId"],
      "latitude": latitude,
      "longitude": longitude,
    };
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
            fontSize: 26.sp),
      ),
      style: TextStyle(
          color: CXColors.titleColor_77,
          fontSize: 26.sp),
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

