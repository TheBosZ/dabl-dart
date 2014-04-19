part of dabl;

abstract class Model {

	static const String COLUMN_TYPE_CHAR = 'CHAR';
    static const String COLUMN_TYPE_VARCHAR = 'VARCHAR';
    static const String COLUMN_TYPE_LONGVARCHAR = 'LONGVARCHAR';
    static const String COLUMN_TYPE_CLOB = 'CLOB';
    static const String COLUMN_TYPE_NUMERIC = 'NUMERIC';
    static const String COLUMN_TYPE_DECIMAL = 'DECIMAL';
    static const String COLUMN_TYPE_TINYINT = 'TINYINT';
    static const String COLUMN_TYPE_SMALLINT = 'SMALLINT';
    static const String COLUMN_TYPE_INTEGER = 'INTEGER';
    static const String COLUMN_TYPE_INTEGER_TIMESTAMP = 'INTEGER_TIMESTAMP';
    static const String COLUMN_TYPE_BIGINT = 'BIGINT';
    static const String COLUMN_TYPE_REAL = 'REAL';
    static const String COLUMN_TYPE_FLOAT = 'FLOAT';
    static const String COLUMN_TYPE_DOUBLE = 'DOUBLE';
    static const String COLUMN_TYPE_BINARY = 'BINARY';
    static const String COLUMN_TYPE_VARBINARY = 'VARBINARY';
    static const String COLUMN_TYPE_LONGVARBINARY = 'LONGVARBINARY';
    static const String COLUMN_TYPE_BLOB = 'BLOB';
    static const String COLUMN_TYPE_DATE = 'DATE';
    static const String COLUMN_TYPE_TIME = 'TIME';
    static const String COLUMN_TYPE_TIMESTAMP = 'TIMESTAMP';
    static const String COLUMN_TYPE_BU_DATE = 'BU_DATE';
    static const String COLUMN_TYPE_BU_TIMESTAMP = 'BU_TIMESTAMP';
    static const String COLUMN_TYPE_BOOLEAN = 'BOOLEAN';

    static final List<String> textTypes = [
		COLUMN_TYPE_CHAR,
		COLUMN_TYPE_VARCHAR,
		COLUMN_TYPE_LONGVARCHAR,
		COLUMN_TYPE_CLOB,
		COLUMN_TYPE_DATE,
		COLUMN_TYPE_TIME,
		COLUMN_TYPE_TIMESTAMP,
		COLUMN_TYPE_BU_DATE,
		COLUMN_TYPE_BU_TIMESTAMP
	];

    static final List<String> integerTypes = [
    	COLUMN_TYPE_SMALLINT,
    	COLUMN_TYPE_TINYINT,
    	COLUMN_TYPE_INTEGER,
    	COLUMN_TYPE_BIGINT,
    	COLUMN_TYPE_BOOLEAN,
    	COLUMN_TYPE_INTEGER_TIMESTAMP
    ];

    static final List<String> lobTypes = [
    	COLUMN_TYPE_VARBINARY,
    	COLUMN_TYPE_LONGVARBINARY,
    	COLUMN_TYPE_BLOB
    ];

    static final List<String> temporalTypes = [
    	COLUMN_TYPE_DATE,
    	COLUMN_TYPE_TIME,
    	COLUMN_TYPE_TIMESTAMP,
    	COLUMN_TYPE_BU_DATE,
    	COLUMN_TYPE_BU_TIMESTAMP,
    	COLUMN_TYPE_INTEGER_TIMESTAMP
    ];

    static final List<String> numericTypes = [
    	COLUMN_TYPE_SMALLINT,
    	COLUMN_TYPE_TINYINT,
    	COLUMN_TYPE_INTEGER,
    	COLUMN_TYPE_BIGINT,
    	COLUMN_TYPE_FLOAT,
    	COLUMN_TYPE_DOUBLE,
    	COLUMN_TYPE_NUMERIC,
    	COLUMN_TYPE_DECIMAL,
    	COLUMN_TYPE_REAL,
    	COLUMN_TYPE_INTEGER_TIMESTAMP
    ];

    /**
	 * The maximum size of the instance pool
	 */
    static const int MAX_INSTANCE_POOL_SIZE = 400;

    /**
	 * Name of the table
	 */
	static String _tableName;

	/**
	 * Cache of objects retrieved from the database
	 */
	static Map<String, Model> _instancePool = new Map<String, Model>();

    static int _instancePoolCount = 0;

    static bool _poolEnabled = true;

    /**
	 * List of objects to batch insert
	 */
    static List<Model> _insertBatch;

    /**
	 * Maximum size of the insert batch
	 */
	static int _insertBatchSize = 500;

