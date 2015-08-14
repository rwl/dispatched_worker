library dispatched_worker;

import 'dart:html';
import 'dart:async';
import 'dart:math' show Random;

/// A wrapper around the WebWorker API. Initialize it providing [url] of
/// the javascript worker code. Request work using [send] and wait for
/// the result using the returned [Future].
///
/// Within the worker script:
///
///     incoming_message = [ handle, [ payload ] ]
///     outgoing_message = [ handle, output ]
///     outgoing_message = [ handle, [ "error", error ] ]
///
/// `handle` is a random [num] (assigned by the host) to match
/// request and response.
///
/// Based on: https://gist.github.com/normanrz/4136597
class DispatchedWorker {
  final Worker _worker;
  final Random _random = new Random();

  DispatchedWorker(String scriptUrl) : _worker = new Worker(scriptUrl);

  Future send(List payload) {
    var completer = new Completer();

    var handle = _random.nextInt(65535);

    workerMessageCallback(MessageEvent event) {
      var packet = event.data;
      if (packet is List && packet.first == handle) {
        _worker.removeEventListener("message", workerMessageCallback, false);
        if (packet.length > 1) {
          var result = packet[1];
          if (result is List && "error" == result.first) {
            completer.completeError(result.length > 1 ? result[1] : null);
          } else {
            completer.complete(result);
          }
        } else {
          completer.completeError("internal error: no result");
        }
      } else if (packet is String && packet.startsWith("internal error:")) {
        completer.completeError(packet);
      }
    }

    _worker.addEventListener('message', workerMessageCallback, false);
    _worker.postMessage([handle, payload]);

    return completer.future;
  }
}
