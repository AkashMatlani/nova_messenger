import 'package:nova/networking/http_service.dart';
import 'package:get_it/get_it.dart';
import 'package:nova/services/internet_status_service.dart';
import 'package:nova/viewmodels/chat_list_viewmodel.dart';
import 'package:nova/viewmodels/chat_viewmodel.dart';

GetIt serviceLocator = GetIt.instance;

setupServiceLocator() {
  serviceLocator.registerLazySingleton(() => HttpService());
  serviceLocator.registerLazySingleton(() => ChatViewModel());
  serviceLocator.registerLazySingleton(() => ChatListViewModel());
  serviceLocator.registerFactory<InternetStatusService>(() => InternetStatusService());
}
