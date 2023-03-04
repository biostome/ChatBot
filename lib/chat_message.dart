import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    super.key,
    required this.text,
    required this.sender,
    this.isImage = false,
    this.error,
  });

  final String text;
  final String sender;
  final bool isImage;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          sender == "user" ? 'images/person.png' : 'images/chat_logo.png',
          height: 30.0,
          width: 30.0,
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: isImage
              ? buildImage()
              : text
                  .trim()
                  .text
                  .bodyText1(context)
                  .color(error == null
                      ? Theme.of(context).textTheme.bodyText1!.color
                      : Colors.red)
                  .make(),
        ),
      ],
    ).py8().backgroundColor(sender == "user" ? Vx.white : Vx.gray50);
  }

  AspectRatio buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        text,
        loadingBuilder: (context, child, loadingProgress) =>
            loadingProgress == null
                ? child
                : const CircularProgressIndicator.adaptive(),
      ),
    );
  }
/*
  DefaultTextStyle buildAnimateText() {
    return DefaultTextStyle(
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      child: AnimatedTextKit(
        isRepeatingAnimation: false,
        repeatForever: true,
        displayFullTextOnTap: false,
        totalRepeatCount: 0,
        stopPauseOnTap: true,
        animatedTexts: [
          TyperAnimatedText(
            text.trim(),
          ),
        ],
      ),
    );
  }*/
}
