import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mooltik/common/data/project/project.dart';

class GalleryModel extends ChangeNotifier {
  Directory _directory;
  List<Project> _projects;

  int get numberOfProjects => _projects?.length;

  Future<void> init(Directory directory) async {
    _directory = directory;
    _projects = await _readProjects();
    notifyListeners();
  }

  Future<List<Project>> _readProjects() async {
    final List<Project> projects = [];
    await for (final FileSystemEntity dir in _directory.list()) {
      if (dir is Directory && Project.validProjectDirectory(dir)) {
        projects.add(Project(dir));
      }
    }
    // Recent projects first.
    projects.sort((p1, p2) => p2.creationEpoch - p1.creationEpoch);
    return projects;
  }

  Project getProject(int index) => _projects[index];

  Future<Project> addProject() async {
    if (_projects == null) throw Exception('Read projects first.');

    final project = Project.createIn(_directory);
    _projects.insert(0, project);

    notifyListeners();
    return project;
  }

  Future<void> deleteProject(int index) async {
    final Project project = _projects.removeAt(index);
    await project.directory.delete(recursive: true);
    notifyListeners();
  }
}
