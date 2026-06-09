import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/core/utils/app_routes.dart';
import 'package:mechanix_messages/core/utils/theme.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_event.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository_impl.dart';
import 'package:mechanix_messages/features/messages/presentation/screens/conversation_screen.dart';
import 'package:mechanix_messages/features/messages/presentation/screens/messages_screen.dart';
import 'package:mechanix_messages/features/messages/presentation/screens/select_contact_screen.dart';
import 'package:show_fps/show_fps.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MessageRepositoryImpl>(
          create: (_) => MessageRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<MessagesBloc>(
            create: (context) =>
                MessagesBloc(repository: context.read<MessageRepositoryImpl>())
                  ..add(const LoadConversations()),
          ),
        ],
        child: const MessagesApp(),
      ),
    ),
  );
}

class MessagesApp extends StatelessWidget {
  const MessagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final showFps = Platform.environment['SHOW_FPS'] == 'true';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: showFps
          ? (context, child) {
              return ShowFPS(visible: showFps, showChart: false, child: child!);
            }
          : null,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark,
      theme: AppTheme.light,
      locale: const Locale('en'),
      home: const MessagesScreen(),
      routes: {
        AppRoutes.conversation: (context) => const ConversationScreen(),
        AppRoutes.selectContact: (context) => const SelectContactScreen(),
      },
    );
  }
}
