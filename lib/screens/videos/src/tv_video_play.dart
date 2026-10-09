import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '/screens/screens.dart';
import '/services/services.dart';

class TvVideoPlay extends StatefulWidget {
  final String videoUrl;
  final String fav;
  const TvVideoPlay({super.key, required this.videoUrl, required this.fav});

  @override
  State<TvVideoPlay> createState() => _TvVideoPlayState();
}

class _TvVideoPlayState extends State<TvVideoPlay> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isBuffering = true;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  int _focusedButtonIndex = 1; // Default focus on Play/Pause
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final FocusNode _mainFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[_focusedButtonIndex]);
    });
  }

  void _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isBuffering = false;
          });
          _controller.play();
          _startHideControlsTimer();
        }
      })
      ..addListener(_videoListener);
  }

  void _videoListener() {
    if (_controller.value.isPlaying != _isPlaying && mounted) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
        if (_isPlaying) {
          _startHideControlsTimer();
        } else {
          _showControls = true;
          _hideControlsTimer?.cancel();
        }
      });
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying && mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _showControls = true;
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        _startHideControlsTimer();
      }
    });
  }

  void _seekForward() {
    _controller
        .seekTo(_controller.value.position + const Duration(seconds: 10));
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  void _seekBackward() {
    _controller
        .seekTo(_controller.value.position - const Duration(seconds: 10));
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  _addOrRemFav() async {
    var isFavorite = await LocalDBConfig().checkFavorite(widget.fav);

    if (isFavorite) {
      await LocalDBConfig().removeFavorite(widget.fav);
      showSnackbar(context,
          content: "Video removed from favorites", isSuccess: true);
    } else {
      await LocalDBConfig().setFavorite(videoDetails: widget.fav);
      showSnackbar(context,
          content: "Video added to favorites", isSuccess: true);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    _mainFocusNode.dispose();
    super.dispose();
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required int index,
  }) {
    bool isFocused = _focusedButtonIndex == index;
    return GestureDetector(
      onTap: onPressed,
      child: Focus(
        focusNode: _focusNodes[index],
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            setState(() {
              _focusedButtonIndex = index;
              _showControls = true;
            });
            _startHideControlsTimer();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isFocused ? Colors.red.withOpacity(0.3) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isFocused ? Colors.red : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 40,
            color: isFocused ? Colors.red : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: _mainFocusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter) {
              if (!_showControls) {
                setState(() {
                  _showControls = true;
                  _focusedButtonIndex = 1; // Focus on play/pause
                });
                _startHideControlsTimer();
              } else {
                // Perform action based on focused button
                switch (_focusedButtonIndex) {
                  case 0:
                    _seekBackward();
                    break;
                  case 1:
                    _togglePlayPause();
                    break;
                  case 2:
                    _seekForward();
                  case 3:
                    _addOrRemFav();
                    break;
                }
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              if (_showControls && _focusedButtonIndex < 3) {
                // Change 2 → 3
                setState(() => _focusedButtonIndex++);
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              if (_showControls && _focusedButtonIndex > 0) {
                setState(() => _focusedButtonIndex--);
              }
            }
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            _controller.value.isInitialized
                ? VideoPlayer(_controller)
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
            if (_isBuffering)
              const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            if (_showControls)
              ColoredBox(
                color: Colors.black54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: false,
                        colors: const VideoProgressColors(
                          playedColor: Colors.red,
                          bufferedColor: Colors.grey,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlButton(
                            icon: Icons.replay_10,
                            onPressed: _seekBackward,
                            index: 0,
                          ),
                          _buildControlButton(
                            icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                            onPressed: _togglePlayPause,
                            index: 1,
                          ),
                          _buildControlButton(
                            icon: Icons.forward_10,
                            onPressed: _seekForward,
                            index: 2,
                          ),
                          FutureBuilder<bool>(
                            future: LocalDBConfig().checkFavorite(widget.fav),
                            builder: (context, snapshot) {
                              bool isFavorite = snapshot.data ?? false;

                              return _buildControlButton(
                                icon: isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                onPressed: _addOrRemFav,
                                index: 3,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
