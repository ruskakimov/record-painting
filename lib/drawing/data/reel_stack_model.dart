import 'package:flutter/material.dart';
import 'package:mooltik/common/data/project/layer_group/frame_reel_group.dart';
import 'package:mooltik/common/data/project/layer_group/layer_group_info.dart';
import 'package:mooltik/common/data/project/layer_group/sync_layers.dart';
import 'package:mooltik/common/data/project/project.dart';
import 'package:mooltik/common/data/project/scene.dart';
import 'package:mooltik/common/data/project/scene_layer.dart';
import 'package:mooltik/drawing/data/frame_reel_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages a stack of frame reels.
class ReelStackModel extends ChangeNotifier {
  ReelStackModel({
    required Scene scene,
    required SharedPreferences sharedPreferences,
    required CreateNewFrame createNewFrame,
  })  : _scene = scene,
        _sharedPreferences = sharedPreferences,
        _createNewFrame = createNewFrame,
        _showFrameReel = sharedPreferences.getBool(_showFrameReelKey) ?? true,
        reels = scene.layers
            .map((layer) => FrameReelModel(
                  frameSeq: layer.frameSeq,
                  createNewFrame: createNewFrame,
                ))
            .toList();

  final Scene _scene;
  SharedPreferences _sharedPreferences;
  final CreateNewFrame _createNewFrame;

  final List<FrameReelModel> reels;

  Iterable<FrameReelModel> get visibleReels => reels
      .where((reel) => isVisible(reels.indexOf(reel)) || reel == activeReel);

  bool isActive(int layerIndex) => _activeReelIndex == layerIndex;

  FrameReelModel get activeReel => isGrouped(_activeReelIndex)
      ? FrameReelGroup(
          activeReel: reels[_activeReelIndex],
          group: reelGroupOf(_activeReelIndex),
        )
      : reels[_activeReelIndex];

  int _activeReelIndex = 0;

  void changeActiveReel(FrameReelModel reel) {
    final index = reels.indexOf(reel);
    if (index != -1) {
      _activeReelIndex = index;
      notifyListeners();
    }
  }

  /// Whether frame reel UI is visible.
  bool get showFrameReel => _showFrameReel;
  bool _showFrameReel;

  Future<void> toggleFrameReelVisibility() async {
    _showFrameReel = !_showFrameReel;
    notifyListeners();
    await _sharedPreferences.setBool(_showFrameReelKey, _showFrameReel);
  }

  void addLayerAboveActive(SceneLayer layer) {
    _scene.layers.insert(_activeReelIndex, layer);
    reels.insert(
        _activeReelIndex,
        FrameReelModel(
          frameSeq: layer.frameSeq,
          createNewFrame: _createNewFrame,
        ));
    notifyListeners();
  }

  bool get canDeleteLayer => reels.length > 1;

  void deleteLayer(int layerIndex) {
    if (!canDeleteLayer) return;
    if (layerIndex < 0 || layerIndex >= reels.length) return;

    final activeReelBefore = activeReel;

    reels.removeAt(layerIndex);
    final removedLayer = _scene.layers.removeAt(layerIndex);

    Future.delayed(
      Duration(seconds: 1),
      () => removedLayer.dispose(),
    );

    if (layerIndex == _activeReelIndex) {
      _activeReelIndex = _activeReelIndex.clamp(0, reels.length - 1);
    } else {
      _activeReelIndex = reels.indexOf(activeReelBefore);
    }
    notifyListeners();
  }

  void onLayerReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final activeReelBefore = activeReel;

    final reel = reels.removeAt(oldIndex);
    reels.insert(newIndex, reel);

    final layer = _scene.layers.removeAt(oldIndex);
    _scene.layers.insert(newIndex, layer);

    _activeReelIndex = reels.indexOf(activeReelBefore);

    notifyListeners();
  }

  bool isVisible(int layerIndex) => _scene.layers[layerIndex].visible;

  void setLayerVisibility(int layerIndex, bool value) {
    _scene.layers[layerIndex].setVisibility(value);
    notifyListeners();
  }

  String getLayerName(int layerIndex) =>
      _scene.layers[layerIndex].name ?? 'Untitled';

  void setLayerName(int layerIndex, String value) {
    _scene.layers[layerIndex].setName(value);
    notifyListeners();
  }

  // ============
  // Group state:
  // ============

  List<LayerGroupInfo> get layerGroups => _scene.layerGroups;

  List<FrameReelModel> reelGroupOf(int layerIndex) {
    if (!isGrouped(layerIndex)) return [];

    final groupInfo = layerGroups.firstWhere((groupInfo) =>
        groupInfo.firstLayerIndex <= layerIndex &&
        layerIndex <= groupInfo.lastLayerIndex);

    return reels.sublist(
      groupInfo.firstLayerIndex,
      groupInfo.lastLayerIndex + 1,
    );
  }

  List<SceneLayer> layerGroupOf(int layerIndex) {
    if (!isGrouped(layerIndex)) return [];

    final groupInfo = layerGroups.firstWhere((groupInfo) =>
        groupInfo.firstLayerIndex <= layerIndex &&
        layerIndex <= groupInfo.lastLayerIndex);

    return _scene.layers.sublist(
      groupInfo.firstLayerIndex,
      groupInfo.lastLayerIndex + 1,
    );
  }

  bool isGrouped(int layerIndex) =>
      isGroupedWithAbove(layerIndex) || isGroupedWithBelow(layerIndex);

  bool isGroupedWithAbove(int layerIndex) =>
      layerIndex > 0 && _scene.layers[layerIndex - 1].groupedWithNext;

  bool isGroupedWithBelow(int layerIndex) =>
      _scene.layers[layerIndex].groupedWithNext;

  bool canGroupWithAbove(int layerIndex) =>
      layerIndex > 0 && !isGroupedWithAbove(layerIndex);

  bool canGroupWithBelow(int layerIndex) =>
      layerIndex < _scene.layers.length - 1 && !isGroupedWithBelow(layerIndex);

  void groupLayerWithAbove(int layerIndex) {
    if (layerIndex == 0) throw Exception('Cannot group first layer with above');
    groupLayerWithBelow(layerIndex - 1);
  }

  void groupLayerWithBelow(int layerIndex) {
    if (layerIndex == _scene.layers.length - 1)
      throw Exception('Cannot group last layer with below');

    final aIndex = layerIndex;
    final bIndex = layerIndex + 1;

    final aGroupLayers = layerGroupOf(aIndex);
    final bGroupLayers = layerGroupOf(bIndex);
    mergeGroups(aGroupLayers, bGroupLayers);

    final a = _scene.layers[aIndex];
    a.setGroupedWithNext(true);

    // Sync current frames in B to A.
    reelGroupOf(bIndex).forEach(
      (reel) => reel.setCurrent(reels[aIndex].currentIndex),
    );

    notifyListeners();
  }

  void ungroupLayer(int layerIndex) {
    if (layerIndex > 0) _scene.layers[layerIndex - 1].setGroupedWithNext(false);
    _scene.layers[layerIndex].setGroupedWithNext(false);
    notifyListeners();
  }
}

const _showFrameReelKey = 'frame_reel_visible';
