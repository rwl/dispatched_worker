library dispatched_worker;

import 'dart:html';
import 'dart:async';
import 'dart:math' show Random;

class _WorkerStatus {
  bool status;
  final Worker worker;
  _WorkerStatus(this.status, this.worker);
}

/// A wrapper around the WebWorker API. Initialize it providing [url] of
/// the javascript worker code. Request work using [send] and wait for
/// the result using the returned [Future].
///
/// Based on: https://gist.github.com/normanrz/4136597
class DispatchedWorker {
  Map<int, _WorkerStatus> pool = {};
  List poolIds = [];
  final int poolSize;
  final int timeout;

//  final Worker _worker;
  final Random _random = new Random();

  DispatchedWorker(String scriptUrl, {this.poolSize: 1, this.timeout: 100}) {
    //      : _worker = new Worker(scriptUrl) {

    for (var i = 0; i < poolSize; i++) {
      poolIds.add(i);
      var myWorker = new Worker(scriptUrl);

//      (i) {
//        myWorker.addEventListener('message', (e) {
//          var data = e.data;
//          console.log("Worker #" + i + " finished. status: " + data.status);
//          pool[i].status = true;
//          poolIds.push(i);
//        });
//      }(i);

      pool[i] = new _WorkerStatus(true, myWorker);
    }
  }

  Future<Worker> _get() {
    if (poolIds.length > 0) {
      return new Future<Worker>(() => pool[poolIds.removeLast()]);
    } else {
      var completer = new Completer<Worker>();
      var timer = new Timer(new Duration(milliseconds: timeout), () {
        _get().then((id) {
          completer.complete(id);
        });
      });
      return completer.future;
    }
  }

  Future send(List payload) async {
    var completer = new Completer();

    Worker worker = await _get();

    var handle = _random.nextInt(65535);

    workerMessageCallback(MessageEvent event) {
      var packet = event.data;
      if (packet is List && packet.first == handle) {
        worker.removeEventListener("message", workerMessageCallback, false);
        if (packet.length > 1) {
          var result = packet[1];
          if (result is List) {
            completer.completeError(result.join(': '));
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

    worker.addEventListener('message', workerMessageCallback, false);
    worker.postMessage([handle, payload]);

    return completer.future;
  }
}
