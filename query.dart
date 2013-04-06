library dabl_query;
part 'condition.dart';
part 'query_statement.dart';
class Query {
  static const String ACTION_COUNT = 'COUNT';
  static const String ACTION_DELETE = 'DELETE';
  static const String ACTION_SELECT = 'SELECT';
  static const String ACTION_UPDATE = 'UPDATE';

  // Comparison types
  static const String EQUAL = '=';
  static const String NOT_EQUAL = '<>';
  static const String ALT_NOT_EQUAL = '!=';
  static const String GREATER_THAN = '>';
  static const String LESS_THAN = '<';
  static const String GREATER_EQUAL = '>=';
  static const String LESS_EQUAL = '<=';
  static const String LIKE = 'LIKE';
  static const String BEGINS_WITH = 'BEGINS_WITH';
  static const String ENDS_WITH = 'ENDS_WITH';
  static const String CONTAINS = 'CONTAINS';
  static const String NOT_LIKE = 'NOT LIKE';
  static const String CUSTOM = 'CUSTOM';
  static const String DISTINCT = 'DISTINCT';
  static const String IN = 'IN';
  static const String NOT_IN = 'NOT IN';
  static const String ALL = 'ALL';
  static const String IS_NULL = 'IS NULL';
  static const String IS_NOT_NULL = 'IS NOT NULL';
  static const String BETWEEN = 'BETWEEN';

// Comparison type for update
  static const String CUSTOM_EQUAL = 'CUSTOM_EQUAL';

  // PostgreSQL comparison types
  static const String ILIKE = 'ILIKE';
  static const String NOT_ILIKE = 'NOT ILIKE';

  // JOIN TYPES
  static const String JOIN = 'JOIN';
  static const String LEFT_JOIN = 'LEFT JOIN';
  static const String RIGHT_JOIN = 'RIGHT JOIN';
  static const String INNER_JOIN = 'INNER JOIN';
  static const String OUTER_JOIN = 'OUTER JOIN';

  // Binary AND
  static const String BINARY_AND = '&';

  // Binary OR
  static const String BINARY_OR = '|';

  // 'Order by' qualifiers
  static const String ASC = 'ASC';
  static const String DESC = 'DESC';

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
