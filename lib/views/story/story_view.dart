import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class StoryView extends StatefulWidget {
  final String title;
  final List<StoryPage> story;
  final Future Function() onShowOptions;

  const StoryView({
    Key? key,
    required this.title,
    required this.story,
    required this.onShowOptions,
  }) : super(key: key);

  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  AnimationController? _animController;
  DateTime? _initTime;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this);
    _animController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController!.stop();
        _animController!.reset();
        if (_currentPage + 1 < widget.story.length) {
          setState(() => _currentPage += 1);
          _loadCurrentStory();
        } else {
          Get.back();
        }
      }
    });
    _loadCurrentStory();
  }

  @override
  void dispose() {
    _animController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: onTapDown,
            onTapUp: onTapUp,
            child: (() {
              final page = widget.story[_currentPage];
              switch (page.type) {
                case StoryType.text:
                  return Container(
                    color: Palette.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      page.content,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                case StoryType.photo:
                  return Material(
                    // make region clickable
                    child: PhotoView(
                      backgroundDecoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      scaleStateChangedCallback: (scaleState) {
                        if (scaleState.name == 'zoomedIn') {
                          _animController!.stop();
                        } else {
                          _animController!.forward();
                        }
                      },
                      imageProvider: CachedNetworkImageProvider(page.content),
                    ),
                  );
              }
            })(),
          ),
          _buildTop(),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Swipe up to respond',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTop() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0),
            ],
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          12,
          18 + Get.mediaQuery.padding.top,
          12,
          50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(width: 8),
                for (var i = 0; i < widget.story.length; i++)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: EdgeInsets.only(
                        right: i + 1 < widget.story.length ? 8 : 0,
                      ),
                      color:
                          Colors.white.withOpacity(i < _currentPage ? 1 : 0.4),
                      alignment: Alignment.centerLeft,
                      child: i == _currentPage
                          ? LayoutBuilder(
                              builder: (context, constraints) =>
                                  AnimatedBuilder(
                                animation: _animController!,
                                builder: (context, child) => Container(
                                  width: constraints.maxWidth *
                                      _animController!.value,
                                  height: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                SizedBox(width: 8),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                MyIconButton(
                  FluentIcons.chevron_left_24_regular,
                  onPressed: Get.back,
                ),
                SizedBox(width: 4),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.8,
                  ),
                ),
                Spacer(),
                MyIconButton(
                  FluentIcons.more_vertical_24_regular,
                  onPressed: () async {
                    _animController!.stop();
                    await widget.onShowOptions();
                    _animController!.forward();
                  },
                ),
              ],
            ),
          ],
        ),
      );

  void onTapDown(TapDownDetails details) {
    _initTime = DateTime.now();
    // pause
    _animController!.stop();
  }

  void onTapUp(TapUpDetails details) {
    if (DateTime.now().difference(_initTime!) > Duration(milliseconds: 200)) {
      // long tap; ignore
      _animController!.forward();
      return;
    }
    final dx = details.globalPosition.dx;
    if (dx < Get.width / 2) {
      if (_currentPage == 0) {
        _animController!.forward();
        return;
      }
      setState(() => _currentPage -= 1);
      _loadCurrentStory();
    } else {
      if (_currentPage + 1 < widget.story.length) {
        setState(() => _currentPage += 1);
        _loadCurrentStory();
      } else {
        // reached the end
        Get.back();
      }
    }
  }

  void _loadCurrentStory() {
    _animController!.stop();
    _animController!.reset();
    _animController!.duration = Duration(seconds: 4);
    _animController!.forward();
  }
}
