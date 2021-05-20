import 'package:flutter/material.dart';
import 'package:mooltik/editing/ui/actionbar/editing_actionbar.dart';
import 'package:mooltik/editing/ui/preview/preview.dart';
import 'package:mooltik/editing/data/timeline_model.dart';
import 'package:mooltik/editing/ui/timeline/timeline_panel.dart';
import 'package:mooltik/common/data/project/project.dart';
import 'package:provider/provider.dart';

class EditingPage extends StatefulWidget {
  static const routeName = '/editor';

  @override
  _EditingPageState createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage>
    with SingleTickerProviderStateMixin, RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<RouteObserver>().subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    // Refresh visible frames.
    setState(() {});
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimelineModel(
        sceneSeq: context.read<Project>().scenes,
        vsync: this,
      ),
      child: WillPopScope(
        // Disables iOS swipe back gesture. (https://github.com/flutter/flutter/issues/14203)
        onWillPop: () async => true,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: PreviewArea(),
                ),
                Expanded(
                  child: TimelinePanel(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PreviewArea extends StatelessWidget {
  const PreviewArea({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final sceneNumber = context.watch<TimelineModel>().currentSceneNumber;

    return Flex(
      direction: isPortrait ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditingActionbar(
          title: Text(
            isPortrait ? 'Scene $sceneNumber' : '$sceneNumber',
            style: TextStyle(fontSize: 18),
          ),
          direction: isPortrait ? Axis.horizontal : Axis.vertical,
        ),
        Preview(),
        Expanded(
          child: DescriptionArea(),
        ),
      ],
    );
  }
}

class DescriptionArea extends StatelessWidget {
  const DescriptionArea({
    Key key,
    this.description,
  }) : super(key: key);

  final String description;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: description == null
            ? _buildPlaceholder(context)
            : Text(description),
      ),
    );
  }

  Text _buildPlaceholder(BuildContext context) {
    return Text(
      'Tap to add scene description',
      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
    );
  }
}
