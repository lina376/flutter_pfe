import 'package:flutter/material.dart';

class Paramettre extends StatefulWidget {
  static const String screenRoute = 'pageparamettre';
  const Paramettre({super.key});

  @override
  State<Paramettre> createState() => _ParamettreState();
}

class _ParamettreState extends State<Paramettre>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
