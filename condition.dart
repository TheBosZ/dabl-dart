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

  Condition([left = null, right = null, oper = Query.EQUAL, quote = Condition.QUOTE_LEFT]) {
    _conds = new List<List<String>>();
    if(null != left) {
      this.add(left, right, oper, quote);
    }
  }

  static Condition create([left = null, right = null, oper = Query.EQUAL, quote = Condition.QUOTE_LEFT]) {
    return new Condition(left, right, oper, quote);
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
      clause.setString("(${clause.getString()})");
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

        right = "(${clause.getString()})";
        statement.addParams(clause.getParams());
        statement.addIdentifiers(clause.getIdentifiers());
        if(Condition.QUOTE_LEFT != quote) {
          quote = Condition.QUOTE_NONE;
        }
      } else if(is_array){
        List r = right as List;
        int arrlength = r.length;

        if(2 == arrlength && Query.BETWEEN == operator){
          statement.setString("${left} ${operator} ${QueryStatement.PARAM} AND ${QueryStatement.PARAM}");
          statement.addParams(r);
          return statement;
        } else if(0 == arrlength){
          if(Query.IN == operator) {
            statement.setString("(0 = 1)");
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
    statement.setString("${left} ${operator} ${right}");
    return statement;
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
    _conds.add([Condition.AND, left, right, oper, quote]);
    return this;
  }

  List<QueryStatement> getAnds() {
    List<QueryStatement> ands = new List<QueryStatement>();
    for(List cond in _conds) {
      if(Condition.AND == cond[0]) {
        ands.add(Condition._processCondition(cond[1], cond[2], cond[3], cond[4]));
      }
    }
    return ands;
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

  List<QueryStatement>getOrs() {
    List<QueryStatement> ors = new List<QueryStatement>();
    for(List cond in _conds) {
      if(Condition.OR == cond[0]) {
        ors.add(Condition._processCondition(cond[1], cond[2], cond[3], cond[4]));
      }
    }
    return ors;
  }

  Condition andNot(column, value) {
    return this.addAnd(column, value, Query.NOT_EQUAL);
  }

  Condition andLike(column, value){
    return this.addAnd(column, value, Query.LIKE);
  }

  Condition andNotLike(column, value) {
    return this.addAnd(column, value, Query.NOT_LIKE);
  }

  Condition andGreater(column, value) {
    return this.addAnd(column, value, Query.GREATER_THAN);
  }

  Condition andGreaterEqual(column, value) {
    return this.addAnd(column, value, Query.GREATER_EQUAL);
  }

  Condition andLess(column, value) {
    return this.addAnd(column, value, Query.LESS_THAN);
  }

  Condition andLessEqual(column, value) {
    return this.addAnd(column, value, Query.LESS_EQUAL);
  }

  Condition andNull(column) {
    return this.addAnd(column, null);
  }

  Condition andNotNull(column) {
    return this.addAnd(column, null, Query.NOT_EQUAL);
  }

  Condition andBetween(column, from, to) {
    return this.addAnd(column, [from, to], Query.BETWEEN);
  }

  Condition andBeginsWith(column, value) {
    return this.addAnd(column, value, Query.BEGINS_WITH);
  }

  Condition andEndsWith(column, value) {
    return this.addAnd(column, value, Query.ENDS_WITH);
  }

  Condition andContains(column, value) {
    return this.addAnd(column, value, Query.CONTAINS);
  }

  Condition orNot(column, value) {
    return this.addOr(column, value, Query.NOT_EQUAL);
  }

  Condition orLike(column, value) {
    return this.addOr(column, value, Query.LIKE);
  }

  Condition orNotLike(column, value) {
    return this.addOr(column, value, Query.NOT_LIKE);
  }

  Condition orGreater(column, value) {
    return this.addOr(column, value, Query.GREATER_THAN);
  }

  Condition orGreaterEqual(column, value) {
    return this.addOr(column, value, Query.GREATER_EQUAL);
  }

  Condition orLess(column, value) {
    return this.addOr(column, value, Query.LESS_THAN);
  }

  Condition orLessEqual(column, value) {
    return this.addOr(column, value, Query.LESS_EQUAL);
  }

  Condition orNull(column) {
    return this.addOr(column, null);
  }

  Condition orNotNull(column) {
    return this.addOr(column, null, Query.NOT_EQUAL);
  }

  Condition orBetween(column, $from, $to) {
    return this.addOr(column, [$from, $to], Query.BETWEEN);
  }

  Condition orBeginsWith(column, value) {
    return this.addOr(column, value, Query.BEGINS_WITH);
  }

  Condition orEndsWith(column, value) {
    return this.addOr(column, value, Query.ENDS_WITH);
  }

  Condition orContains(column, value) {
    return this.addOr(column, value, Query.CONTAINS);
  }

  QueryStatement getQueryStatement([conn]) {
    if(0 == _conds.length) {
      return null;
    }

    int count = 0;
    StringBuffer sb = new StringBuffer();
    QueryStatement statement = new QueryStatement(conn), temp;
    bool is_first = true, is_second = false;

    for(final List<String> cond in this._conds) {
      temp = Condition._processCondition(cond[1], cond[2], cond[3], cond[4]);
      if(null == temp) {
        continue;
      }
      sb.write("\n\t");
      if(is_first) {
        is_first = false;
        is_second = true;
      } else {
       if(is_second) {
         if(Condition.OR == _conds[0][0]){
           sb.write(Condition.OR);
         }
         is_second = false;
       } else {
         sb.write(cond[0]);
       }
      }
      sb.write(temp.getString());
      statement.addParams(temp.getParams());
      statement.addIdentifiers(temp.getIdentifiers());
    }
    statement.setString(sb.toString());
    return statement;
  }

  String toString() {
    return getQueryStatement().toString();
  }
}
