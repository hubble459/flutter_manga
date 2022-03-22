import 'package:flutter/material.dart';

class SkeletonList extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;

  const SkeletonList({Key? key, required this.itemBuilder}) : super(key: key);

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> animationOne;
  late Animation<Color?> animationTwo;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    animationOne = ColorTween(begin: Colors.grey.shade700, end: Colors.grey).animate(_controller);
    animationTwo = ColorTween(begin: Colors.grey, end: Colors.grey.shade700).animate(_controller);

    _controller.forward();

    _controller.addListener(() {
      if (_controller.isCompleted) {
        _controller.reverse();
      } else if (_controller.isDismissed) {
        _controller.forward();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(colors: [animationOne.value!, animationTwo.value!]).createShader(rect),
      child: ListView.builder(itemCount: 10, itemBuilder: widget.itemBuilder),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}

class SkeletonRow extends StatelessWidget {
  final double height;
  final double width;

  const SkeletonRow({Key? key, this.height = 10, this.width = double.infinity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }
}
