import "package:dabl_query/query.dart";
import 'lib/dabl.dart';
import 'lib/dbmanager.dart';
import 'package:ddo/drivers/ddo_mysql.dart';
void main() {
	Map<String, String> conn_params = {
		'driver': 'mysql',
   		'host': '127.0.0.1',
   		'dbname': 'test',
   		'user': 'test_user',
   		'password': 'test'
   	};
	Driver driver = new DDOMySQL(conn_params['host'], conn_params['dbname'], conn_params['user'], conn_params['password']);
	addConnection('test', driver);

	DABLDDO conn = getConnection('test');
	Query q = new Query();
	q.setTable('task');
	q.doSelect(conn).then((DDOStatement stmt) {
		var results = stmt.fetchAll(DDO.FETCH_ASSOC);
		print(results);
	});
}
