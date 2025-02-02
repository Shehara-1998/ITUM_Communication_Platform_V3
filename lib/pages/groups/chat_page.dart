import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itum_communication_platform/notifications/inbox_notifications.dart';
import 'package:itum_communication_platform/pages/polls/polls_home_page.dart';
import 'package:itum_communication_platform/pages/polls/polls_view.dart';
import 'package:itum_communication_platform/pages/reminders/reminders_home_page.dart';
import 'package:itum_communication_platform/service/database_service.dart';
import 'package:itum_communication_platform/widgets/message_tile.dart';
import 'package:itum_communication_platform/widgets/widegets.dart';

import 'group_info.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage({Key? key,
    required this.groupName,
    required this.groupId,
    required this.userName})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";

  @override
  void initState() {
    getChatAdmin();
    super.initState();
  }

  getChatAdmin(){
    DatabaseService().getChats(widget.groupId).then((val){
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val){
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(widget.groupName, style: const TextStyle(color: Colors.black),),
        backgroundColor: const Color(0xffE5F9FF),
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xff649EFF))),
        actions: [
          IconButton(
              onPressed: (){
                nextScreen(context, PollsViewPage());
              },
              icon: Icon(Icons.poll, color: Color(0xff649EFF),)),
          IconButton(
              onPressed: (){
                nextScreen(context, InboxNotifications());
              },
              icon: Icon(Icons.notifications, color: Color(0xff649EFF),)),
          Builder(
            builder: (context) => IconButton(
                onPressed: (){
                  Scaffold.of(context).openEndDrawer();
                },
                icon: const Icon(Icons.more_vert, color: Color(0xff649EFF),)),
          ),
        ],
      ),
        endDrawer: Drawer(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            children: <Widget>[
              ListTile(
                onTap: (){
                  nextScreen(context, GroupInfo(
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                    adminName: admin,
                  ));
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.info, color: Color(0xff649EFF),),
                title: const Text('Group Info', style: TextStyle(color: Colors.black),),
              ),
              ListTile(
                onTap: (){
                  nextScreen(context, PollsHome(
                  ));
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.poll, color: Color(0xff649EFF),),
                title: const Text('Create Polls', style: TextStyle(color: Colors.black),),
              ),
              ListTile(
                onTap: (){
                  nextScreen(context, RemindersHome(
                  ));
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.notifications, color: Color(0xff649EFF),),
                title: const Text('Create Reminders', style: TextStyle(color: Colors.black),),
              ),
            ],
          ),
        ),
      body: Stack(
        children: <Widget>[
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.grey[700],
              ),
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Expanded(
                      child: TextFormField(
                        controller: messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Send a message...",
                          hintStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                        ),
                      )),
                  const SizedBox(width: 12,),
                  GestureDetector(
                    onTap: (){
                      sendMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xff649EFF),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(Icons.send, color: Colors.white,),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )
    );
  }
  chatMessages(){
    return StreamBuilder(
      stream: chats,
        builder: (context,AsyncSnapshot snapshot){
        return snapshot.hasData ?
        ListView.builder(
          itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index){
            return MessageTile(
                message: snapshot.data.docs[index]['message'],
                sender: snapshot.data.docs[index]['sender'],
                sentByMe: widget.userName == snapshot.data.docs[index]['sender']);
            })
            : Container();
        });
  }

  sendMessage(){
    if(messageController.text.isNotEmpty){
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }


}
