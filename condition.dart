


class Condition {
  /**
   * escape only the first parameter
   */
  static final int QUOTE_LEFT = 1;

  /**
   * escape only the second param
   */
  static final int QUOTE_RIGHT = 2;

  /**
   * escape both params
   */
  static final int QUOTE_BOTH = 3;

  /**
   * escape no params
   */
  static final int QUOTE_NONE = 4;

  static final String OR = 'OR';
  static final String AND = 'AND';

  List<List> _conds;

  Condition() {
    _conds = new List<List<String>>();
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
    cond.addAll([Condition.AND, left, right, oper, quote]);
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

  String getQueryStatement([conn]) {
    if(1 > _conds.length) {
      return null;
    }
    StringBuffer result = new StringBuffer();
    for(final cond in _conds) {
      result.add('${cond[1]} = ${cond[2]}');
    }
    return result.toString();
  }

}
