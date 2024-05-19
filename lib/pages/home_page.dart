import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
    const LinuxInitializationSettings(
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
  int totalBorrows = 0;
  int totalOverdues = 0;
  List<Map<String, dynamic>> randomBooks = [];
  TextEditingController _textEditingController = TextEditingController();
  bool isSearchActive = false;

  @override
  void initState() {
    super.initState();
    fetchUserStats();
    fetchRandomBooks();
  }

  Future<void> fetchUserStats() async {
    try {
      final userBorrowedBooks = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.email)
          .collection('borrowed_books')
          .get();

      setState(() {
        totalBorrows = userBorrowedBooks.docs.length;
        totalOverdues = userBorrowedBooks.docs
            .where((doc) => (doc['deadlineDate'] as Timestamp)
                .toDate()
                .isBefore(DateTime.now()))
            .length;
      });
    } catch (error) {
      print('Error fetching user stats: $error');
    }
  }

  Future<void> fetchRandomBooks() async {
    try {
      final booksCollection =
          await FirebaseFirestore.instance.collection('books').get();
      final allBooks = booksCollection.docs
          .map((doc) => doc.data())
          .toList();

      // Filter out unique books by name
      Set<String> seenNames = {};
      List<Map<String, dynamic>> uniqueBooks = [];
      for (var book in allBooks) {
        if (!seenNames.contains(book['name'])) {
          seenNames.add(book['name']);
          uniqueBooks.add(book);
        }
        if (uniqueBooks.length == 7) break; // Only take 7 unique books
      }

      setState(() {
        randomBooks = uniqueBooks;
      });
    } catch (error) {
      print('Error fetching random books: $error');
    }
  }

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
      final DocumentSnapshot bookDoc = await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .get();

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

 Future<void> addBookToUser(
  String bookId, Map<String, dynamic> bookData) async {
  try {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final userDocRef = usersRef.doc(widget.email);

    // Check if the book is already borrowed
    if (bookData['isBorrowed'] == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book "${bookData['name']}" is already taken')),
      );
      return;
    }

    // Mark the book as borrowed and set the user who borrowed it
    await userDocRef.collection('borrowed_books').doc(bookId).set({
      'name': bookData['name'],
      'photoUrl': bookData['photoUrl'],
      'borrowedDate': Timestamp.now(),
      'deadlineDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 45))),
      'bookId': bookId,
    });
    await FirebaseFirestore.instance.collection('books').doc(bookId).update({
      'isBorrowed': 1,
      'taken_by': widget.email,
    });

    // Show notifications
    LocalNotification.showSimpleNotification(
      title: "Borrowed",
      body: 'You borrowed ${bookData['name']}',
      payload: 'You borrowed ${bookData['name']}'
    );

    // Show a scheduled notification after 5 seconds
    LocalNotification.showScheduleNotification1(
      title: "Borrowed",
      body: 'It\'s been 5 seconds since you borrowed ${bookData['name']}',
      payload: 'It\'s been 5 seconds since you borrowed ${bookData['name']}',
      remaning: 5
    );

    // Show a scheduled notification for due date
    LocalNotification.showScheduleNotification(
      title: "Borrowed",
      body: 'Due today for ${bookData['name']}',
      payload: 'Due today for ${bookData['name']}',
      remaning: 29
    );

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Book "${bookData['name']}" added to your borrowed list!'
        ),
      ),
    );
  } catch (error) {
    print('Error adding book to user: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to add book to your borrowed list.'),
      ),
    );
  }
}



  Future<void> addBookToWishlist(
      String bookId, Map<String, dynamic> bookData) async {
    try {
      final usersRef = FirebaseFirestore.instance.collection('users');
      final userDocRef = usersRef.doc(widget.email);

      await userDocRef.collection('wishlist').doc(bookId).set({
        'name': bookData['name'],
        'author': bookData['author'],
        'photoUrl': bookData['photoUrl'],
        'addedDate': Timestamp.now(),
        'bookId': bookId,
      });

      print('Book added to wishlist successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Book "${bookData['name']}" added to your wishlist!')),
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
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final dateString = dateFormat.format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('EZBorrow'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
            onPressed: scanCode,
          ),
        ],
      ),
      drawer: UserMenu(email: widget.email),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60.0),
                    topRight: Radius.circular(60.0),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Date and greeting
                    Text(
                      dateString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome Achiever!!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // New Arrivals Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'New Arrivals',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: randomBooks.length,
                        itemBuilder: (context, index) {
                          final book = randomBooks[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Container(
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    child: Image.network(
                                      book['photoUrl'],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      book['name'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      book['author'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // White container for the bottom half
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Best Ever Book Lists Section
                    const Text(
                      'Best Ever Book Lists',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: randomBooks.length,
                        itemBuilder: (context, index) {
                          final book = randomBooks[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Container(
                              width: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    child: Image.network(
                                      book['photoUrl'],
                                      width: 250,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      book['name'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      book['author'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdCategory({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}