import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String userEmail;
  final String volunteerEmail;

  const ChatScreen({
    super.key,
    required this.userEmail,
    required this.volunteerEmail,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String? volunteerEmail;
  late String chatId;
  bool isTyping = false;
  String? displayName;

  @override
  void initState() {
    super.initState();
    volunteerEmail = FirebaseAuth.instance.currentUser?.email;
    chatId = generateChatId(widget.userEmail, widget.volunteerEmail);
    _controller.addListener(() {
      setTypingStatus(_controller.text.isNotEmpty);
    });
    createChatMetadata();
    markMessagesAsRead();
    fetchDisplayName();
  }

  void fetchDisplayName() {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    setState(() {
      displayName = currentUserEmail == widget.userEmail
          ? widget.volunteerEmail
          : widget.userEmail;
    });
  }

  String generateChatId(String email1, String email2) {
    return (email1.compareTo(email2) < 0)
        ? '${email1}_$email2'
        : '${email2}_$email1';
  }

  Future<void> createChatMetadata() async {
    final chatDocRef =
        FirebaseFirestore.instance.collection('chat').doc(chatId);

    final chatDoc = await chatDocRef.get();
    if (!chatDoc.exists) {
      await chatDocRef.set({
        'userEmail': widget.userEmail,
        'volunteerEmail': widget.volunteerEmail,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      await chatDocRef.update({'lastUpdated': FieldValue.serverTimestamp()});
    }
  }

  void setTypingStatus(bool typing) {
    if (isTyping != typing) {
      isTyping = typing;
      FirebaseFirestore.instance
          .collection('chat')
          .doc(chatId)
          .update({'${volunteerEmail}_typing': typing});
    }
  }

  void sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(chatId)
        .collection('messages')
        .add({
      'sender': volunteerEmail,
      'text': message.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
    _controller.clear();
    setTypingStatus(false);
  }

  void markMessagesAsRead() async {
    final messages = await FirebaseFirestore.instance
        .collection('chat')
        .doc(chatId)
        .collection('messages')
        .where('sender', isEqualTo: widget.userEmail)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      doc.reference.update({'read': true});
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dt = timestamp.toDate();
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  void dispose() {
    setTypingStatus(false);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF833ab4), Color(0xFFe91e63)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          title: Text(
            displayName ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['sender'] == volunteerEmail;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.purple[200]
                              : Colors.redAccent[100], // Red for user
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(msg['text']),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (msg['timestamp'] != null)
                                  Text(
                                    formatTimestamp(msg['timestamp']),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black54),
                                  ),
                                if (isMe && msg['read'] == true)
                                  const Icon(Icons.done_all,
                                      size: 16, color: Colors.blue)
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Typing indicator
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chat')
                .doc(chatId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final data = snapshot.data!.data() as Map<String, dynamic>?;

              final typingKey = '${widget.userEmail}_typing';
              if (data != null && data[typingKey] == true) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${widget.userEmail} is typing...",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF833ab4)),
                  onPressed: () {
                    sendMessage(_controller.text);
                    markMessagesAsRead();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
