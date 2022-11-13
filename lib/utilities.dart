// Importing Queue Data Structure
import 'dart:collection';

// Class to store the data of the Web Socket
class ResponseData {
  // Add the required data from the response message of the Web Socket
  late bool isPlaying;
  // Connection status of the Web Socket
  late String? type;
  late String? connectionStatus;
  // Playlist data
  late Queue playlistQue;
  late String playlistName;
  // Song data
  late int? songId;
  late Queue songQue;
  late List songList;

  // Constructor that initializes the data
  ResponseData() {
    isPlaying = false;
    type = '';
    connectionStatus = '';
    songId = 0;

    playlistQue = Queue();
    playlistName = '';
    songQue = Queue();
    songList = [];
  }

  // Method that converts JSON to ResponseData
  ResponseData.fromJSON(Map<String, dynamic> json) {
    isPlaying = json['is_playing'].toString().toLowerCase() == 'true';
    type = json['type'];
    connectionStatus = json['connection_status'];
    songId = (json['song_id'] != null) ? int.parse(json['song_id']) : -1;
    playlistName = json['playlist_name'] ?? '';
    songQue = Queue();
    songList = json['song_list'] ?? [];
  }
}