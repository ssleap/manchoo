import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentMouthfulChews = 0;
  int _totalChews = 0;
  bool _isSessionRunning = false;
  int _elapsedSeconds = 0;
  List<Map<String, dynamic>> _sessionHistory = [];
  List<Map<String, dynamic>> _mouthfuls = [];
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick);
  }

  void _onTick(Duration elapsed) {
    if (_isSessionRunning) {
      setState(() {
        _elapsedSeconds = elapsed.inSeconds;
      });
    }
  }

  void _startSession() {
    setState(() {
      _isSessionRunning = true;
      _currentMouthfulChews = 0;
      _totalChews = 0;
      _elapsedSeconds = 0;
      _mouthfuls.clear();
    });
    _ticker.start();
  }

  void _stopSession() {
    setState(() {
      _isSessionRunning = false;
      _sessionHistory.insert(0, {
        'date': DateTime.now(),
        'totalChews': _totalChews,
        'duration': _elapsedSeconds,
        'mouthfuls': List<Map<String, dynamic>>.from(_mouthfuls),
      });
    });
    _ticker.stop();
  }

  void _toggleSession() {
    if (_isSessionRunning) {
      _stopSession();
    } else {
      _startSession();
    }
  }

  void _newMouthful() {
    setState(() {
      _currentMouthfulChews = 0;
    });
  }

  void _mouthfulDone() {
    if (_currentMouthfulChews > 0) {
      setState(() {
        _totalChews += _currentMouthfulChews;
        _mouthfuls.insert(0, {
          'chews': _currentMouthfulChews,
          'time': DateTime.now(),
        });
        _currentMouthfulChews = 0;
      });
    }
  }

  void _incrementChew() {
    setState(() {
      _currentMouthfulChews++;
    });
  }

  String _formatDuration(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Chew Counter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 16),
            Text(
              'Session Time: ${_formatDuration(_elapsedSeconds)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      '$_currentMouthfulChews',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const Text('Current Mouthful'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$_totalChews',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const Text('Total Chews'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isSessionRunning ? _newMouthful : null,
                  child: const Text('New Mouthful'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSessionRunning && _currentMouthfulChews > 0 ? _mouthfulDone : null,
                  child: const Text('Mouthful Done'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _toggleSession,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Text(_isSessionRunning ? 'Stop Session' : 'Start Session'),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mouthfuls This Session',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _mouthfuls.isEmpty
                  ? const Center(child: Text('No mouthfuls yet.'))
                  : ListView.builder(
                      itemCount: _mouthfuls.length,
                      itemBuilder: (context, index) {
                        final mouthful = _mouthfuls[index];
                        return ListTile(
                          leading: const Icon(Icons.fastfood),
                          title: Text('Chews: ${mouthful['chews']}'),
                          subtitle: Text('Time: '
                              '${mouthful['time'].hour.toString().padLeft(2, '0')}:${mouthful['time'].minute.toString().padLeft(2, '0')}'),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Session History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: _sessionHistory.isEmpty
                  ? const Center(child: Text('No sessions yet.'))
                  : ListView.builder(
                      itemCount: _sessionHistory.length,
                      itemBuilder: (context, index) {
                        final session = _sessionHistory[index];
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text('Total Chews: ${session['totalChews']}'),
                          subtitle: Text('Duration: ${_formatDuration(session['duration'])}\nMouthfuls: ${session['mouthfuls'].length}'),
                          trailing: Text(
                            '${session['date'].hour.toString().padLeft(2, '0')}:${session['date'].minute.toString().padLeft(2, '0')}\n${session['date'].month}/${session['date'].day}',
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isSessionRunning
          ? FloatingActionButton(
              onPressed: _incrementChew,
              tooltip: 'Increment Chew',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
