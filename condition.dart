part of dabl_query;

class Condition {
  /**
   * escape only the first parameter
   */
  static const int QUOTE_LEFT = 1;

  /**
   * escape only the second param
   */
  static const int QUOTE_RIGHT = 2;

  /**
   * escape both params
   */
  static const int QUOTE_BOTH = 3;

  /**
   * escape no params
   */
  static const int QUOTE_NONE = 4;

  static const String OR = 'OR';
  static const String AND = 'AND';

  List<List> _conds;

  Condition() {
    _conds = new List<List<String>>();
  }

  Condition add(left, [right, oper = Query.EQUAL, quote = Condition.QUOTE_LEFT]) {
    return this.addAnd(left, right, oper, quote);
  }

  Condition addAnd(left, [right, oper = Query.EQUAL, quote = Condition.QUOTE_LEFT]) {
    if(null == left) {
      return this;
    }

    if(left is Map) {
      left.forEach((k,v) => addAnd(k,v));
      return this;
    }
    List cond = new List();
    cond.add([Condition.AND, left, right, oper, quote]);
    _conds.add(cond);
    return this;
  }

  getAnds() {
    //TODO: implement
  }

  Condition addOr(left, [right, oper = Query.EQUAL, quote]) {
    if(null == left) {
      return this;
    }

    if(left is Map) {
      left.forEach((k,v) => addOr(k,v));
      return this;
    }

    _conds.add([Condition.OR, left, right, oper, quote]);
    return this;
  }

  getOrs() {
    //TODO: Implement
  }

  static QueryStatement _processCondition(left, [right = null, operator = Query.EQUAL, quote = null]){
    if(left is QueryStatement && !?right && !?operator && !?quote){
      return left;
    }

    QueryStatement statement = new QueryStatement();
    if(left is Condition) {
      var clause = left.getQueryStatement();
      if(null == clause) {
        return null;
      }
      clause.query_string = "(${clause.query_string})";
      return clause;
    }

    if(null == quote) {
      if(operator is num) {
        quote = operator;
        operator = Condition.QUOTE_RIGHT;
      } else {
        quote = Condition.QUOTE_RIGHT;
      }
    }

    if(Query.BEGINS_WITH == operator) {
      right = "${right}%";
      operator = Query.LIKE;
    } else if(Query.ENDS_WITH == operator){
      right = "%${right}";
      operator = Query.LIKE;
    } else if(Query.CONTAINS == operator) {
      right = "%${right}%";
      operator = Query.LIKE;
    }

    bool is_query = right is Query;
    bool is_array = false == is_query && right is List;

    if(is_array || is_query) {
      if(!is_query || 1 != right.getLimit()) {
        switch(operator) {
          case Query.IN:
            break;
          case Query.EQUAL:
            operator = Query.IN;
            break;
          case Query.BETWEEN:
            break;
          case Query.NOT_IN:
            break;
          case Query.NOT_EQUAL:
          case Query.ALT_NOT_EQUAL:
            operator = Query.NOT_IN;
            break;
          default:
            throw new Exception("${operator} unknnown for comparing an array.");
        }
      }

      if(is_query) {
        Query r = right as Query;
        if(null == r.getTable()) {
          throw new Exception("right does not have a table, so it cannot be nested");
        }
        QueryStatement clause = r.getQuery();
        if(null == clause) {
          return null;
        }

        right = "(${clause.query_string})";
        statement.addParams(clause.params);
        statement.addIdentifiers(clause.identifiers);
        if(Condition.QUOTE_LEFT != quote) {
          quote = Condition.QUOTE_NONE;
        }
      } else if(is_array){
        List r = right as List;
        int arrlength = r.length;

        if(2 == arrlength && Query.BETWEEN == operator){
          statement.query_string = "${left} ${operator} ${QueryStatement.PARAM} AND ${QueryStatement.PARAM}";
          statement.addParams(r);
          return statement;
        } else if(0 == arrlength){
          if(Query.IN == operator) {
            statement.query_string = "(0 = 1)";
            return statement;
          } else if(Query.NOT_IN == operator) {
            return null;
          }
        } else if (Condition.QUOTE_RIGHT == quote || Condition.QUOTE_BOTH == quote) {
          statement.addParams(r);
          StringBuffer sb = new StringBuffer();
          sb.write("(");
          for(var x = 0; x < arrlength; ++x){
            if(0 < x){
              sb.write(",");
            }
            sb.write(QueryStatement.PARAM);
          }
          sb.write(")");
          right = sb.toString();
        }
      }
    } else {
      if(null == right) {
        if(Query.NOT_EQUAL == operator || Query.ALT_NOT_EQUAL == operator) {
          operator = Query.IS_NOT_NULL;
        } else if(Query.EQUAL == operator) {
          operator = Query.IS_NULL;
        }
      }

      if(Query.IS_NULL == operator || Query.IS_NOT_NULL == operator){
        right = null;
      } else if(Condition.QUOTE_RIGHT == quote || Condition.QUOTE_BOTH == quote) {
        statement.addParam(right);
        right = QueryStatement.PARAM;
      }
    }
    statement.query_string = "${left} ${operator} ${right}";
    return statement;
  }

  QueryStatement getQueryStatement([conn]) {
    if(0 == _conds.length) {
      return null;
    }
    int count = 0;
    StringBuffer sb = new StringBuffer();
    QueryStatement statement = new QueryStatement(conn);
    for(final List<String> cond in this._conds) {
      if(null == cond) {
        continue;
      }
      sb.write("\n\t");
      //If this is not the first condition, insert the separator
      if(0 != count) {
        // sb.write((1 == count && _conds.first().sep == 'OR') )
      }
    }
  }

}
