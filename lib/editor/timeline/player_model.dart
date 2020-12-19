import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:mooltik/editor/sound_clip.dart';
import 'package:mooltik/editor/timeline/timeline_model.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerModel extends ChangeNotifier {
  PlayerModel({
    Directory directory,
    TimelineModel timeline,
  })  : _directory = directory,
        _timeline = timeline,
        _player = FlutterSoundPlayer() {
    _player.openAudioSession().then((_) {
      _timeline.addListener(_timelineListener);
    });
  }

  // TODO: Move file ownership to Project, since it is responsible for project folder IO.
  final Directory _directory;

  final TimelineModel _timeline;

  FlutterSoundRecorder _recorder;
  FlutterSoundPlayer _player;

  bool get isRecording => _recorder?.isRecording ?? false;

  bool get isPlaying => _player?.isPlaying ?? false;
  bool _isPlayerBusy = false;

  SoundClip get soundBite => _soundBite;
  SoundClip _soundBite;

  Future<void> _initRecorder() async {
    final permit = await Permission.microphone.request();
    if (permit != PermissionStatus.granted) return;
    _recorder = FlutterSoundRecorder();
    await _recorder.openAudioSession();
  }

  void _timelineListener() {
    if (isRecording) {
      _recorderListener();
    } else {
      _playerListener();
    }
  }

  void _recorderListener() {
    _updateSoundBiteDuration();
    if (!_timeline.isPlaying) stopRecording();
  }

  void _playerListener() async {
    if (_soundBite == null) return;

    final shouldPlay = _timeline.isPlaying &&
        _timeline.playheadPosition >= _soundBite.startTime &&
        _timeline.playheadPosition <= _soundBite.endTime;

    if (shouldPlay && !isPlaying && !_isPlayerBusy) {
      _isPlayerBusy = true;

      // TODO: This is expensive (~80ms), prime the sound beforehand
      await _player.startPlayer(
        fromURI: _soundBite.file.path,
        codec: Codec.aacADTS,
      );

      await _player.seekToPlayer(
        _timeline.playheadPosition - _soundBite.startTime,
      );

      _isPlayerBusy = false;
    } else if (!shouldPlay && isPlaying && !_isPlayerBusy) {
      _isPlayerBusy = true;
      await _player.stopPlayer();
      _isPlayerBusy = false;
    }
  }

  void _updateSoundBiteDuration() {
    _soundBite = _soundBite.copyWith(
      duration: _timeline.playheadPosition - _soundBite.startTime,
    );
    notifyListeners();
  }

  Future<void> startRecording() async {
    if (_recorder == null) {
      await _initRecorder();
      if (_recorder == null) return;
    }
    _soundBite = SoundClip(
      file: File('${_directory.path}/recording.aac'),
      startTime: _timeline.playheadPosition,
      duration: Duration.zero,
    );
    await _recorder.startRecorder(
      toFile: _soundBite.file.path,
      codec: Codec.aacADTS,
      audioSource: AudioSource.voice_communication,
    );
    _timeline.play();
    notifyListeners();
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    _timeline.pause();
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _recorder?.closeAudioSession();
    await _player?.closeAudioSession();
  }
}
