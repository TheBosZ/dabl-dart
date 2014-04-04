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

	DABLDDO({String dsn, String username: '', String password: '', Map<int, int> driver_options: null}) :
		super(dsn: dsn, username: username, password: password, driver_options: driver_options);

	factory DABLDDO.factory(Map<String, String> connectionParams) {
		DABLDDO obj;
		String dsn;
		String user;
		String password;

		if(connectionParams.containsKey('user')) {
			user = connectionParams['user'];
		}

		if(connectionParams.containsKey('password')) {
			password = connectionParams['password'];
		}

		var options = {DDO.ATTR_ERRMODE: DDO.ERRMODE_EXCEPTION};
		if(connectionParams.containsKey('persistant')) {
			var p = connectionParams['persistant'].trim().toLowerCase();
			switch(p) {
				case 'true':
				case '1':
				case 'on':
					options['persistant'] = true;
					break;
			}
		}

		switch(connectionParams['driver']) {
			case 'mysql':
				List<String> parts = new List<String>();
				if(connectionParams.containsKey('host')){
					parts.add(connectionParams['host']);
				}
				if(connectionParams.containsKey('port')){
					parts.add(connectionParams['port']);
				}
				if(connectionParams.containsKey('unix_socket')){
					parts.add(connectionParams['unix_socket']);
				}
				if(connectionParams.containsKey('dbname')){
					parts.add(connectionParams['dbname']);
				}
				parts.map((String f) => f.replaceAll(';', r'\;'));
				String dsn = 'mysql:${parts.join(';')}';
				obj = new DBMySQL(dsn: dsn, username: user, password: password, driver_options: options);
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

	Object prepareInput(Object val) {
		if(val is List) {
			return val.map((v) => prepareInput(v));
		}

		if(val is num) {
			return val;
		}

		if(val is bool) {
			return val ? 1 : 0;
		}

		if(val == null) {
			return 'NULL';
		}

		return quote(val);
	}

	String ignoreCase(String s);

	String ignoreCaseInOrderBy(String s) {
		return ignoreCase(s);
	}

	String concatString(String s1, String s2);

	String subString(String s, int pos, int len);

	String strLength(String s);

	Object quoteIdentifier(Object val) {
		if(val is List) {
			return val.map((v) => quoteIdentifier(v));
		}

		if(val is String) {
			if (val.contains(new RegExp(r'[" (\*]'))) {
				return val;
			}
			return '"${val.replaceAll('.', '","')}"';
		}

		return val;
	}

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
		return 'Y-m-d H:i:s';
	}

	String getDateFormatter() {
		return 'Y-m-d';
	}

	String getTimeFormatter() {
		return 'H:i:s';
	}

	bool useQuoteIdentifier();

	String applyLimit(String sql, int offset, int limit);

	String random([int seed = null]);

	Object getDatabaseSchema();
}