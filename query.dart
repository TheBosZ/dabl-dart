#library('dabl-query');
#source('condition.dart');
#source('query_statement.dart');
class Query {
  static final String ACTION_COUNT = 'COUNT';
  static final String ACTION_DELETE = 'DELETE';
  static final String ACTION_SELECT = 'SELECT';
  static final String ACTION_UPDATE = 'UPDATE';

  // Comparison types
  static final String EQUAL = '=';
  static final String NOT_EQUAL = '<>';
  static final String ALT_NOT_EQUAL = '!=';
  static final String GREATER_THAN = '>';
  static final String LESS_THAN = '<';
  static final String GREATER_EQUAL = '>=';
  static final String LESS_EQUAL = '<=';
  static final String LIKE = 'LIKE';
  static final String BEGINS_WITH = 'BEGINS_WITH';
  static final String ENDS_WITH = 'ENDS_WITH';
  static final String CONTAINS = 'CONTAINS';
  static final String NOT_LIKE = 'NOT LIKE';
  static final String CUSTOM = 'CUSTOM';
  static final String DISTINCT = 'DISTINCT';
  static final String IN = 'IN';
  static final String NOT_IN = 'NOT IN';
  static final String ALL = 'ALL';
  static final String IS_NULL = 'IS NULL';
  static final String IS_NOT_NULL = 'IS NOT NULL';
  static final String BETWEEN = 'BETWEEN';

// Comparison type for update
  static final String CUSTOM_EQUAL = 'CUSTOM_EQUAL';

  // PostgreSQL comparison types
  static final String ILIKE = 'ILIKE';
  static final String NOT_ILIKE = 'NOT ILIKE';

  // JOIN TYPES
  static final String JOIN = 'JOIN';
  static final String LEFT_JOIN = 'LEFT JOIN';
  static final String RIGHT_JOIN = 'RIGHT JOIN';
  static final String INNER_JOIN = 'INNER JOIN';
  static final String OUTER_JOIN = 'OUTER JOIN';

  // Binary AND
  static final String BINARY_AND = '&';

  // Binary OR
  static final String BINARY_OR = '|';

  // 'Order by' qualifiers
  static final String ASC = 'ASC';
  static final String DESC = 'DESC';

  String action;
  String table;
  bool distinct;
  List<String> columns;
  List<String> groups;

  //Private members

  List<String> _joins;
  List<String> _orders;
  Condition _where;
  String _tableAlias;

  Query() {
    _where = new Condition();
  }

  Query addColumn(String column_name, [String alias]) {
    if(alias != null) {
      column_name = '$column_name AS "$alias"';
    }
    columns.add(column_name);
    return this;
  }

  Query addJoin(){
    //TODO: Fill in functionality
    return this;
  }

  Query addAnd(String column, [value, oper = Query.EQUAL, quote = Condition.QUOTE_LEFT]){
    _where.addAnd(column, value, oper, quote);
    return this;
  }

  String getWhereClause() {
    return _where.getQueryStatement();
  }

}
