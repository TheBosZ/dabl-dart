import "query.dart";
void main() {
  Query q = new Query();
  q.addAnd('nathan', 2);
  q.addAnd('bob', 'fred');
  print(q.getWhereClause());
}