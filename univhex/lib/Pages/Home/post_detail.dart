import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:univhex/Constants/AppColors.dart';
import 'package:univhex/Constants/current_user.dart';
import 'package:univhex/Objects/app_comment.dart';
import 'package:univhex/Objects/post_interaction_bar.dart';
import 'package:univhex/Objects/univhex_post.dart';
import 'package:univhex/Objects/univhex_post_widget.dart';

import '../../Objects/comment_widget.dart';

@RoutePage(name: "PostDetailRoute")
class PostDetail extends StatefulWidget {
  PostDetail(
      {super.key,
      required this.post,
      required this.autoFocus,
      required this.refreshHome});
  final UnivhexPost post;
  final bool autoFocus;
  VoidCallback? refreshHome;
  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  TextEditingController _controller = TextEditingController();

  late ImageProvider<Object> _avatarImageProvider;
  void _loadAvatarImage() {
    if (CurrentUser.user!.imgUrl == "assets/images/icon.png") {
      _avatarImageProvider = AssetImage("assets/images/icon.png");
    } else {
      _avatarImageProvider = NetworkImage(CurrentUser.user!.imgUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadAvatarImage();

    return WillPopScope(
      onWillPop: () {
        widget.refreshHome;
        ;
        return _onBackPressed();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Post Flood"),
        ),
        body: ListView(
          children: [
            GestureDetector(
              onDoubleTap: () {
                setState(() {
                  if (!widget.post.hexedBy.contains(CurrentUser.user!.id)) {
                    widget.post.addLike();
                  }
                });
              },
              child: UnivhexPostWidget(
                post: widget.post,
                userid: CurrentUser.user!.id!,
              ),
            ),
            const Divider(
              height: 0,
              color: AppColors.obsidianInvert,
              thickness: 0.5,
            ),
            PostInteractionBar(post: widget.post),
            const Divider(
              height: 0,
              color: AppColors.obsidianInvert,
              thickness: 0.5,
            ),
            const Divider(
              height: 0.2,
              color: AppColors.myAqua,
              thickness: 1,
            ),
            CurrentUser.addVerticalSpace(1),
            widget.post.comments.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.post.comments.length,
                    itemBuilder: (context, index) {
                      return CommentWidget(
                          comment:
                              AppComment.fromJson(widget.post.comments[index]));
                    },
                  )
                : Container(),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                      child: CircleAvatar(
                        backgroundImage: _avatarImageProvider,
                      ),
                    ),
                    Flexible(
                      child: TextField(
                        autofocus: widget.autoFocus,
                        keyboardType: TextInputType.name,
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.myPurple,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(16)),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.myLightBlue, width: 1.0),
                          ),
                          hintText: "Leave a comment!",
                          suffixIcon: TextButton(
                            onPressed: () {
                              AppComment comment = AppComment(
                                userid: CurrentUser.user!.id!,
                                textContent: _controller.text,
                                dateTime: DateTime.now(),
                              );
                              setState(() {
                                widget.post.addComment(comment);
                                _controller.clear();
                              });
                            },
                            child: const Text("Share"),
                          ),
                        ),
                      ),
                    ),
                    CurrentUser.addHorizontalSpace(2.5)
                  ],
                ),
                CurrentUser.addVerticalSpace(2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _onBackPressed() {
  // Set your variable to false here
  CurrentUser.inPost = false;

  // Return true to allow the back button to pop the current screen
  return Future.value(true);
}
