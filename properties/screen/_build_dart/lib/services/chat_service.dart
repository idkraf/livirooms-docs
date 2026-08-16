import '../models/chat.dart';
import '../models/paginated.dart';
import 'api_client.dart';

class ChatService {
  ChatService({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  Future<List<Conversation>> conversations() async {
    final res = await _api.get('conversations');
    return res.dataObjects.map(Conversation.fromJson).toList();
  }

  Future<Conversation> start({required int recipientId, int? propertyId}) async {
    final res = await _api.post('conversations', body: {
      'recipient_id': recipientId,
      if (propertyId != null) 'property_id': propertyId,
    });
    return Conversation.fromJson(res.dataMap);
  }

  Future<Paginated<Message>> messages(int conversationId, {int page = 1}) async {
    final res = await _api.get(
      'conversations/$conversationId/messages',
      query: {'page': page},
    );
    return Paginated.fromResponse(res, Message.fromJson);
  }

  Future<Message> send(
    int conversationId,
    String body, {
    String? attachment,
    double? locationLat,
    double? locationLng,
  }) async {
    final res = await _api.post('conversations/$conversationId/messages', body: {
      if (body.isNotEmpty) 'body': body,
      if (attachment != null) 'attachment': attachment,
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
    });
    return Message.fromJson(res.dataMap);
  }
}
