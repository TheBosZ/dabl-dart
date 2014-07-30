import 'package:unittest/unittest.dart';
import '../../lib/generator/generator.dart';
import 'package:dabl/dbmanager.dart' as DBManager;
import 'package:ddo/ddo.dart';
import 'package:ddo/drivers/ddo_mysql.dart';

main() {
	Map<String, String> conn_params = {
       		'driver': 'mysql',
       		'host': '127.0.0.1',
       		'dbname': 'people',
       		'user': 'root',
       		'password': ''
       	};

   	DBManager.addConnection('rollcallDb', conn_params);

   	Driver driver = new DDOMySQL(conn_params['host'], conn_params['dbname'], conn_params['user'], conn_params['password']);
   	DBManager.setDriver(driver);
   	DefaultGenerator dg = new DefaultGenerator('people');
   	dg.setOptions({
   		'project_path': '../people/',
   		'model_path': 'models/',
   		'base_model_path': 'models/base/'
   	});
   	dg.generateProjectFiles();
}