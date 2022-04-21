class EventBusModel {}

class Splash {
  int tag;
  Splash(this.tag);
}
class MaintabIndex {
  int tabIndex;
  MaintabIndex(this.tabIndex);
}
class MessageCenter {
  MessageCenter();
}
class Toloading {
  String title;

  Toloading({this.title});

}
class PushTouch {

  PushTouch();

}
class VideoStatus {
  bool show;
  VideoStatus(this.show);

}
class Todismiss {
  int delays;

  Todismiss({this.delays});

}
class FocusHide {
  FocusHide();
}
class EndUpload {
  EndUpload();
}
class ShowToast {
  String msg;
  ShowToast(this.msg);
}
class DispatchTaskList {
  DispatchTaskList();
}
class GuideModel {
  GuideModel();
}
class MarkerDetail {
  String type;
  dynamic data;
  bool pop = false;

  MarkerDetail(this.type,this.data,{this.pop});
}
class PlayerInit {
  String url;
  String monitorId;
  String channelId;
  bool isState;
  PlayerInit(this.url, this.monitorId,this.channelId,this.isState);

}
class MapResourceCamera {
  String monitorId;
  String channelId;
  bool force;
  MapResourceCamera(this.monitorId,this.channelId,{this.force});

}
class LocationRefresh {
  double latitude;
  double longitude;
  bool zoom;
  LocationRefresh(this.latitude, this.longitude,{this.zoom});

}
class MesurePlayer {
  double width;
  double height;
  MesurePlayer(this.width, this.height);

}
class LiveController {
  ///remove control
  String type;
  ///move distance
  String function;
  ///3：上，4：下，1：左，2：右，7：左上，8：左下，9：右上，10：右下  拉进5 拉远6
  int value;
  ///true 控制  false 停止
  bool clickType;

  LiveController({this.type,this.value,this.function,this.clickType});
}
