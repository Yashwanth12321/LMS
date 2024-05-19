import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum BookIssueStatus { DUE, OVERDUE, RETURNED }

class BorrowHistory extends StatelessWidget {
  final String email;

  const BorrowHistory({required this.email, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrow History'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFF512F),
                Color(0xFFF09819),
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(email)
                    .collection('borrowed_books')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No borrow history found.'));
                  }

                  var borrowHistory = snapshot.data!.docs;
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    physics: BouncingScrollPhysics(),
                    itemCount: borrowHistory.length,
                    itemBuilder: (context, index) {
                      var history = borrowHistory[index].data() as Map<String, dynamic>;

                      // Convert the 'deadlineDate' field to a DateTime
                      Timestamp deadlineTimestamp = history['deadlineDate'] as Timestamp;
                      DateTime deadlineDateTime = deadlineTimestamp.toDate();

                      // Manually format the date string to display only date/month/year
                      String formattedDeadline = '${deadlineDateTime.day}/${deadlineDateTime.month}/${deadlineDateTime.year}';

                      // Determine the status of the book based on the deadline date
                      BookIssueStatus status;
                      if (DateTime.now().isAfter(deadlineDateTime)) {
                        status = BookIssueStatus.OVERDUE;
                      } else {
                        status = BookIssueStatus.DUE;
                      }

                      return BorrowListItem(
                        bookName: history['name'] ?? 'No name',
                        authorName: history['author'] ?? 'Unknown author',
                        issueDate: formattedDeadline,
                        date: formattedDeadline,
                        bookImageUrl: history['photoUrl'] ?? '', // Assuming photoUrl is optional
                        status: status,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BorrowListItem extends StatelessWidget {
  final String bookName;
  final String bookImageUrl;
  final String authorName;
  final String issueDate;
  final String date;
  final BookIssueStatus status;

  const BorrowListItem({
    Key? key,
    required this.bookName,
    required this.authorName,
    required this.issueDate,
    required this.date,
    required this.bookImageUrl,
    required this.status,
  }) : super(key: key);

  Color getIssueStatusColor() {
    switch (status) {
      case BookIssueStatus.DUE:
        return Colors.green!;
      case BookIssueStatus.OVERDUE:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getIssueStatusText() {
    switch (status) {
      case BookIssueStatus.DUE:
        return "BORROWING";
      case BookIssueStatus.OVERDUE:
        return "OVERDUE";
      default:
        return "RETURNED";
    }
  }

  IconData getIssueStatusIcon() {
    switch (status) {
      case BookIssueStatus.DUE:
        return Icons.timer;
      case BookIssueStatus.OVERDUE:
        return Icons.error_outline;
      default:
        return Icons.check;
    }
  }

  String getDate() {
    switch (status) {
      case BookIssueStatus.DUE:
        return "Due on: $date";
      case BookIssueStatus.OVERDUE:
        return "Was due on: $date";
      default:
        return "Returned on: $date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      height: 180,
      child: Stack(
        children: [
          //Borrow details card
          Positioned.fill(
            top: 35,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 3, 12),
                    child: Row(
                      children: [
                        SizedBox(width: 109),

                        //Borrow details
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              //Book Title
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  bookName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              SizedBox(height: 3),

                              //Author name
                              Text(
                                "By $authorName",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),

                              SizedBox(height: 10),

                              //Issue date
                              Text.rich(
                                TextSpan(
                                  text: 'Issued on: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: issueDate,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 3),

                              //If returned, then change to return date
                              Text.rich(
                                TextSpan(
                                  text: getDate().contains('Returned on') ? 'Returned on: ' : (getDate().contains('Due on') ? 'Due on: ' : 'Was due on: '),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: date,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  //Status
                  Container(
                    height: double.infinity,
                    width: 32,
                    decoration: BoxDecoration(
                      color: getIssueStatusColor(),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          getIssueStatusText(),
                          style:
 TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Book Image
          Positioned(
            left: 13,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: 155,
                width: 100,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.black,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.network(
                    bookImageUrl,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),

          //Borrow status
          Positioned(
            right: 20,
            top: 16,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(7),
                child: Icon(
                  getIssueStatusIcon(),
                  size: 22,
                  color: getIssueStatusColor(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}