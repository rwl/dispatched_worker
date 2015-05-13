# DispatchedWorker

A wrapper for [Dart][] around the [WebWorker][] API.

## Usage

    import 'package:dispatched_worker/dispatched_worker.dart';
    
    main() {
      var worker = new DispatchedWorker('path/to/script.js');
      worker.send('hello').then((result) {
        print(result);
      }); 
    }
    
## Credits

Based on [dispatched_worker.coffee][orig] by [Norman Rzepka](https://github.com/normanrz).

[Dart]: https://www.dartlang.org/
[WebWorker]: https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:html.Worker
[orig]: https://gist.github.com/normanrz/4136597#file-dispatched_worker-coffee
