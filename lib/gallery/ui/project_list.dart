import 'package:flutter/material.dart';
import 'package:mooltik/common/data/project/project.dart';
import 'package:mooltik/gallery/ui/project_thumbnail.dart';
import 'package:provider/provider.dart';
import 'package:mooltik/editing/editing_page.dart';
import 'package:mooltik/gallery/data/gallery_model.dart';

class ProjectList extends StatelessWidget {
  const ProjectList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gallery = context.watch<GalleryModel>();
    final projects = gallery.projects;

    return GridView.count(
      padding: const EdgeInsets.all(32),
      scrollDirection: Axis.vertical,
      crossAxisCount: MediaQuery.of(context).size.width ~/ 300,
      childAspectRatio: 16 / 9,
      mainAxisSpacing: 32,
      crossAxisSpacing: 32,
      children: [
        for (final project in projects)
          ChangeNotifierProvider<Project>.value(
            value: project,
            child: ProjectThumbnail(
              thumbnail: project.thumbnail,
              onTap: () async {
                await project.open();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider<Project>.value(
                      value: project,
                      child: EditingPage(),
                    ),
                  ),
                );
              },
            ),
          )
      ],
    );
  }
}
