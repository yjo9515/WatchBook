import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../controller/video_controller.dart';

class VideoWidget extends StatelessWidget {
  final String url;
  late VideoPlayerController _controller;
  var controller = Get.put(VideoController());
  initState(){
    print(url);
    _controller = VideoPlayerController.network(
        'https://www.smartdoor.watchbook.tv${url}')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        controller.allUpdate();
        return _controller.value.isInitialized;
      });
  }
  VideoWidget({
    required this.url,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      //Dialog Main Title
      title: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text("동영상 재생")],
        ),
      ),
      //
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
            FutureBuilder(
            future: initState(),
            builder: (context, snapshot) {
            if (snapshot.hasData) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
            }else{
              return Container();
            }
            }),
        ],
      ),
      actions: <Widget>[
        FloatingActionButton(
          onPressed: () {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
        TextButton(
          child: const Text("뒤로가기"),
          onPressed: () {
            Get.back();
          },
        ),
      ],
    );
  }
}