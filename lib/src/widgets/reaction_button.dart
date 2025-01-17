import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_reaction_button/src/enums/reaction.dart';
import 'package:flutter_reaction_button/src/extensions/key.dart';
import 'package:flutter_reaction_button/src/widgets/reactions_box.dart';

class ReactionButton<T> extends StatefulWidget {
  const ReactionButton({
    super.key,
    required this.onReactionChanged,
    required this.reactions,
    this.placeholder,
    this.selectedReaction,
    this.boxColor = Colors.white,
    this.boxElevation = 5,
    this.boxRadius = 50,
    this.isChecked = false,
    this.itemsSpacing = 8,
    this.itemScale = .3,
    required this.itemSize,
    this.animateBox = true,
    this.toggle = true,
    this.boxPadding = const EdgeInsets.all(4),
    this.boxAnimationDuration = const Duration(milliseconds: 200),
    this.itemAnimationDuration = const Duration(milliseconds: 100),
    this.hoverDuration = const Duration(milliseconds: 400),
    this.child,
  }) : _type = child != null ? ReactionType.container : ReactionType.button;

  /// This triggers when reaction button value changed.
  final ValueChanged<Reaction<T>?> onReactionChanged;

  /// Default widget if no reaction selected
  final Reaction<T>? placeholder;

  /// Selected reaction button when tap on widget
  final Reaction<T>? selectedReaction;

  final List<Reaction<T>?> reactions;

  /// Reactions box color [default = white]
  final Color boxColor;

  /// Reactions box elevation [default = 5]
  final double boxElevation;

  /// Reactions box radius [default = 50]
  final double boxRadius;

  /// Reactions box visibility duration [default = 200 milliseconds]
  final Duration boxAnimationDuration;

  /// Flag for pre-set reactions if true @link selectedReaction will be
  /// displayed else @link initialReaction will be displayed [default = false]
  final bool isChecked;

  /// Reactions box padding [default = const EdgeInsets.all(0)]
  final EdgeInsetsGeometry boxPadding;

  /// Spacing between the reaction items
  final double itemsSpacing;

  /// Scale ratio when item hovered [default = 0.3]
  final double itemScale;

  /// Animation duration while moving [default = const Duration(milliseconds: 100)]
  final Duration itemAnimationDuration;

  final Size itemSize;

  final bool animateBox;

  final bool toggle;

  final Widget? child;

  final Duration hoverDuration;

  final ReactionType _type;

  @override
  State<ReactionButton<T>> createState() => _ReactionButtonState<T>();
}

class _ReactionButtonState<T> extends State<ReactionButton<T>> {
  final GlobalKey _globalKey = GlobalKey();

  late Reaction<T>? _selectedReaction =
      _isChecked ? widget.selectedReaction : widget.placeholder;

  late bool _isChecked = widget.isChecked;

  bool get _isContainer => widget._type == ReactionType.container;

  OverlayEntry? _overlayEntry;

  void _updateReaction(Reaction<T>? reaction) {
    _isChecked = reaction != widget.placeholder;
    widget.onReactionChanged.call(reaction);
    setState(() {
      _selectedReaction = reaction;
    });
  }

  void _onCheck() {
    _isChecked = !_isChecked;
    _updateReaction(
      _isChecked
          ? widget.selectedReaction ?? widget.reactions.first
          : widget.placeholder,
    );
  }

  void _onShowReactionsBox([Offset? offset]) {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return ReactionsBox<T>(
          offset: offset ?? _globalKey.offset,
          itemSize: widget.itemSize,
          reactions: widget.reactions,
          color: widget.boxColor,
          elevation: widget.boxElevation,
          radius: widget.boxRadius,
          boxDuration: widget.boxAnimationDuration,
          boxPadding: widget.boxPadding,
          itemSpace: widget.itemsSpacing,
          itemScale: widget.itemScale,
          itemScaleDuration: widget.itemAnimationDuration,
          animateBox: widget.animateBox,
          onReactionSelected: (reaction) {
            _updateReaction(reaction);
            _disposeOverlayEntry();
          },
          onClose: () {
            _disposeOverlayEntry();
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _disposeOverlayEntry() {
    _overlayEntry
      ?..remove()
      ..dispose();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _disposeOverlayEntry();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget? child = _isContainer
        ? widget.child
        : (_selectedReaction ?? widget.reactions.first)!.icon;

    return GestureDetector(
      key: _globalKey,
      onTap: () {
        if (widget.toggle) {
          _onCheck();
        } else {
          _onShowReactionsBox();
        }
      },
      onLongPressStart: (details) {
        if (widget.toggle) {
          _onShowReactionsBox(_isContainer ? details.globalPosition : null);
        }
      },
      child: child,
    );
  }
}
