part of dabl;

class Model {

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
	static List<Model> _instancePool;

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
	static List<String> _columnTypes;

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

	String toString() {
		return "${this.runtimeType.toString()} ${getPrimaryKeyValues().join("-")}";
	}

	static Object create() {
		throw new UnimplementedError('Create() not implemented yet');
	}

	/**
	 * Whether passed type is a temporal (date/time/timestamp) type.
	 */
	static bool isTemporalType(String typ) {
		return Model.temporalTypes.contains(typ);
	}

	List<Object> getPrimaryKeyValues() {
		throw new UnimplementedError('getPrimaryKeyValues() not implemented yet');
	}

}