	/**
	 * Array of all primary keys
	 */
	static List<String> _primaryKeys;

	/**
	 * string name of the primary key column
	 */
	static String _primaryKey;

	/**
	 * true if primary key is an auto-increment column
	 */
	static bool _isAutoIncrement = false;

	/**
	 * array of all fully-qualified(table.column) columns
	 */
	static List<String> _columns;

	/**
	 * array of all column names
	 */
	static List<String> _columnNames;

	/**
	 * array of all column types
	 */
	static Map<String, String> _columnTypes;

	/**
	 * Array to contain names of modified columns
	 */
	List<String> _modifiedColumns = new List<String>();

	/**
	 * Whether or not to cache results in the internal object cache
	 */
	bool _cacheResults = true;

	/**
	 * Whether or not this is a new object
	 */
	bool _isNew = true;

	/**
	 * Wether or not the object is out of sync with the databse
	 */
	bool _isDirty = false;

	/**
	 * Errors from the validate() step of saving
	 */
	List<String> _validationErrors = new List<String>();

	String toString();

	static Object create() {
		throw new UnimplementedError('Create() not implemented yet');
	}

	/**
	 * Whether passed type is a temporal (date/time/timestamp) type.
	 */
	static bool isTemporalType(String typ) {
		return Model.temporalTypes.contains(typ);
	}

	static bool isNumericType(String typ) {
		return Model.numericTypes.contains(typ);
	}

	static bool isIntegerType(String typ) {
		return Model.integerTypes.contains(typ);
	}

	static bool isLobType(String typ) {
		return Model.lobTypes.contains(typ);
	}

	static String getTableName() {
		return _tableName;
	}

	static List<String> getColumnNames() {
		return _columnNames;
	}

	static List<String> getColumns() {
		return _columns;
	}

	static Map<String, String> getColumnTypes() {
		return _columnTypes;
	}

	static String getColumnType(String col_name) {
		return _columnTypes[normalizeColumnName(col_name)];
	}

	static List<String> _lowerCaseColumns = new List<String>();

	static bool hasColumn(String col_name) {
		throw new UnimplementedError('hasColumn() not implemented yet');
	}

	static String normalizeColumnName(String col_name) {
		int split = 0;
		if(col_name.contains('.')){
			split = col_name.indexOf('.') + 1;
		}
		return col_name.substring(split);
	}

	static String getPrimaryKey() {
		return _primaryKey;
	}

	static List<String> getPrimaryKeys() {
		return _primaryKeys;
	}

	static bool isAutoIncrement() {
		return _isAutoIncrement;
	}

	static Object coerceTemporalValue(Object value, String columnType, [DABLDDO conn = null]) {
		if(null == conn) {
			conn = getConnection();
		}

		if(value is List){
			return value.map((f) => coerceTemporalValue(f, columnType, conn)).toList();
		}

		if(!(value is int)) {
			value = DateTime.parse(value).millisecondsSinceEpoch;
		}

		String format;
		switch(columnType) {
			case Model.COLUMN_TYPE_TIMESTAMP:
				format = conn.getTimestampFormatter();
				break;
			case Model.COLUMN_TYPE_DATE:
				format = conn.getDateFormatter();
				break;
			case Model.COLUMN_TYPE_TIME:
				format = conn.getTimeFormatter();
				break;
			case Model.COLUMN_TYPE_INTEGER_TIMESTAMP:
				return value;
		}
		DateFormat formatter = new DateFormat(format);
		return formatter.format(new DateTime.fromMillisecondsSinceEpoch(value));
	}

	static Object retrieveByColumn(String field, Object value) {
		if(field == _primaryKey) {
			return retrieveByPK(value);
		}

		Query q = getQuery().add(field, value).setLimit(1);
		if(_primaryKey != null){
			q.orderBy(_primaryKey);
		}

		return doSelectOne(q);
	}

	static Query getQuery([Map<String, Object> params = null, Query q = null]) {
		q = q != null ? q : new Query();

		if(q.getTable() == null) {
			q.setTable(getTableName());
		}

		params.forEach((k, param) {
			if(hasColumn(k)) {
				q.add(k, param);
			}
		});

		if(params.containsKey('order_by') && hasColumn(params['order_by'])) {
			q.orderBy(params['order_by'],
				params.containsKey('dir') && params['dir'] == Query.DESC ? Query.DESC : Query.ASC);
		}

		if(params.containsKey('limit')){
			q.setLimit(params['limit']);
		}
		return q;
	}

