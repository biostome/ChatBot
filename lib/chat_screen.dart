import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:velocity_x/velocity_x.dart';
import 'chat_message.dart';
import 'navigation_drawer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late OpenAI? chatGPT;
  bool _isImageSearch = false;

  bool _isTyping = false;
  String title = "ChatGPT";

  @override
  void initState() {
    chatGPT = OpenAI.instance.build(
        token: dotenv.env["API_KEY"],
        baseOption: HttpSetup(receiveTimeout: 60000));
    super.initState();
  }

  @override
  void dispose() {
    chatGPT?.close();
    chatGPT?.genImgClose();
    super.dispose();
  }

  // Link for api - https://beta.openai.com/account/api-keys

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    if (_isTyping == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please for a while",
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.grey,
      ));
      return;
    }

    ChatMessage message = ChatMessage(
      text: _controller.text,
      sender: "user",
      isImage: false,
    );

    setState(() {
      _isTyping = true;
      _messages.add(message);
    });

    _controller.clear();
    _scrollController.jumpToBottom();

    if (_isImageSearch) {
      final request = GenerateImage(message.text, 1, size: "256x256");

      final response = await chatGPT!.generateImage(request);
      Vx.log(response!.data!.last!.url!);
      insertNewData(response.data!.last!.url!, isImage: true);
    } else {
      final request = CompleteText(
          prompt: message.text, model: kTranslateModelV3, maxTokens: 2048);

      chatGPT!.onCompleteText(request: request).then((response) {
        Vx.log(response!.choices[0].text);
        insertNewData(response.choices[0].text, isImage: false);
      }).onError((error, stackTrace) {
        final value = error.toString();
        Vx.log(value);
        insertNewData(value, isImage: false, error: value);
      }).whenComplete(() => null);
    }
  }

  void insertNewData(String response, {bool isImage = false, Object? error}) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      sender: "bot",
      isImage: isImage,
      error: error,
    );

    setState(() {
      _isTyping = false;
      _messages.add(botMessage);
      _scrollController.jumpToBottom();
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: const InputDecoration.collapsed(
              hintText: "Question/description",
            ),
          ),
        ),
        ButtonBar(
          children: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                _isImageSearch = false;
                _sendMessage();
              },
            ),
            // TextButton(
            //     onPressed: () {
            //       _isImageSearch = true;
            //       _sendMessage();
            //     },
            //     child: const Text("Generate Image"))
          ],
        ),
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_isTyping ? "Bot typing..." : title),
          shadowColor: Vx.gray50,
          elevation: 0.5,
        ),
        drawer: const NavigationDrawer(),

        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                  child: ListView.separated(
                padding: EdgeInsets.zero,
                controller: _scrollController,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return _messages[index];
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 1,
                  );
                },
                itemCount: _messages.length,
              )),
              const Divider(
                height: 1.0,
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                ),
                child: _buildTextComposer(),
              ),
              Text(
                "Developed using gpt-3.5-turbo API. Please refresh the page if you encounter an error.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ).pOnly(left: 8,right: 8)
            ],
          ),
        ));
  }
}
