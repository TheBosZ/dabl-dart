part of dabl;

class DBWebSQL extends DABLDDO {
	DBWebSQL(Driver driver): super(driver);

	@override
	String applyLimit(String sql, int offset, int limit) {
		if (limit >0) {
			sql = "${sql} LIMIT ${limit} ${offset > 0 ? ' OFFSET' : ''}";
		} else if (offset > 0) {
			sql = "${sql} LIMIT -1 OFFSET ${offset}";
		}
		return sql;
	}

	@override
	String concatString(String s1, String s2) {
		return "(${s1} || ${s2})";
	}

	@override
	String ignoreCase(String s) {
		return toUpperCase(s);
	}

	@override
	String random([int seed = null]) {
		return 'random()';
	}

	@override
	String strLength(String s) {
		return "length(${s})";
	}

	@override
	String subString(String s, int pos, int len) {
		return "substr(${s}, ${pos}, ${len})";
	}

	@override
	String toUpperCase(String i) {
		return "UPPER(${i})";
	}

	@override
	bool useQuoteIdentifier() {
		return true;
	}
}