	static void insertIntoPool(Model object) {
		if(!_poolEnabled ||
			_instancePoolCount >= Model.MAX_INSTANCE_POOL_SIZE ||
			_primaryKeys.isEmpty) {
			return;
		}

		String key = object.getPrimaryKeyValues().join('-');
		if(key == null || key.isEmpty){
			return;
		}

		if(!_instancePool.containsKey(key)){
			++_instancePoolCount;
		}

		_instancePool[key] = object;
	}

	static Model retrieveFromPool(Object key) {
		if(!_poolEnabled || null == key) {
			return null;
		}

		String skey = key.toString();
		if(_instancePool.containsKey(skey)){
			return _instancePool[key];
		}
		return null;
	}

	static void removeFromPool(Object obj_or_pk) {
		String skey;
		if(obj_or_pk is Model) {
			skey = obj_or_pk.getPrimaryKeyValues().join('-');
		} else {
			skey = obj_or_pk.toString();
		}
		if(_instancePool.containsKey(skey)){
			--_instancePoolCount;
			_instancePool.remove(skey);
		}
	}

	static void flushPool() {
		_instancePool = new Map<String, Model>();
		_instancePoolCount = 0;
	}

	static void setPoolEnabled([bool enable = true]) {
		_poolEnabled = enable;
	}

	static bool getPoolEnabled() {
		return _poolEnabled;
	}

	static List<Model> getAll([String extra = null]) {
		throw new UnimplementedError('Use doSelect instead');
	}

	static Future<int> doCount([Query q = null]){
		q = q != null ? q : getQuery();
		if(q.getTable() == null) {
			q.setTable(getTableName());
		}
		return q.doCount(getConnection());
	}

	static Future<List<Model>> doSelect([Query q = null, List<String> additional_classes = null]){
		String modelname = '';
		if(additional_classes == null) {
			additional_classes = new List<String>();
		}

		additional_classes.insert(0, modelname);
		return fromResult(doSelectRS(q), additional_classes);
	}

	static Future<Model> doSelectOne([Query q= null, List<String> additional_classes = null]) {
		q = q != null ? q : getQuery();
		q.setLimit(1);
		Completer c = new Completer();
		doSelect(q, additional_classes).then((List<Model> objs) {
			c.complete(objs.first);
		});
		return c.future;
	}

	static Future<DDOStatement> doSelectRS([Query q = null]) {
		q = q != null ? q : getQuery();
		if(q.getTable() == null) {
			q.setTable(getTableName());
		}
		return q.doSelect(getConnection());
	}

	static Object doSelectIterator([Query q = null]) {
		throw new UnimplementedError();
	}

	static Future<List<Model>> fromResult(Future<DDOStatement> result, [List<String> classes = null, bool use_pool = null]) {
		throw new UnsupportedError('fromResult needs to be overridden in the child class');
	}

	bool fromNumericResultArray(List values, int startCol);

	bool fromAssociativeResultArray(Map<String, Object> values);

	static int doDelete(Query q, [bool flushPool = true]) {
		throw new UnsupportedError('doDelete needs to be overridden in the child class');
	}

	static List<Model> doUpdate(List values, [Query q = null]) {
		throw new UnsupportedError('doUpdate needs to be overridden in the child class');
	}

	static int setInsertBatchSize([int size = 500]){
		throw new UnsupportedError('setInsertBatchSize needs to be overridden in the child class');
	}

	static int insertBatch() {
		throw new UnsupportedError('insertBatch needs to be overridden in the child class');
	}

	Model queueForInsert();

	Model copy();

	bool isModified() => _modifiedColumns.isNotEmpty;

	bool isColumnModified(String columnName);

	List<String> getModifiedColumns() => _modifiedColumns;

	Model setColumnValue(String columnName, Object value, [String columnType = null]);

	Model resetModified();

	Model fromArray(Map<String, Object> array);

	Map<String, Object> toArray();

	Map<String, Object> jsonSerialize();

	Model setCacheResults([bool value = true]);

	bool getCacheResults() => _cacheResults;

	bool hasPrimaryKeyValues();

	List<Object> getPrimaryKeyValues();

	bool validate();

	List<String> getValidationErrors() => _validationErrors;

	int delete();

	int save();

	int archive();

	bool isNew() => _isNew;

	Model setNew(bool isNew);

	bool isDirty() => _isDirty;

	Model setDirty(bool dirty);

	Model castInts();

	int _insert();

	int _update();

	Query _getForeignObjectsQuery(String foreignTable, String foreignColumn, String localColumn, [Query q = null]);

	static DABLDDO getConnection() {
		throw new UnsupportedError('getConnection needs to be overridden in child class');
	}

	static Model retrieveByPK(Object id) {
		throw new UnsupportedError('retrieveByPK needs to be overridden in child class');
	}
}