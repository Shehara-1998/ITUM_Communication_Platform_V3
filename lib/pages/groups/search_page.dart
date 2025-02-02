import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itum_communication_platform/helper/helper_function.dart';
import 'package:itum_communication_platform/pages/groups/chat_page.dart';
import 'package:itum_communication_platform/service/database_service.dart';
import 'package:itum_communication_platform/widgets/widegets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  bool isJoined = false;
  User? user;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdAndName();
  }

  getCurrentUserIdAndName()async{
    await HelperFunctions.getUserNameFromSF().then((value){
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r){
    return r.substring(r.indexOf("_")+ 1);
  }

  String getId(String res){
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: const Color(0xffE5F9FF),
        iconTheme: const IconThemeData(color:Color(0xff649EFF)),
        title: const Text("Search",
          style: TextStyle(color: Colors.black, fontSize: 27, fontWeight: FontWeight.bold),),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xffE5F9FF),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search groups..."
                      ),
                    )),
                GestureDetector(
                  onTap: (){
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(Icons.search, color: Colors.black54,),
                  ),
                ),
              ],
            ),
          ),
          isLoading ? const Center(child: CircularProgressIndicator(),) : groupList(),
        ],
      ),
    );
  }
  initiateSearchMethod() async{
    if(searchController.text.isNotEmpty){
      setState(() {
        isLoading = true;
      });
      await DatabaseService()
        .searchByName(searchController.text).then((snapshot){
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;
          hasUserSearched = true;
        });
      });

    }
  }
  groupList(){
    return hasUserSearched
        ? ListView.builder(
      shrinkWrap: true,
        itemCount: searchSnapshot!.docs.length,
        itemBuilder: (context, index){
          return groupTile(
            userName,
            searchSnapshot!.docs[index]['groupId'],
            searchSnapshot!.docs[index]['groupName'],
            searchSnapshot!.docs[index]['admin'],
          );
        },
        ) :Container();
  }

  joinedOrNot(String userName, String groupId, String groupName, String admin)async{
    await DatabaseService(uid: user!.uid).isUserJoined(groupName, groupId, userName).then((value){
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(String userName, String groupId, String groupName,String admin){
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Color(0xffE5F9FF),
        child: Text(groupName.substring(0,1).toUpperCase(),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
      ),
      title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600),),
      subtitle: Text("Admin :${getName(admin)}"),
      trailing: InkWell(
        onTap: ()async{
          await DatabaseService(uid: user!.uid)
          .toggleGroupJoin(groupId, userName, groupName);
          if(isJoined){
            setState(() {
              isJoined = !isJoined;
            });
            showSnackBar(context, Colors.greenAccent, "Successfuly joined the group");
            Future.delayed(const Duration(seconds: 2),(){
              nextScreen(context, ChatPage(
                  groupName: groupName,
                  groupId: groupId,
                  userName: userName));
            });
          }
          else{
            setState(() {
              isJoined = !isJoined;
              showSnackBar(context, Colors.red, "Left the group $groupName");
            });
          }
        },
        child: isJoined
        ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.white,width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: const Text("Joined",
            style: TextStyle(color: Colors.white),
          ),
        )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white,width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                child: const Text("Join now",
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ),
    );
  }
}
