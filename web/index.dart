import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:http/browser_client.dart';

import 'package:angel3_doc/main_app.template.dart' as ng;

import 'index.template.dart' as self;

const useHashLS = false;

@GenerateInjector([
  routerProvidersHash, // For development
  // routerProviders, // For Production
  ClassProvider(BrowserClient),
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.MainAppNgFactory, createInjector: injector);
//  runApp(ng.EditorComponentNgFactory);
}
