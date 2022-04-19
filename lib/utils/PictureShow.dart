import 'dart:io';

import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PictureShow extends StatefulWidget{
  final File fileS;
  final String url;

  PictureShow(this.fileS,this.url);//url 为null 则文件

  @override
  State<StatefulWidget> createState() {
    return PictureShowState();
  }

}

class PictureShowState extends State<PictureShow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseScaffold(
        title: "图片详情",
        leftImage: "assets/images/common/ic_back.png",
        leftImageSize: 40.w,
        titleSize: 30.sp,
        leftCallback: (){
          Navigator.pop(context);
        },
        body: SizedBox.expand(
          child: Hero(
            tag: 1,
            child: Photo(fileS: widget.fileS,url: widget.url,),
          ),
        ),
      ),
    );
  }
}


class Photo extends StatefulWidget {
  const Photo({Key key, this.fileS, this.url}) : super(key: key);
  final fileS;//url 为null 则文件
  final url;

  @override
  State<StatefulWidget> createState() {
    return PhotoState();
  }
}

class PhotoState extends State<Photo> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _animation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;
  double _kMinFlingVelocity = 600.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      setState(() {
        _offset = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    // widget的屏幕宽度
    final Offset minOffset = Offset(size.width, size.height) * (1.0 - _scale);
    // 限制他的最小尺寸
    return Offset(
        offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      // 计算图片放大后的位置
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 3.0);
      // 限制放大倍数 1~3倍
      _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
      // 更新当前位置
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (magnitude < _kMinFlingVelocity) return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    // 计算当前的方向
    final double distance = (Offset.zero & context.size).shortestSide;
    // 计算放大倍速，并相应的放大宽和高，比如原来是600*480的图片，放大后倍数为1.25倍时，宽和高是同时变化的
    _animation = _controller.drive(Tween<Offset>(
        begin: _offset, end: _clampOffset(_offset + direction * distance)));
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleOnScaleStart,
      onScaleUpdate: _handleOnScaleUpdate,
      onScaleEnd: _handleOnScaleEnd,
      child: ClipRect(
        child: Transform(
          transform: Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: widget.url==null?
              Image.file(
            widget.fileS,
            fit: BoxFit.scaleDown,
          ):FadeInImage.assetNetwork(image: widget.url, fit: BoxFit.scaleDown, placeholder: "assets/images/common/ic_no_pic.png",),
        ),
      ),
    );
  }
}