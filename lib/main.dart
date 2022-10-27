import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
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
    Uri.parse('ws://192.168.1.65:8000/ws/music/oom/'),
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
                await player.setUrl('http://192.168.1.65:8000/api/send/');
                player.play();
              },
              child: Text('Play'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                final response = await http
                    .get(Uri.parse('http://192.168.1.65:8000/api/send/'));

                var responseData = json.decode(response.body);
                print(responseData);
              },
              child: const Text('Pause'),
            ),
            const SizedBox(height: 24),
            StreamBuilder(
              stream: _channel.stream,
              builder: (context, snapshot) {
                return Text(snapshot.hasData ? '${snapshot.data}' : 'error');
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
