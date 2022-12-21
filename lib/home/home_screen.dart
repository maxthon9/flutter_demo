import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var image1 = "storage/emulated/0/CreateVideo/image1.jpeg";
  var image2 = "storage/emulated/0/CreateVideo/image2.jpeg";
  var gifFile = "storage/emulated/0/CreateVideo/nature.gif";
  var songFile = "storage/emulated/0/CreateVideo/prems.mp3";
  var videoFile = "storage/emulated/0/CreateVideo/videoFile.mp4";
  var firstVideo = "storage/emulated/0/CreateVideo/firstVideo.mp4";

  var isLoading = false;

  File? imagePath;
  File? songPath;

  //storage/emulated/0/Android/data/com.maxthontechnologies.chat_app/files
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "File Merger",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    selectImages();
                    setState(() {});
                  },
                  child: Container(
                    height: 45,
                    width: 120,
                    alignment: AlignmentDirectional.center,
                    decoration: BoxDecoration(
                      color: imagePath!=null ? Colors.green : Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      imagePath!=null ? "Done" : "Select Image",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    selectSongs();
                    setState(() {});
                  },
                  child: Container(
                    height: 45,
                    width: 120,
                    alignment: AlignmentDirectional.center,
                    decoration: BoxDecoration(
                      color: songPath!=null ? Colors.green : Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      songPath!=null ? "Done" : "Select Song",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isLoading)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2.5,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Loading...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                  )
                ],
              ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                if(imagePath!=null && songPath!=null){
                  await videoMerger();
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please Select Image & Song!"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                setState(() {});
              },
              child: Container(
                height: 45,
                width: 120,
                alignment: AlignmentDirectional.center,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "Process",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Future<void> videoMerger() async{
  //   final FlutterFFmpeg ffMpeg = FlutterFFmpeg();
  //
  //   Permission.storage.request();
  //   if(await Permission.storage.request().isGranted){
  //     /// Gif With AUDIO MERGER
  //     String commandToExecute = '-r 15 -f mp3 -i $songFile -f gif -re -stream_loop 5 -i $gifFile -y $videoFile';
  //     /// Image With AUDIO MERGER
  //     //String commandToExecute = '-r 15 -f mp3 -i $songFile -f image2 -i $image1 -y $videoFile';
  //     ffMpeg.execute(commandToExecute)
  //         .then((rc) => print("Return code $rc"));
  //   }else if(await Permission.storage.isPermanentlyDenied || await Permission.storage.isDenied){
  //     openAppSettings();
  //   }
  //
  // }

  Future<void> videoMerger() async {
    Permission.storage.request();
    if (await Permission.storage.request().isGranted) {
      setState(() {
        isLoading = true;
      });
      print(songPath!.path);
      String commandToExecute = '-r 15 -f mp3 -i ${songPath!.path} -f image2 -i ${imagePath!.path} -y $videoFile';
      //String commandToExecute = '-r 15 -f mp3 -i $songFile -f gif -re -stream_loop 5 -i $gifFile -y $videoFile';
      // String commandToExecute = '-i $firstVideo -c:v mpeg4 $videoFile';
      FFmpegKit.execute(commandToExecute).then((session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          print("FFMPEG Process Exited SUCCESS :: $ReturnCode");
          // SUCCESS

        } else if (ReturnCode.isCancel(returnCode)) {
          // CANCEL
          print("FFMPEG Process Exited CANCEL :: $ReturnCode");
        } else {
          // ERROR
          print("FFMPEG Process Exited ERROR :: $ReturnCode");
        }
        setState(() {
          isLoading = false;
        });
      });
    } else if (await Permission.storage.isPermanentlyDenied || await Permission.storage.isDenied) {
      openAppSettings();
    }
  }

  Future<void> selectImages() async {
    try{
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'gif'],
      );

      if (result != null) {
        File file = File(result.files.first.path.toString());
        print("File :: ${file.path}");
        setState((){
          imagePath = file;
        });
      } else {
        // User canceled the picker
      }
    }catch(e){
      print("Error : $e");
    }
  }

  Future<void> selectSongs() async {
    try{
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path.toString());
        print("File :: ${file.path}");
        setState((){
          songPath = file;
        });
      } else {
        // User canceled the picker
      }
    }catch(e){
      print("Error : $e");
    }
  }
}
