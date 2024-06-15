// ignore_for_file: curly_braces_in_flow_control_structures

// State provider imports
import 'package:flutter/material.dart';

import 'sender_profile.dart';
import 'auth_handler.dart';
import 'status_handler.dart';

// Gmail handler imports
import 'package:googleapis/gmail/v1.dart';
import 'gmail_handler.dart';


class StateProvider extends ChangeNotifier {

  late final GmailApi _gmailApi;
  String _status = '';
  List<Column> _loadingWidgets = [];
  List<SenderProfile> _senderProfiles = [];
  bool _collectAll = false;
  List<String> _flaggedLinks = [];
  bool _collectionStarted = false;
  int _messagesToCollect = 100;

  String get status => _status;
  List<Column> get loadingWidgets => _loadingWidgets;
  List<SenderProfile> get senderProfiles => _senderProfiles;
  bool get collectAll => _collectAll;
  List<String> get flaggedLinks => _flaggedLinks;
  int get messagesToCollect => _messagesToCollect;

  void setStatus(String value) {
    _status = value;
    notifyListeners();
  }
  void setLoadingWidgets(List<Column> value) {
    _loadingWidgets = value;
    notifyListeners();
  }
  void setCollectAll(bool value) {
    _collectAll = value;
    notifyListeners();
  }
  void setMessagseToCollect(int value) {
    _messagesToCollect = value;
    notifyListeners();
  }
  void setFlagged(SenderProfile profile, bool value) {
    profile.setFlagged(value);
    notifyListeners();
  }
  void setTrash(SenderProfile profile, bool value) {
    profile.setTrash(value);
    notifyListeners();
  }
  void setPermaDelete(SenderProfile profile, bool value) {
    profile.setPermaDelete(value);
    notifyListeners();
  }

  void signInWithGoogle(BuildContext context) async {
    _gmailApi = await AuthHandler.initGmailApi();
    _senderProfiles = await collectEmails(context);
  }

  void initFlagHandler(BuildContext context) {
    for (SenderProfile profile in _senderProfiles) {
      if (profile.flagged) 
          _flaggedLinks.addAll(profile.unsubLinks);

      if (profile.permaDelete) 
          GmailHandler.permaDeleteMessages(_gmailApi, profile.messages);
      else if (profile.trash) 
          for (Message message in profile.messages) GmailHandler.trashMessage(_gmailApi, message.id!);
    }
  }

  Future<List<SenderProfile>> collectEmails(BuildContext context) async {
    if (_collectionStarted) return [];
    _collectionStarted = true;

    List<Message> messages = [];
    
    if (_collectAll) {
      Profile profile = await _gmailApi.users.getProfile('me');
      _messagesToCollect = profile.messagesTotal!;
    }

    int messagesPerCall = _messagesToCollect < 500
        ? _messagesToCollect
        : 500;

    final Stopwatch collectionStopwatch = Stopwatch();
    collectionStopwatch.start();

    String? pageToken;
    int count = 0;
    while (true) {
      List<Message> messages = await GmailHandler.listMessages(_gmailApi, messagesPerCall, pageToken);
      for (Message message in messages) {
        messages.add(await GmailHandler.getMessage(_gmailApi, message.id!));
        count++;
        if (count > _messagesToCollect) break;
        StatusHandler.collectionStatusBuilder(count, _messagesToCollect, collectionStopwatch.elapsedMilliseconds);
      }
      if (count >= _messagesToCollect) break;
    }

    return GmailHandler.processMessages(messages);
  }

}