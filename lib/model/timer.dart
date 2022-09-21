import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum TimerStatus { running, paused, stopped }

class IntervalTimer {
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

}
