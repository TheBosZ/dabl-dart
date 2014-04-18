part of dabl;

class DefaultGenerator extends BaseGenerator {
  DefaultGenerator(String connectionName) : super(connectionName);

	Map<String, String> getActions(String tableName) {
		String single = StringFormat.variable(tablename);
		List<Column> pks = getPrimaryKeys(tableName);
		Column pk;

		if(pks.length == 1) {
			pk = pks.first;
		}
		Map<String, String> actions = new Map<String, String>();
		if(pk == null) {
			return actions;
		}

		String pkMethod = StringFormat.classMethod('get${StringFormat.titleCase(pk.getName())}');

		for(String action in _standardActions) {

		}

	}
}