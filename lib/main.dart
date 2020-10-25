import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import './model/board.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth=FirebaseAuth.instance;
final GoogleSignIn _googlesign=new GoogleSignIn();
void main() {
  runApp(new MyApp(

  ));
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "Comunity Board",
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new Home()


    );
  }
}

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<Board> boardmessages=List();
  Board board;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference databaseReference;//to handle the form state
  @override
  void initState() {

    super.initState();
    board = new Board("","");
    databaseReference = database.reference().child("community_board");
    databaseReference.onChildAdded.listen(_onEntryAdde);//function
    databaseReference.onChildChanged.listen(_onEntry);
  }
  @override
  Widget build(BuildContext context) {
       return new Scaffold(
         appBar: new AppBar(
           title: new Text("Comunity Board"),

         ),

         body: new Center(
           child: new Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [

               Flexible(
                 flex: 0,
                 child: Form(
                   key: formKey,
                   child: Flex(
                     direction: Axis.vertical,
                     children: [
                       ListTile(
                         leading: Icon(Icons.subject),
                         title: TextFormField(
                           initialValue: "",
                           onSaved: (val)=>board.subject=val,
                           validator: (val)=>val==""?val:null,
                         ),
                       ),


                       ListTile(
                         leading: Icon(Icons.message),
                         title: TextFormField(
                           initialValue: "",
                           onSaved:(val)=>board.body=val,
                           validator: (val)=>val==""?val:null,

                         ),
                       ),


                       FlatButton(
                         child: Text("Post"),
                         color: Colors.redAccent,
                         onPressed:(){
                           handleSubmit();
                         }
                       ),

                       FlatButton(
                         child: Text("Google sign"),
                         onPressed: ()=> _googleSignin(),
                         color: Colors.red,
                       ),

                       FlatButton(
                         child: Text("Signin with Email"),
                         onPressed:(){

                         }
                       ),

                       FlatButton(
                           child: Text("Create acocount"),
                           onPressed:(){

                           }
                       ),



                     ],
                   ),
                 ),
               ),

               Flexible(
                   child: FirebaseAnimatedList(
                     query:databaseReference,
                     itemBuilder: (_,DataSnapshot snapshot,Animation<double> animation,int index){
                       return new Card(
                         child: ListTile(
                           leading: CircleAvatar(
                             backgroundColor: Colors.green,
                           ),
                           title:Text(boardmessages[index].subject),
                           subtitle: Text(boardmessages[index].body),
                         ),
                       );
                     }
                   ),
               )

             ],
           ),
         ),
       );
  }

  void _onEntryAdde(Event event) {
    setState((){
      boardmessages.add(Board.fromSnapshot(event.snapshot));
            }
    );
  }


  void handleSubmit(){
    final FormState form=formKey.currentState;
    if(form.validate()){
      form.save();
      form.reset();
      databaseReference.push().set(board.toJson());
    }
  }


  void _onEntry(Event event) {

  var oldEntry = boardmessages.singleWhere((entry){
    return entry.key==event.snapshot.key;
  });

  setState((){
  boardmessages[boardmessages.indexOf(oldEntry)]=
  Board.fromSnapshot(event.snapshot);
  });


}

  Future<FirebaseUser>_googleSignin() async {
    GoogleSignInAccount googleSignInAccount=await _googlesign.signIn();
    GoogleSignInAuthentication googleSignInAuthentication=await googleSignInAccount.authentication;

   /* FirebaseUser user=await _auth.signInWithGoogle(
      idToken: googleSignInAuthentication.idToken,
      accessToken:googleSignInAuthentication.accessToken;
      print("user ${user.displayName}")

      return
    ); */
  }




}




