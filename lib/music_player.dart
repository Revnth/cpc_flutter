import 'package:flutter/material.dart';
// Just Audio package for Music Player
import 'package:just_audio/just_audio.dart';

// Function to get status of the player
Widget getStatus(player) {
  late String message = "No data";
  player.playerStateStream.listen((state) {
    if (state.playing) {
      message = 'Playing';
    } else {
      message = 'Paused';
    }
    switch (state.processingState) {
      case ProcessingState.loading:
        message = 'Loading';
        break;
      case ProcessingState.completed:
        message = 'Completed';
        break;
      case ProcessingState.idle:
        message = 'Idle';
        break;
      case ProcessingState.buffering:
        message = 'Buffering';
        break;
      case ProcessingState.ready:
        message = 'Ready';
        break;
    }
  });
  return Text(message);
}

// Function to add songs to the player
void addSong(player, songId) async {
  final url = 'http://10.0.2.2:8000/api/send/$songId';
  // Catching errors at load time
  try {
    await player.setUrl(url);
    player.play();
  } on PlayerException catch (e) {
    // Android: maps to ExoPlayerException.type
    print("Error code: ${e.code}");
    // Android: maps to ExoPlaybackException.getMessage()
    print("Error message: ${e.message}");
  } on PlayerInterruptedException catch (e) {
    // This call was interrupted since another audio source was loaded or the
    // player was stopped or disposed before this audio source could complete
    // loading.
    print("Connection aborted: ${e.message}");
  } catch (e) {
    // Fallback for all other errors
    print('An error occurred: $e');
  }
}

void addSongList(player, songList) {
  for (var songId in songList) {
    addSong(player, songId);
  }
  print("Playlist Song list added");
}