import 'package:flutter/cupertino.dart';
import 'package:teams_clone/enum/view_state.dart';

// Used to notify users if the image is uploading --> Loading or idle
class ImageUploadProvider with ChangeNotifier{
  ViewState _viewState = ViewState.IDLE;
  ViewState get getViewState => _viewState;
  void setToLoading(){
    _viewState = ViewState.LOADING;
    notifyListeners();
  }

  void setToIdle(){
    _viewState = ViewState.IDLE;
    notifyListeners();
  }

}