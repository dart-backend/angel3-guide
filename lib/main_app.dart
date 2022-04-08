import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'src/error/not_found_component.dart';
import 'src/widgets/footer.dart';
import 'src/widgets/header.dart';
import 'src/home/home.dart';
import 'src/routes.dart';

@Component(
    selector: 'main-app',
    styleUrls: ['main_app.css'],
    templateUrl: 'main_app.html',
    directives: [
      routerDirectives,
      NotFoundComponent,
      HeaderPanel,
      FooterPanel,
      HomePanel
    ],
    providers: [ClassProvider(PortalRoutes)],
    exports: [PortalRoutes])
class MainApp {
  final PortalRoutes routes;

  String title = ' ';

  MainApp(this.routes);
}
