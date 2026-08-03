import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:stackfood_multivendor/common/widgets/no_internet_screen_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/deep_link_body.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? notificationBody;
  final DeepLinkBody? linkBody;
  const SplashScreen({super.key, required this.notificationBody, required this.linkBody});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.asset(Images.splashVideo)
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isVideoInitialized = true);
          _videoPlayerController.play();
        }
      });

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

      if(!firstTime) {
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 6 : 6000),
          content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
        ));
        if(isConnected) {
          _route();
        }else {
          Get.to(const NoInternetScreen());
        }
      }



      firstTime = false;

    });

    Get.find<SplashController>().initSharedData();
    if(AddressHelper.getAddressFromSharedPref() != null && (AddressHelper.getAddressFromSharedPref()!.zoneIds == null
        || AddressHelper.getAddressFromSharedPref()!.zoneData == null)) {
      AddressHelper.clearAddressFromSharedPref();
    }
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<CartController>().getCartDataOnline();
    }
    _route();

  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged?.cancel();
    _videoPlayerController.dispose();
  }

  void _route() {
    Get.find<SplashController>().getConfigData(handleMaintenanceMode: false, notificationBody: widget.notificationBody);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Center(
          child: splashController.hasConnection ? (_isVideoInitialized ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoPlayerController.value.size.width,
                height: _videoPlayerController.value.size.height,
                child: VideoPlayer(_videoPlayerController),
              ),
            ),
          ) : const SizedBox()) : NoInternetScreen(child: SplashScreen(notificationBody: widget.notificationBody, linkBody: widget.linkBody)),
        );
      }),
    );
  }
}
