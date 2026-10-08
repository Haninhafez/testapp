import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:testapp/deep_link/deep_link.dart';
import 'package:testapp/main.dart';
import 'package:testapp/maps/google_map.dart';
import 'package:testapp/maps/map_page.dart';
import 'package:testapp/notfications/chatpage.dart';
import 'package:testapp/notfications/home_page_practice_in_notfications.dart';
import 'package:testapp/payment/data/repositories/payment_imp_repo.dart';
import 'package:testapp/payment/domain/usecases/create_payment_usecase.dart';
import 'package:testapp/payment/presentation/cubit/payment_cubit.dart';
import 'package:testapp/payment/presentation/pages/payment_page.dart';

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
          path: '/payment_page',
          builder: (context, state) {

            return BlocProvider(
              create: (context) => PaymentCubit(CreatePayment(FakePaymentRepository())),
              child: const PaymentMethodPage(),
            );
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
        GoRoute(
          path: '/map',
          builder: (context, state) {
            return const MapScreen();
          },
        ),
        GoRoute(
          path: '/google_map',
          builder: (context, state) => GoogleMapScreen(),
        ),
      ],
    ),
  ],
);
