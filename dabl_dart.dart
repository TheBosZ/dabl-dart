import "query.dart";
void main() {
  Query q = new Query();
  //q.setAction(Query.ACTION_SELECT);
  q.addAnd('nathan', 2);
  q.addAnd('bob', 'fred');
  print(q.toString());
}