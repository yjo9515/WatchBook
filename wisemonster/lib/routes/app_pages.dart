import 'package:get/get.dart';
import 'package:wisemonster/binding/binding.dart';
import 'package:wisemonster/routes/app_routes.dart';
import 'package:wisemonster/view/findId_view.dart';
import 'package:wisemonster/view/findPw_view.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/navigator_view.dart';
import 'package:wisemonster/view/intro_view.dart';
import 'package:wisemonster/view/push_view.dart';
import 'package:wisemonster/view/result_view.dart';
import 'package:wisemonster/view/splash_view.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => splash_view(),
      binding: SplahBinding(),
      children: [
        GetPage(
          name: Routes.LOGIN,
          page: () => login_view(),
          binding: LoginBinding(),
          children: [
            GetPage(
              name: Routes.FINDID,
              page: () => findId_view(),
            ),
            GetPage(
              name: Routes.FINDPW,
              page: () => findPw_view(),
            ),
          ]
        ),
        GetPage(
          name: Routes.HOME,
          page: () => home_view(),
        ),
      ]
    ),
    GetPage(
      name: Routes.INTRO,
      page: () => intro_view(),
    ),

    GetPage(
      name: Routes.PUSH,
      page: () => push_view()
    ),
    GetPage(
      name: Routes.NAVIGATOR,
      page: () => navigator_view()
    ),
    GetPage(
      name: Routes.RESULT,
      page: () => result_view(),
    )
  ];
}
