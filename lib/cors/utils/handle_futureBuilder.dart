import 'package:flutter/material.dart';

class HandleFuturebuilder<T> extends StatelessWidget {
  const HandleFuturebuilder(
      {super.key,
      required this.future,
      required this.builder,
      this.loadingWidget,
      this.errorWidget});

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return errorWidget ?? const Text('Something went wrong!');
        } else if (snapshot.hasData) {
          return builder(context, snapshot.data as T);
        } else {
          return const Text('No data available');
        }
      },
    );
  }
}
