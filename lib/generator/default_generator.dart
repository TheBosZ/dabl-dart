part of dabl_generator;

class DefaultGenerator extends BaseGenerator {
  DefaultGenerator(String connectionName) : super(connectionName);

	Map<String, String> getActions(String tableName) {
		throw new UnimplementedError();
		String single = StringFormat.variable(tableName);
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