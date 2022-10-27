import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class ResponseData {
  final bool message;
  final String? type;
  final String? connectionStatus;

  ResponseData(this.message, this.type, this.connectionStatus);

  ResponseData.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        type = json['type'],
        connectionStatus = json['connectionStatus'];

  Map<String, dynamic> toJson() => {
        'message': message,
        'type': type,
        'connectionStatus': connectionStatus,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'End device';
    return const MaterialApp(
      title: title,
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://10.0.2.2:8000/ws/music/zero/'),
  );

  late AudioPlayer player;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                await player.setUrl('http://10.0.2.2:8000/api/send/');
                player.pause();
              },
              child: const Text('Ready audio files'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                final response =
                    await http.get(Uri.parse('http://10.0.2.2:8000/api/send/'));

                var responseData = json.decode(response.body);
                print(responseData);
                player.stop();
              },
              child: const Text('Pause'),
            ),
            const SizedBox(height: 24),
            StreamBuilder(
              stream: _channel.stream,
              builder: (context, snapshot) {
                print(snapshot.data);// TODO: Debug code
                var response = jsonDecode(snapshot.data);
                var data = ResponseData.fromJson(response);
                if (data.message) {
                  player.play();
                } else {
                  player.pause();
                }
                return Text(data.message ? 'Playing' : 'Paused');
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }
}
