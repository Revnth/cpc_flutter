import 'package:flutter/material.dart';

// Import dart Queue Data Structures
import 'dart:collection';

// Import dart JSON converter
import 'dart:convert';

// Just Audio package for Music Player
import 'package:just_audio/just_audio.dart';

// Web socket package for flutter
import 'package:web_socket_channel/web_socket_channel.dart';

// Class that contains method to convert the Web socket data to the required format
import './utilities.dart';
import 'music_player.dart';

// Stateful widget for Home page which renders of Data from the Web Socket
class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

// State class for Home page
class _HomeState extends State<Home> {
  final TextEditingController _controller = TextEditingController();
  final _channel = WebSocketChannel.connect(
    // Connects to a Web Socket server with the level 10 in the hierarchy structure
    Uri.parse('ws://10.0.2.2:8000/socket/music/lvl0/'),
  );

  // Create music player variable
  late AudioPlayer player;

  // Create file URL variable
  late String fileURL;

  // Song Queue
  late Queue songQue;

  @override
  void initState() {
    super.initState();
    // Initialize the audio player instance and file URL
    player = AudioPlayer();
    fileURL = "http://10.0.2.2:8000/api/send/";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
              stream: _channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var response = jsonDecode(snapshot.data);
                  print("Response is $response");
                  var data = ResponseData.fromJSON(response);

                  if (data.isPlaying) {
                    player.play();
                  } else {
                    player.pause();
                  }

                  if (data.playlistName.isNotEmpty) {
                    addSongList(player, data.songList);
                  }

                  if (data.songId! > 0) {
                    print('Setting up the song');
                    addSong(player, data.songId);
                  }
                  if (data.playlistName.isNotEmpty &&
                      data.songList.isNotEmpty) {
                    print('Setting up the playlist');
                    player.setAudioSource(
                      ConcatenatingAudioSource(
                        children: data.songList.map((songId) {
                          return AudioSource.uri(
                              Uri.parse(fileURL + songId.toString()));
                        }).toList(),
                      ),
                      initialIndex: 0,
                    );
                    player.play();
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      data.connectionStatus ==
                              'Connection established successfully'
                          ? const Text('Connected to the server')
                          : const Text('Not connected to the server'),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(data.songId != -1
                          ? 'Song ID is ${data.songId}'
                          : 'No song received'),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(data.isPlaying ? 'Playing' : 'Paused'),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(data.playlistName),
                      const SizedBox(
                        height: 20,
                      ),
                      for (var song in data.songList) Text('Song ID is $song'),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (player.playing) {
                                player.pause();
                                _channel.sink.add(jsonEncode({
                                  'is_playing': false,
                                }));
                              } else {
                                player.play();
                                _channel.sink.add(jsonEncode({
                                  'is_playing': true,
                                }));
                              }
                            },
                            child: Text(player.playing ? 'Play' : 'Pause'),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              player.seekToNext();
                            },
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const Text("Error occurred");
                }
              },
            ),
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
