import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../utils.dart';
import '../controller/story_controller.dart';

class VideoLoader {
  String url;

  // File? videoFile;

  // Map<String, dynamic>? requestHeaders;

  LoadState state = LoadState.loading;

  VideoLoader(this.url);

  // void loadVideo(VoidCallback onComplete) {
  //   if (this.videoFile != null) {
  //     this.state = LoadState.success;
  //     onComplete();
  //   }

  //   final fileStream = DefaultCacheManager()
  //       .getFileStream(this.url, headers: this.requestHeaders as Map<String, String>?);

  //   fileStream.listen((fileResponse) {
  //     if (fileResponse is FileInfo) {
  //       if (this.videoFile == null) {
  //         this.state = LoadState.success;
  //         this.videoFile = fileResponse.file;
  //         onComplete();
  //       }
  //     }
  //   });
}

class StoryVideo extends StatefulWidget {
  final StoryController? storyController;
  final VideoLoader videoLoader;
  double? aspectRatio;

  StoryVideo(this.videoLoader, {this.storyController, this.aspectRatio, Key? key}) : super(key: key ?? UniqueKey());

  static StoryVideo url(String url, {StoryController? controller, double? aspectRatio, Map<String, dynamic>? requestHeaders, Key? key}) {
    return StoryVideo(
      VideoLoader(url),
      storyController: controller,
      aspectRatio: aspectRatio,
      key: key,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return StoryVideoState();
  }
}

class StoryVideoState extends State<StoryVideo> {
  Future<void>? playerLoader;

  StreamSubscription? _streamSubscription;
  YoutubePlayerController? youtubePlayerController;
  VideoPlayerController? playerController;

  @override
  void initState() {
    super.initState();

    widget.storyController!.pause();

    youtubePlayerController = YoutubePlayerController(initialVideoId: widget.videoLoader.url)..addListener(() {});
    widget.videoLoader.state = LoadState.success;
    //   widget.videoLoader.loadVideo(() {
    //     if (widget.videoLoader.state == LoadState.success) {
    //       this.playerController =
    //           VideoPlayerController.file(widget.videoLoader.videoFile!);

    //       playerController!.initialize().then((v) {
    //         setState(() {});
    //         widget.storyController!.play();
    //       });

    //       if (widget.storyController != null) {
    //         _streamSubscription =
    //             widget.storyController!.playbackNotifier.listen((playbackState) {
    //           if (playbackState == PlaybackState.pause) {
    //             playerController!.pause();
    //           } else {
    //             playerController!.play();
    //           }
    //         });
    //       }
    //     } else {
    //       setState(() {});
    //     }
    //   });
  }

  Widget getContentView() {
    if (widget.videoLoader.state == LoadState.success) {
      return Center(
        child: YoutubePlayer(
          aspectRatio: widget.aspectRatio ?? 16.0 / 9.0,
          controller: youtubePlayerController!,
          showVideoProgressIndicator: true,
            onReady: () {
            setState(() {
              widget.storyController!.play();
              widget.videoLoader.state = LoadState.success;
            });
          },
          ),
        
      );
    }

    return widget.videoLoader.state == LoadState.loading
        ? const Center(
            child: SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          )
        : const Center(
            child: Text(
            "Media failed to load.",
            style: TextStyle(
              color: Colors.white,
            ),
          ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: getContentView(),
    );
  }

  @override
  void dispose() {
    playerController?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
