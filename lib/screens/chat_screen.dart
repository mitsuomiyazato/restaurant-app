import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  final TwilioFlutter twilioFlutter = TwilioFlutter(
    accountSid: 'AC65bcacdf8c73b30529fbd6cafd06e512',
    authToken: '4226665405f7513863e70d22c764ad18',
    twilioNumber: '+17752577838',
  );

  final List<String> messages = [];

  @override
  void initState() {
    super.initState();
  }

  void _sendMessage() async {
    String message = _controller.text; 
    if (message.isNotEmpty) {
      try {
        await twilioFlutter.sendSMS(
          toNumber: '+5519993184939', 
          messageBody: message, 
        );

        print("Mensagem enviada com sucesso!");

        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('messages').add({
            'message': message,
            'sender': user.uid, 
            'timestamp': FieldValue.serverTimestamp(), 
          });

          setState(() {
            messages.insert(0, message);
          });

          _controller.clear();
        } else {
          print("Usuário não autenticado");
        }
      } catch (e) {
        print("Erro ao enviar mensagem: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao enviar mensagem: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Row(
          children: [
            Icon(Icons.chat_bubble_outline),
            SizedBox(width: 8),
            Text('Chat'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
              .collection('messages')
              .where('sender', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .orderBy('timestamp', descending: true)
              .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Nenhuma mensagem encontrada.'));
                }

                final messages = snapshot.data!.docs.map((doc) {
                  return doc['message'] as String;
                }).toList();

                return ListView.builder(
                  reverse: true, 
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Usuário",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                message, 
                                style: const TextStyle(fontSize: 16),
                              ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage, 
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
