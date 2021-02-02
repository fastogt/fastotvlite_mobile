import 'package:fastotvlite/base/streams/program_bloc.dart';
import 'package:fastotvlite/base/streams/programs_list.dart';
import 'package:fastotvlite/base/tv/constants.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';

// player
class TvPlayerWrap extends StatefulWidget {
  final Widget child;
  final bool fullscreen;
  final bool Function(FocusNode node, RawKeyEvent event) onKey;

  const TvPlayerWrap(this.child, this.fullscreen, this.onKey);

  @override
  _TvPlayerWrapState createState() => _TvPlayerWrapState();
}

class _TvPlayerWrapState extends State<TvPlayerWrap> {
  final FocusNode _node = FocusNode();
  Color _color = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _node.dispose();
  }

  @override
  void didUpdateWidget(TvPlayerWrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setColor();
    if (widget.fullscreen) {
      FocusScope.of(context).requestFocus(_node);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
          height: constraints.maxWidth / 16 * 9,
          decoration:
              BoxDecoration(color: Colors.black, border: Border.all(color: _color, width: 2)),
          child: Focus(
              onKey: widget.onKey,
              focusNode: _node,
              child: widget.child,
              autofocus: widget.fullscreen));
    });
  }

  void _onFocusChange() {
    _setColor();
  }

  void _setColor() {
    setState(() {
      if (widget.fullscreen || !_node.hasFocus) {
        _color = Colors.transparent;
      } else {
        _color = Theme.of(context).accentColor;
      }
    });
  }
}

class Programs extends StatelessWidget {
  final ProgramsBloc programsBloc;
  final Size size;

  const Programs(this.size, this.programsBloc);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: size.width,
        height: size.height,
        child: ProgramsListView(
            itemHeight: TV_LIST_ITEM_SIZE,
            programsBloc: programsBloc,
            textColor: Theming.of(context).onBrightness()));
  }
}
