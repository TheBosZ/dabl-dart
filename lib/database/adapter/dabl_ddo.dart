part of dabl;

abstract class DABLDDO extends DDO {
	static const int ID_METHOD_NONE = 0;
	static const int ID_METHOD_AUTOINCREMENT = 1;
	static const int ID_METHOD_SEQUENCE = 2;

	String _dbName;

	void setDBName(String name) {
		_dbName = name;
	}

	String getDBName() {
		return _dbName;
	}

	DABLDDO(Driver driver) :
		super(driver);

	factory DABLDDO.factory(Map<String, String> connectionParams, Driver driver) {
		DABLDDO obj;

		switch(connectionParams['driver']) {
			case 'mysql':
				obj = new DBMySQL(driver);
				break;
			case 'websql':
				obj = new DBWebSQL(driver);
				break;
			default:
            	throw new ArgumentError("Unsupported database driver: '${connectionParams['driver']}'");

		}
		obj.setDBName(connectionParams['dbname']);
		return obj;
	}

	Future<DDOStatement> query(String query) {
		return super.query(query);
	}

	Future<int> exec(String state){
		return super.exec(state);
	}

	void initConnection(Map<String, Object> settings) {
		if(settings.containsKey('charset') &&
			settings['charset'] is Map<String, String> &&
			(settings['charset'] as  Map<String, String>).containsKey(['value'])){
			setCharset((settings['charset'] as  Map<String, String>)['value']);
		}
		if(settings.containsKey('queries') && settings['queries'] is List<String>) {
			(settings['queries'] as List<String>).forEach((q) => exec(q));
		}
	}

	void setCharset(String charset) {
		exec("SET NAMES '${charset}'");
	}

	String toUpperCase(String i);

	String getStringDelimiter() {
		return "'";
	}

	String ignoreCase(String s);

	String ignoreCaseInOrderBy(String s) {
		return ignoreCase(s);
	}

	String concatString(String s1, String s2);

	String subString(String s, int pos, int len);

	String strLength(String s);

	int _getIdMethod() {
		return DABLDDO.ID_METHOD_AUTOINCREMENT;
	}

	bool isGetIdBeforeInsert() {
		return _getIdMethod() == DABLDDO.ID_METHOD_SEQUENCE;
	}

	bool isGetIdAfterInsert() {
		return _getIdMethod() == DABLDDO.ID_METHOD_AUTOINCREMENT;
	}

	Object getId([String name = null]) {
		return lastInsertId(name);
	}

	String getTimestampFormatter() {
		return 'y-M-d HH:mm:ss';
	}

	String getDateFormatter() {
		return 'y-M-d';
	}

	String getTimeFormatter() {
		return 'HH:mm:ss';
	}

	bool useQuoteIdentifier();

	String applyLimit(String sql, int offset, int limit);

	String random([int seed = null]);

	Future<Database> getDatabaseSchema();
}