import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '/providers/friend_list_provider.dart';
import '/screens/messages_screen.dart';
import '/screens/user_profile_screen.dart';
import 'search_user.dart';

class FriendsHome extends StatefulWidget {
  const FriendsHome({Key? key}) : super(key: key);

  @override
  State<FriendsHome> createState() => _FriendsHomeState();
}

class _FriendsHomeState extends State<FriendsHome> {
  late FriendsProvider friendsProvider;

  Future<void> _pullRefresh() async {
    await friendsProvider.getFriends();
    await friendsProvider.getFriendRequests();
  }

  @override
  void initState() {
    super.initState();
    friendsProvider = Provider.of<FriendsProvider>(context, listen: false);
    _pullRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 75.0,
          title: const Text('Friends'),
          actions: [
            IconButton(
              focusColor: Colors.black,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => const SearchUser(),
                  ),
                );
              },
              icon: const Icon(Iconsax.user_search),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: const Color.fromRGBO(245, 117, 106, 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  tabs: const [
                    Tab(text: 'Friends'),
                    Tab(text: 'Requests'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Consumer<FriendsProvider>(
          builder: (context, friendsListProvider, _) {
            return TabBarView(
              children: [
                RefreshIndicator(
                  onRefresh: _pullRefresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    primary: false,
                    shrinkWrap: true,
                    itemCount: friendsListProvider.friendUsers.length,
                    itemBuilder: (BuildContext context, int index) {
                      final friendUser = friendsListProvider.friendUsers[index];
                      if (friendsListProvider.friendUsers.isEmpty) {
                        return const Center(
                          child: Text('No friends yet'),
                        );
                      } else {
                        return ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => UserProfile(
                                  userUid: friendUser.user_uid as String,
                                ),
                              ),
                            );
                          },
                          leading: const CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://i.pinimg.com/originals/e0/41/fa/e041fa5038a055ff62d51fdbcc15dbc9.jpg',
                            ),
                            radius: 30.0,
                          ),
                          title: Text(
                            friendUser.username as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          subtitle: Text(
                            friendUser.about_me as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) => Messages(
                                    userUid: friendUser.user_uid as String,
                                    name: friendUser.name as String,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Iconsax.message_text,
                              color: Colors.grey[800],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  primary: false,
                  shrinkWrap: true,
                  itemCount: friendsListProvider.friendRequestUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final friendRequestUserIndividual =
                        friendsListProvider.friendRequestUsers[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://i.pinimg.com/originals/e0/41/fa/e041fa5038a055ff62d51fdbcc15dbc9.jpg',
                        ),
                        radius: 30.0,
                      ),
                      title: Text(
                        friendRequestUserIndividual.username as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      subtitle: const Text(
                        'Mumbai, India',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await friendsListProvider.friendRequestAction(
                                friendRequestUserIndividual.requestId as int,
                                'accept',
                              );
                              await _pullRefresh();
                            },
                            icon: const Icon(
                              Iconsax.check,
                              color: Colors.green,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await friendsListProvider.friendRequestAction(
                                friendRequestUserIndividual.requestId as int,
                                'decline',
                              );
                              await _pullRefresh();
                            },
                            icon: const Icon(
                              Iconsax.colors_square,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
