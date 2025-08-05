import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/tomorrow-night.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  bool containsPythonCode(String text) {
    return text.contains("def") ||
        text.contains("import") ||
        text.contains("print(") ||
        text.contains("input(");
  }

  bool isComment(String line) {
    return line.trim().startsWith(">");
  }

  List<InlineSpan> formatMessage(String text, bool isDarkMode, TextStyle defaultStyle) {
    List<InlineSpan> spans = [];
    List<String> lines = text.split("\n");

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      bool comment = isComment(line);
      bool hasPython = containsPythonCode(line);

      if (comment) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 4, bottom: i == lines.length - 1 ? 0 : 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black54 : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: isDarkMode ? Colors.white70 : Colors.black54),
              ),
              child: hasPython
                  ? HighlightView(
                      line.substring(1).trim(),
                      language: 'python',
                      theme: isDarkMode ? tomorrowNightTheme : githubTheme,
                      textStyle: const TextStyle(fontSize: 14),
                    )
                  : Text(
                      line.substring(1).trim(),
                      style: defaultStyle.copyWith(fontSize: 14),
                    ),
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: i == lines.length - 1 ? line : "$line\n",
            style: defaultStyle,
          ),
        );
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final defaultTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isDarkMode ? Colors.white : Colors.black,
        ) ??
        TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        );

    final bubbleDecoration = BoxDecoration(
      color: isCurrentUser
          ? Theme.of(context).colorScheme.inversePrimary
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border(
        left: isCurrentUser ? BorderSide.none : const BorderSide(color: Colors.black, width: 2),
        right: isCurrentUser ? const BorderSide(color: Colors.black, width: 2) : BorderSide.none,
        bottom: const BorderSide(color: Colors.black, width: 2),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: isCurrentUser ? const Offset(2, 2) : const Offset(-2, 2),
          blurRadius: 4,
        ),
      ],
    );

    if (!message.contains(">") && containsPythonCode(message)) {
      return Container(
        decoration: bubbleDecoration,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        child: HighlightView(
          message.trim(),
          language: 'python',
          theme: isDarkMode ? tomorrowNightTheme : githubTheme,
          textStyle: const TextStyle(fontSize: 14),
        ),
      );
    }

    return Container(
      decoration: bubbleDecoration,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: RichText(
        text: TextSpan(
          children: formatMessage(message.trim(), isDarkMode, defaultTextStyle),
        ),
      ),
    );
  }
}