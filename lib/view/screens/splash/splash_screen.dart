import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity/connectivity.dart';
import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/util/app_constants.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const sound = ['my_audio.mp3'];

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  playSound() {
    AudioCache cache = new AudioCache();
    cache.play('audio/my_audio.mp3');
    print('Sounds play 1: ${cache.play('assets/audio/my_audio.mp3')}');
  }

  @override
  void initState() {
    playSound();
    super.initState();

    bool _firstTime = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (!_firstTime) {
        bool isNotConnected = result != ConnectivityResult.wifi &&
            result != ConnectivityResult.mobile;
        isNotConnected
            ? SizedBox()
            : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection' : 'connected',
            textAlign: TextAlign.center,
          ),
        ));
        if (!isNotConnected) {
          _route();
        }
      }
      _firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    _route();
  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) {
      if (isSuccess) {
        Timer(Duration(seconds: 1), () async {
          if (Get.find<AuthController>().isLoggedIn()) {
            Get.find<AuthController>().updateToken();
            await Get.find<AuthController>().getProfile();
            Get.offNamed(RouteHelper.getInitialRoute());
          } else {
            if (AppConstants.languages.length > 1 &&
                Get.find<SplashController>().showIntro()) {
              Get.offNamed(RouteHelper.getLanguageRoute('splash'));
            } else {
              Get.offNamed(RouteHelper.getSignInRoute());
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Center(
        child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: InkWell(
                onTap: () {
                  sound.map((e) => playSound());
                  playSound();
                  print('play sounds:');
                },
                child: Image.network(
                  "https://i.pinimg.com/originals/5f/52/b4/5f52b4921038dca837ebc4a2188372ff.gif",
                  fit: BoxFit.cover,
                ))),
      ),
    );
  }
}
