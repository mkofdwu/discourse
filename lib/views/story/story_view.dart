import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoryView extends StatefulWidget {
  final String title;
  final List<StoryPage> story;

  const StoryView({
    Key? key,
    required this.title,
    required this.story,
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
                    child: Center(
                      child: CachedNetworkImage(imageUrl: page.content),
                    ),
                  );
              }
            })(),
          ),
          _buildTop(),
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
          28,
          20 + Get.mediaQuery.padding.top,
          28,
          50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
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
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                OpacityFeedback(
                  child: Icon(FluentIcons.chevron_left_24_regular, size: 24),
                  onPressed: Get.back,
                ),
                SizedBox(width: 16),
                Text(
                  'Your story',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                Spacer(),
                OpacityFeedback(
                  child: Icon(FluentIcons.more_vertical_24_regular, size: 24),
                  onPressed: () {},
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
    if (dx < Get.width / 3) {
      if (_currentPage == 0) {
        _animController!.forward();
        return;
      }
      setState(() => _currentPage -= 1);
      _loadCurrentStory();
    } else if (dx > Get.width * 2 / 3) {
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
