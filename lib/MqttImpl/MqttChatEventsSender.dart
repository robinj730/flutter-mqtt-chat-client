import 'package:flutter_mqtt/MqttImpl/topics_generator.dart';
import 'package:flutter_mqtt/abstraction/ChatEventsSender.dart';
import 'package:flutter_mqtt/abstraction/ClientHandler.dart';
import 'package:flutter_mqtt/abstraction/models/ChatMarkerMessage.dart';
import 'package:flutter_mqtt/abstraction/models/InvitationMessage.dart';
import 'package:flutter_mqtt/abstraction/models/PresenceMessage.dart';
import 'package:flutter_mqtt/abstraction/models/enums/ChatMarker.dart';
import 'package:flutter_mqtt/abstraction/models/enums/InvitationMessageType.dart';
import 'package:flutter_mqtt/abstraction/models/enums/MessageType.dart';
import 'package:flutter_mqtt/abstraction/models/TypingMessage.dart';
import 'package:flutter_mqtt/abstraction/models/enums/PresenceType.dart';
import 'package:uuid/uuid.dart';

class MqttChatEventsSender extends ChatEventsSender {
  final ClientHandler clientHandler;

  MqttChatEventsSender({required this.clientHandler});
  @override
  void sendChatMarker(String messageId, ChatMarker marker, String bareRoom) {
    String topic = TopicsNamesGenerator.getEventsTopicForBareRoom(bareRoom);

    ChatMarkerMessage msg = ChatMarkerMessage(
        id: Uuid().v4(),
        type: MessageType.ChatMarker,
        fromId: "",
        referenceId: messageId,
        status: marker);
    clientHandler.sendPayload(msg.toJson().toString(), topic);
  }

  @override
  void sendIsTyping(bool isTyping, String bareRoom) {
    TypingMessage message = TypingMessage(
        id: Uuid().v4(),
        type: MessageType.Typing,
        fromId: Uuid().v1(), //TODO: use user id, the broker will change this anyway
        fromName: Uuid().v1(),
        roomId: bareRoom,
        isTyping: isTyping);

    String topic = TopicsNamesGenerator.getEventsTopicForBareRoom(bareRoom);
    clientHandler.sendPayload(message.toJson().toString(), topic);
  }

  @override
  void respondToInvitation(String invitationId, String senderId, bool accept) {
    InvitationMessage invitationMessage = InvitationMessage(
        id: invitationId,
        type: accept ? MessageType.EventInvitationResponseAccept : MessageType.EventInvitationResponseReject,
        invitationMessageType: InvitationMessageType.REQUEST_RESPONSE,
        sendTime: DateTime.now().millisecondsSinceEpoch);

    clientHandler.sendPayload(invitationMessage.toJson().toString(), "personalevents/" + senderId);
  }

  @override
  void sendInvitation(String username, String? invitationId) {
    InvitationMessage message = InvitationMessage(
        id: invitationId ?? Uuid().v4(),
        type: MessageType.EventInvitationRequest,
        invitationMessageType: InvitationMessageType.REQUEST_RESPONSE,
        sendTime: DateTime.now().millisecondsSinceEpoch);

    String topic = "invitations/" + username;
    clientHandler.sendPayload(message.toJson().toString(), topic);
  }

  @override
  void sendPresence(PresenceType presenceType, String myId) {
    PresenceMessage presenceMessage = PresenceMessage(id: Uuid().v4(), type: MessageType.Presence, presenceType: presenceType, fromId: myId);
    String payload = presenceMessage.toJson().toString();
    clientHandler.sendPayload(payload, "presence/" + myId);
  }
}
