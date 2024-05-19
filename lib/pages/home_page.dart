import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/User_Pages/user_menu.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';  
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_local_notifications/src/platform_specifics/android/enums.dart';
import 'package:timezone/timezone.dart' as tz;


class HomePage extends StatefulWidget {
  final String email;

  const HomePage({required this.email, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class LocalNotification{
   static final _flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
        static final onClickNotification=BehaviorSubject<String>();

        


      static void onNotificationTap(
        NotificationResponse notificationResponse
      ){
        onClickNotification.add(notificationResponse.payload!);
      }
  static Future init() async{
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        onDidReceiveLocalNotification: (id,title,body,payload)=>null);
final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
        defaultActionName: 'Open notification');
final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux);
  _flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onDidReceiveNotificationResponse: onNotificationTap,
    onDidReceiveBackgroundNotificationResponse: onNotificationTap);


    _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    

  }
  static Future showSimpleNotification({
        required String title,
        required String body,
        required String payload,
      })async{
         const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.show(
    0, title, body, notificationDetails,
    payload: payload);

      }

      static Future showScheduleNotification({
    required String title,
    required String body,
    required String payload,
    required int remaning,
  }) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    
    
    var yourVariable=remaning;
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      title,
      body,
      
      tz.TZDateTime.now(tz.local).add(Duration(days: yourVariable)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel 2',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          

        ),
        
  
      
        
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

   static Future showScheduleNotification1({
    required String title,
    required String body,
    required String payload,
    required int remaning,
  }) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    
    
    var yourVariable=remaning;
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      
      tz.TZDateTime.now(tz.local).add(Duration(seconds: yourVariable)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel 3',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',

        ),
  
      
        
      ),
      
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  
}



class _HomePageState extends State<HomePage> {
  String _scanResult = "";

  Future<void> scanCode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to scan';
    }

    if (!mounted) return;

    setState(() {
      _scanResult = barcodeScanRes;
    });

    if (barcodeScanRes != '-1') {
      showConfirmationDialog(barcodeScanRes);
    }
  }

  Future<void> showConfirmationDialog(String bookId) async {
    try {
      final DocumentSnapshot bookDoc =
          await FirebaseFirestore.instance.collection('books').doc(bookId).get();

      if (bookDoc.exists) {
        final bookData = bookDoc.data() as Map<String, dynamic>;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Borrow'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Book Name: ${bookData['name']}'),
                  Text('Author: ${bookData['author']}'),
                  Text('Quantity: ${bookData['quantity']}'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    await addBookToUser(bookId, bookData);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Borrow'),
                ),
                TextButton(
                  onPressed: () async {
                    await addBookToWishlist(bookId, bookData);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add to Wishlist'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book not found!')),
        );
      }
    } catch (error) {
      print('Error fetching book details: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch book details.')),
      );
    }
  }

  Future<void> addBookToUser(String bookId, Map<String, dynamic> bookData) async {
    try {
      final usersRef = FirebaseFirestore.instance.collection('users');
      final userDocRef = usersRef.doc(widget.email);

      await userDocRef.collection('borrowed_books').doc(bookId).set({
        'name': bookData['name'],
        'photoUrl': bookData['photoUrl'],
        'borrowedDate': Timestamp.now(),
        'deadlineDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 45))),
      });

    final wishListCollection = userDocRef.collection('wishlist');
    final dummywish = wishListCollection.doc('dummywish');
    await dummywish.set({});
      // Update isBorrowed field to 1 in the books collection

      if (bookData['isBorrowed'] == 0) {
        await FirebaseFirestore.instance.collection('books').doc(bookId).update({
          'isBorrowed': 1,
          'taken_by': widget.email,
        });
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book "${bookData['name']}" is already taken')),
        );
        return;
      }
      
      LocalNotification.showSimpleNotification(title: "borrowed", body: 'you borrowed ${bookData['name']}', payload: 'you borrowed ${bookData['name']}');
      print('Book added to user successfully!');
      LocalNotification.showScheduleNotification1(title: "borrowed", body: 'its been 5 seconds you borrowed ${bookData['name']}', payload: 'its been 5 sec you borrowed ${bookData['name']}', remaning: 5);

    
      LocalNotification.showScheduleNotification(title: "borrowed", body: 'due today for ${bookData['name']}', payload: 'due today for ${bookData['name']}', remaning: 29);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book "${bookData['name']}" added to your borrowed list!')),
      );
    } catch (error) {
      print('Error adding book to user: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add book to your borrowed list.')),
      );
    }
  }

  Future<void> addBookToWishlist(String bookId, Map<String, dynamic> bookData) async {
  try {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final userDocRef = usersRef.doc(widget.email);

    await userDocRef.collection('wishlist').doc(bookId).set({
      'name': bookData['name'],
      'author': bookData['author'],
      'photoUrl': bookData['photoUrl'], // Adding photo URL to the wishlist
      'addedDate': Timestamp.now(),
    });

    print('Book added to wishlist successfully!');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book "${bookData['name']}" added to your wishlist!')),
    );
  } catch (error) {
    print('Error adding book to wishlist: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to add book to your wishlist.')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text('EzBorrow'),
        actions: [
          IconButton(
            onPressed: scanCode,
            icon: const Icon(Icons.qr_code_scanner, size: 24.0, color: Colors.black),
          ),
        ],
      ),
      drawer: UserMenu(email: widget.email),
      body: Center(
        child: Container(
          child: const Text(
            "Hello User",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
