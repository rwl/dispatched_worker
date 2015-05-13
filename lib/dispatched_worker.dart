library dispatched_worker;

import 'dart:html';
import 'dart:async';
import 'dart:math' show Random;

/// A wrapper around the WebWorker API. Initialize it providing [url] of
/// the javascript worker code. Request work using [send] and wait for
/// the result using the returned [Future].
///
/// Based on: https://gist.github.com/normanrz/4136597
class DispatchedWorker {
  final Worker _worker;
  final Random _random = new Random();

  DispatchedWorker(String scriptUrl) : _worker = new Worker(scriptUrl);

  Future send(payload) {
    var completer = new Completer();

    var handle = _random.nextInt(65535);

    workerMessageCallback(MessageEvent event) {
      var packet = event.data;
      if (packet is Map && packet['workerHandle'] == handle) {
        _worker.removeEventListener("message", workerMessageCallback, false);
        if (packet.containsKey('error')) {
          completer.completeError(packet['error']);
        } else {
          completer.complete(packet['payload']);
        }
      }
    }

    _worker.addEventListener('message', workerMessageCallback, false);
    _worker.postMessage({ 'workerHandle': handle, 'payload': payload });

    return completer.future;
  }
}
