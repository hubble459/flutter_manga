import 'package:flutter/material.dart';

class Cover extends StatelessWidget {
  final Uri? referer;
  final Uri? cover;

  const Cover(this.cover, this.referer, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Visibility(
          visible: cover != null,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Image.network(
              cover.toString(),
              headers: referer != null ? {'Referer': referer.toString()} : null,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          )),
    );
  }
}
