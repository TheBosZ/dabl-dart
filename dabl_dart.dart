import "package:dabl_query/query.dart";
import 'lib/dabl.dart';
import 'package:database_reverse_engineer/database_reverse_engineer.dart';
void main() {
	Map<String, String> conn_params = {
		'driver': 'mysql',
		'host': '127.0.0.1',
		'dbname': 'hoffman_ssm',
		'user': 'hoffman',
		'password': 'G00bers!'
	};
	DBManager.addConnection('hoffman', conn_params);

	DABLDDO conn = DBManager.getConnection('hoffman');


	conn.getDatabaseSchema().then((Database db) {
		print(db.toString());
	});
}
