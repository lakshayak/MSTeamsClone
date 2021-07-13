import 'package:teams_clone/models/log.dart';
import 'package:teams_clone/resources/local_db/db/hive_methods.dart';

// Creating a log class containing methods to access logs stored in local database
class LogRepository {
  static var dbObject;
  static late bool isHive;

  static init({required bool isHive, required String dbName}) {
    dbObject = isHive ? HiveMethods() : false;
    dbObject.openDb(dbName);
    dbObject.init();
  }

  static addLogs(Log log) => dbObject.addLogs(log);
  static deleteLogs(int logId) => dbObject.deleteLogs(logId);
  static getLogs() => dbObject.getLogs();
  static close() => dbObject.close();
}