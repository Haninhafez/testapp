import 'package:go_router/go_router.dart';
import 'package:testapp/deep_link/deep_link.dart';
import 'package:testapp/main.dart';
import 'package:testapp/notfications/chatpage.dart';
import 'package:testapp/notfications/home_page_practice_in_notfications.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'product/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return DeepLinkScreen(id: id);
          },
        ),

        GoRoute(
          path: '/home',
          builder: (context, state) {
            return const HomeScreen();
          },
        ),

         GoRoute(
          path: '/chat',
          builder: (context, state) {
         
            return const ChatPage();
          },
        ),
      ],
    ),
  ],
);
