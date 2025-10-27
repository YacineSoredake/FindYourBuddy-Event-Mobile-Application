import 'package:frontend/core/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(String userId) {
    socket = IO.io(
      ApiConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();
  }

  void joinBuddyChat(String buddyId) {
    socket.emit('joinBuddyChat', buddyId);
  }

  void sendMessage(String buddyId, String senderId, String text) {
    socket.emit('sendMessage', {
      'buddyId': buddyId,
      'senderId': senderId,
      'text': text,
    });
  }

  void onMessageReceived(Function(dynamic) callback) {
    socket.on('receiveMessage', (data) {
      print(' New message: $data');
      callback(data);
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
