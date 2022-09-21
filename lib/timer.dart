import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

enum TimerStatus { running, paused, stopped }

class _TimerWidgetState extends State<TimerWidget> {
  FlutterTts flutterTts = FlutterTts();

  Timer? _timer;
  int _countdown = 10;
  int _count = 0;
  int _interval = 5;
  int _maxclicks = 0;

  bool _enableVoice = true;
  bool _enableBeep = true;

  TimerStatus _status = TimerStatus.stopped;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  void loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _interval = prefs.getInt("interval") ?? _interval;
      _maxclicks = prefs.getInt("maxclicks") ?? _maxclicks;
      _enableBeep = prefs.getBool("enablebeep") ?? _enableBeep;
      _enableVoice = prefs.getBool("enablevoice") ?? _enableVoice;
    });
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("enablebeep", _enableBeep);
    prefs.setBool("enablevoice", _enableVoice);
    prefs.setInt("maxclicks", _maxclicks);
    prefs.setInt("interval", _interval);
  }

  void setEnableVoice(bool val) {
    setState(() {
      _enableVoice = val;
    });
  }

  void setEnableBeep(bool val) {
    setState(() {
      _enableBeep = val;
    });
  }

  void maxIncrease(int amount) {
    setState(() {
      _maxclicks += amount;
    });
  }

  void maxDecrease(int amount) {
    if (_maxclicks > amount) {
      setState(() {
        _maxclicks -= amount;
      });
    } else {
      setState(() {
        _maxclicks = 0;
      });
    }
  }

  void intervalIncrease() {
    setState(() {
      _interval += 1;
    });
  }

  void intervalDecrease() {
    if (_interval > 1) {
      setState(() {
        _interval -= 1;
      });
    }
  }

  void handleInterval() {
    setState(() {
      _count += 1;
    });
    if (_count < _maxclicks || _maxclicks == 0) {
      timerSetup();
    }

    //Now beep and say the count
    //var result = await flutterTts.speak("Hello World");
    if (_enableBeep) {
      FlutterBeep.beep();
    }
    if (_enableVoice) {
      flutterTts.speak(_count.toString());
    }
  }

  void timerStart() async {
    _count = 0;
    await savePreferences();
    timerSetup();
  }

  void timerSetup() {
    setState(() {
      _status = TimerStatus.running;
    });

    _countdown = _interval;
    const oneSec = Duration(seconds: 1);

    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_countdown == 1) {
          setState(() {
            timer.cancel();
            _status = TimerStatus.stopped;
          });
          handleInterval();
        } else {
          setState(() {
            _countdown--;
          });
        }
      },
    );
  }

  void timerStop() {
    setState(() {
      if (_timer != null) {
        _timer!.cancel();
      }
      _status = TimerStatus.stopped;
    });
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }

    flutterTts.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          "This app has been designed to tick at a certain interval.  This is not an exact science, but has been designed for manually taking timewarp photos, whilst maintaining control (incase you are not quite positioned in time)",
          style: Theme.of(context).textTheme.bodySmall,
        ),

        buildStopped(context),
        buildRunning(context),
        //Text("Status$_status"),
      ],
    );
  }

  Widget buildStopped(BuildContext context) {
    if (_status == TimerStatus.running) return Container();

    return Column(
      children: <Widget>[
        CheckboxListTile(
          title: const Text('Enable Beep'),
          value: _enableBeep,
          onChanged: (bool? value) {
            setEnableBeep(value ?? true);
          },
        ),
        CheckboxListTile(
          title: const Text('Enable Voice'),
          value: _enableVoice,
          onChanged: (bool? value) {
            setEnableVoice(value ?? true);
          },
        ),
        ListTile(
          title: const Text('Tick every x seconds'),
          trailing: Text("$_interval"),
          subtitle: Row(
            children: [
             
              ElevatedButton(
                onPressed: () {
                  intervalDecrease();
                },
                child: const Text("-"),
              ),
            //  Text("$_interval"),
              ElevatedButton(
                onPressed: () {
                  intervalIncrease();
                },
                child: const Text("+"),
              ),
            ],
          ),
        ),

         ListTile(
          title: const Text('Max no of Ticks:'),
          trailing: Text("$_maxclicks"),
          subtitle:  Row(
          children: [
            
            ElevatedButton(
              onPressed: () {
                maxDecrease(10);
              },
              child: const Text("--"),
            ),
            ElevatedButton(
              onPressed: () {
                maxDecrease(1);
              },
              child: const Text("-"),
            ),
            ElevatedButton(
              onPressed: () {
                maxIncrease(1);
              },
              child: const Text("+"),
            ),
            ElevatedButton(
              onPressed: () {
                maxIncrease(10);
              },
              child: const Text("++"),
            ),
          ],
        ),
        ),


        // Row(
        //   children: [
        //     const Text('Max no of Ticks: '),
        //     ElevatedButton(
        //       onPressed: () {
        //         maxDecrease(10);
        //       },
        //       child: const Text("--"),
        //     ),
        //     ElevatedButton(
        //       onPressed: () {
        //         maxDecrease(1);
        //       },
        //       child: const Text("-"),
        //     ),
        //     Text("$_maxclicks"),
        //     ElevatedButton(
        //       onPressed: () {
        //         maxIncrease(1);
        //       },
        //       child: const Text("+"),
        //     ),
        //     ElevatedButton(
        //       onPressed: () {
        //         maxIncrease(10);
        //       },
        //       child: const Text("++"),
        //     ),
        //   ],
        // ),
        _status != TimerStatus.running
            ? ElevatedButton(
                onPressed: () {
                  timerStart();
                },
                child: const Text("Start"),
              )
            : Container(),
      ],
    );
  }

  Widget buildRunning(BuildContext context) {
    if (_status != TimerStatus.running) return Container();

    //style: Theme.of(context).textTheme.headline6,
    return Column(
      children: [
        const Text("Number of Clicks:"),
        Text(
          "$_count",
          style: Theme.of(context).textTheme.headline6,
        ),
        const Text("Seconds to Next Click:"),
        Text(
          "$_countdown",
          style: Theme.of(context).textTheme.headline6,
        ),
        ElevatedButton(
          onPressed: () {
            timerStop();
          },
          child: const Text("Stop"),
        ),
      ],
    );
  }
}
