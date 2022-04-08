import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';

import '../routes.dart';
import '../config/app_config.dart' as app_config;

@Component(
  selector: 'header-panel',
  styleUrls: ['header.css'],
  templateUrl: 'header.html',
  directives: [routerDirectives, NgClass],
  providers: [],
)
class HeaderPanel {
  final PortalRoutes _routes;

  String mobileMenu = "";

  HeaderPanel(this._routes);

  void showMobileMenu() {
    print("Show menu");
    if (mobileMenu == "") {
      mobileMenu = "is-active";
    } else {
      mobileMenu = "";
    }
  }

  PortalRoutes get routes => _routes;
}
