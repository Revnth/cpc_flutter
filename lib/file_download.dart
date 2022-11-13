import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';

class FileDownload extends StatelessWidget {
  FileDownload({Key? key}) : super(key: key);
  late String fileURL;

  void initState() async {
    await Permission.storage.request();
    fileURL = "http://10.0.2.2:8000/api/send/";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () async {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.storage,
          ].request();

          if (statuses[Permission.storage]!.isGranted) {
            var dir = await DownloadsPathProvider.downloadsDirectory;
            if (dir != null) {
              String savename = "oom.mp3";
              String savePath = "${dir.path}/$savename";
              print(savePath);

              try {
                await Dio().download(fileURL, savePath,
                    onReceiveProgress: (received, total) {
                  if (total != -1) {
                    print(
                        "${(received / total * 100).toStringAsFixed(0)}%");
                  }
                });
                print("File is saved to download folder.");
              } on DioError catch (e) {
                print(e.message);
              }
            }
          } else {
            print("No permission to read and write.");
          }
        },
        child: Text("Download"),
      )
    ],);

  }
}
