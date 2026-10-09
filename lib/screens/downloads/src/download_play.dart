import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '/screens/screens.dart';

class DownloadPlay extends StatefulWidget {
  final String path, heading;
  const DownloadPlay({super.key, required this.path, required this.heading});

  @override
  State<DownloadPlay> createState() => _DownloadPlayState();
}

class _DownloadPlayState extends State<DownloadPlay> {
  VideoPlayerController? _controller;
  VoidCallback? _videoListener;

  bool _isMuted = false;
  bool _isFullscreen = false;
  Timer? _hideTimer;
  bool _showControls = true;

  void reload() {
    _controller?.dispose();
    _controller = VideoPlayerController.file(File(widget.path));

    _controller!.initialize().then((value) {
      if (!mounted) return;

      if (_controller!.value.isInitialized) {
        _controller!
          ..play()
          ..setLooping(true);

        _videoListener = () {
          if (mounted) setState(() {});
        };

        _controller!.addListener(_videoListener!);

        setState(() {});
      }
    }).catchError((e) {
      if (mounted) {
        showSnackbar(context, content: e.toString(), isSuccess: false);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    reload();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    if (_videoListener != null) {
      _controller?.removeListener(_videoListener!);
    }
    _controller?.dispose();
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _onInteraction() {
    if (!_showControls) {
      setState(() {
        _showControls = true;
      });
    }
    _startHideTimer();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _togglePlayPause() {
    setState(() {
      _controller!.value.isPlaying ? _controller?.pause() : _controller?.play();
    });
  }

  void _toggleFullscreen() {
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullscreen ? null : appbar(),
      body: _controller != null && _controller!.value.isInitialized
          ? _isFullscreen
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: GestureDetector(
                      onTap: _onInteraction,
                      onPanDown: (_) => _onInteraction(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(child: VideoPlayer(_controller!)),
                          if (_showControls) _buildControls(context),
                        ],
                      ),
                    ),
                  ),
                )
              : AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: GestureDetector(
                    onTap: _onInteraction,
                    onPanDown: (_) => _onInteraction(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(child: VideoPlayer(_controller!)),
                        if (_showControls) _buildControls(context),
                      ],
                    ),
                  ),
                )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        color: Colors.black54,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12.0),
              ),
              child: Slider(
                min: 0.0,
                max: _controller!.value.duration.inMilliseconds.toDouble(),
                value: _controller!.value.position.inMilliseconds
                    .toDouble()
                    .clamp(0.0,
                        _controller!.value.duration.inMilliseconds.toDouble()),
                onChanged: (value) {
                  _onInteraction(); // keep controls visible
                  _controller!.seekTo(Duration(milliseconds: value.toInt()));
                },
                activeColor: Colors.redAccent,
                inactiveColor: Colors.white54,
              ),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: "Play/Pause",
                  icon: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _togglePlayPause();
                    _onInteraction();
                  },
                ),
                IconButton(
                  tooltip: "Mute/Unmute",
                  icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white),
                  onPressed: () {
                    _toggleMute();
                    _onInteraction();
                  },
                ),
                Text(
                  '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
                  style: const TextStyle(color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  tooltip: "Full Screen",
                  icon: Icon(
                    _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _toggleFullscreen();
                    _onInteraction();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar appbar() {
    return AppBar(
      leading: IconButton(
        tooltip: "Back",
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: blackColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      centerTitle: true,
      title: Text(widget.heading),
      iconTheme: IconThemeData(color: whiteColor),
      backgroundColor: whiteColor,
    );
  }
}
