import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/utils/date_time.dart';
import 'package:discourse/utils/url_preview.dart';
import 'package:discourse/views/chat/widgets/message_view.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SpotifyMessageView extends StatefulWidget {
  final Message message;

  const SpotifyMessageView({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<SpotifyMessageView> createState() => _SpotifyMessageViewState();
}

class _SpotifyMessageViewState extends State<SpotifyMessageView> {
  bool _loading = true;
  UrlData? _urlData;

  @override
  void initState() {
    super.initState();
    _loadUrlData();
  }

  Future<void> _loadUrlData() async {
    setState(() => _loading = true);
    _urlData = await getUrlData(widget.message.text!);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Align(
        alignment: widget.message.fromMe
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _loading
            ? _buildLoading()
            : _urlData == null
                ? MessageView(message: widget.message) // simple
                : _buildMain(),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: Palette.black2,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildMain() {
    return OpacityFeedback(
      onPressed: () {
        launchUrlString(
          widget.message.text!,
          mode: LaunchMode.externalNonBrowserApplication,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        // for some reason Clip.antiAlias causes a subtle problem (adds a thin 1px padding below the gradient)
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: _urlData!.photoUrl!,
              width: 240,
              height: 240,
            ),
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _urlData!.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _urlData!.description.split(' · ')[0],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 14,
              bottom: 12,
              child: Text(
                formatTime(widget.message.sentTimestamp),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
