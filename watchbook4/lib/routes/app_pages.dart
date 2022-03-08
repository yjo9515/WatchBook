import 'package:get/get.dart';
import 'package:watchbook4/routes/app_routes.dart';
import 'package:watchbook4/view/findId_view.dart';
import 'package:watchbook4/view/findPw_view.dart';
import 'package:watchbook4/view/home_view.dart';
import 'package:watchbook4/view/login_view.dart';
import 'package:watchbook4/view/newMember_view.dart';
import 'package:watchbook4/view/push_view.dart';
import 'package:watchbook4/view/result_view.dart';
import 'package:watchbook4/view/splash_view.dart';


class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => splash_view(),
      children:
      [
        GetPage(
          name: Routes.LOGIN,
          page: () => login_view(),
          children: [
            GetPage(
              name: Routes.FINDID,
              page: () => findId_view(),
            ),
            GetPage(
              name: Routes.FINDPW,
              page: () => findPw_view(),
            ),
            GetPage(
              name: Routes.NEWMEMBER,
              page: () => newMember_view(),
            ),
            GetPage(
              name: Routes.HOME,
              page: () => home_view(),
              children: [
                GetPage(
                    name: Routes.PUSH,
                    page: () => push_view(),
                    children: [
                      GetPage(
                        name: Routes.RESULT,
                        page: () => result_view(),
                      )
                    ]
                ),
              ],
            ),
          ],
        ),
      ]
    ),
  ];
}