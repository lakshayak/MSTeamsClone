import 'package:teams_clone/models/log.dart';
// Interface with all methods related to log storage
abstract class LogInterface {
  openDb(dbName);
  init();
  addLogs(Log log);
  Future<List<Log>> getLogs();   // returns a list of logs
  deleteLogs(int logId);
  close();
}