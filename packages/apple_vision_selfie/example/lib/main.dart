import 'package:apple_vision_selfie/apple_vision_selfie.dart';
import 'package:flutter/material.dart';
import '../camera/camera_insert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'camera/input_image.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VisionSelfie(),
    );
  }
}

class VisionSelfie extends StatefulWidget {
  const VisionSelfie({Key? key, this.onScanned}) : super(key: key);

  final Function(dynamic data)? onScanned;

  @override
  _VisionSelfie createState() => _VisionSelfie();
}

class _VisionSelfie extends State<VisionSelfie> {
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  late AppleVisionSelfieController visionController = AppleVisionSelfieController();
  InsertCamera camera = InsertCamera();
  String? deviceId;
  bool loading = true;

  List<Uint8List?>? selfieImage;
  late double deviceWidth;
  late double deviceHeight;
  Uint8List? bg;

  @override
  void initState() {
    rootBundle.load('assets/WaterOnTheMoonFull.jpg').then((value) {
      bg = value.buffer.asUint8List();
    });
    camera.setupCameras().then((value) {
      setState(() {
        loading = false;
      });
      camera.startLiveFeed((InputImage i) {
        // if (i.metadata?.size != null) {
        //   imageSize = i.metadata!.size;
        // }
        if (mounted) {
          Uint8List? image = i.bytes;
          visionController
              .processImage(
            SelfieSegmentationData(
              image: image!,
              imageSize: i.metadata!.size,
              quality: SelfieQuality.fast,
              gamma: 3.0,
            ),
          )
              .then((data) {
            selfieImage = data;
            setState(() {});
          });
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    return Image.memory(
      selfieImage![0]!,
      width: deviceWidth,
      height: deviceHeight,
      fit: BoxFit.fill,
    );
  }

  Widget loadingWidget() {
    return Container(
      width: deviceWidth,
      height: deviceHeight,
      color: Theme.of(context).canvasColor,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: Colors.blue),
    );
  }
}
