import "package:dabl_query/query.dart";
import 'lib/dabl.dart';
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
	Query q = new Query('project');
	String queryinjection = '\'; delete * from * -- bob';
	String firstname = 'bob';
	q.add('refId', 2);
	q.add('name', firstname, Query.NOT_EQUAL);
	q.add('name', queryinjection);
	Condition c = new Condition();
	c.add('rand()', false);
	c.addOr('rand()', false);
	q.add(c);
	print(q.getQuery(conn));
}
