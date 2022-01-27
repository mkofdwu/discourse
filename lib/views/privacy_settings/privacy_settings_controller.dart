import 'package:discourse/models/db_objects/friend_list.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/story_db.dart';
import 'package:discourse/services/user_db.dart';
import 'package:discourse/views/privacy_settings/friend_list/friend_list_view.dart';
import 'package:discourse/views/user_selector/user_selector_view.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';

class PrivacySettingsController extends GetxController {
  final _relationships = Get.find<RelationshipsService>();
  final _userDb = Get.find<UserDbService>();
  final _storyDb = Get.find<StoryDbService>();
  final _auth = Get.find<AuthService>();

  Future<List<FriendList>> myFriendLists() => _storyDb.myFriendLists();

  FriendList? defaultFriendList(List<FriendList> myFriendLists) {
    final listId = _auth.currentUser.settings.showStoryTo;
    if (listId == null) return null;
    final defaultList = myFriendLists.where((list) => list.id == listId);
    return defaultList.length == 1 ? defaultList.single : null;
  }

  void changeDefaultFriendList(FriendList? newList) async {
    _auth.currentUser.settings.showStoryTo = newList?.id;
    await _userDb.setUserData(_auth.currentUser);
    // update(); <-- changes in ui are already reflected by radiogroup
  }

  void editFriendList(FriendList? friendList) async {
    // a bit confusing
    if (friendList == null) return;
    final result = await Get.to(FriendListView(
      title: 'Edit friend list',
      listName: friendList.name,
      friends: friendList.friends, // will be copied in view constructor
      actions: {
        FluentIcons.delete_20_regular: () async {
          final confirm = await Get.bottomSheet(YesNoBottomSheet(
            title: 'Delete list?',
            subtitle: 'Are you sure you want to delete this friend list?',
          ));
          if (confirm ?? false) {
            await _storyDb.deleteFriendList(friendList.id);
            Get.back(); // return to this page
            update();
          }
        },
      },
    ));
    if (result != null) {
      friendList.name = result['name'];
      friendList.friends = result['friends'];
      await _storyDb.updateFriendList(friendList);
      update();
    }
  }

  void toNewFriendList() async {
    final friends = await Future.wait((await _relationships.getFriends())
        .map((userId) => _userDb.getUser(userId)));
    Get.to(UserSelectorView(
      title: 'Select friends',
      canSelectMultiple: true,
      onlyUsers: friends,
      onSubmit: (selectedUsers) async {
        final result = await Get.to(FriendListView(
          title: 'New friend list',
          listName: '',
          friends: selectedUsers,
        ));
        if (result != null) {
          await _storyDb.newFriendList(result['name'], result['friends']);
          Get.back(); // return to this page
          update();
        }
      },
    ));
  }
}
