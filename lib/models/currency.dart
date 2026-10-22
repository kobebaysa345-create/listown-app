enum Cur {
  usd('\$', 'USD'),
  php('₱', 'PHP');

  final String sym;
  final String code;

  const Cur(this.sym, this.code);

  Cur get other => this == Cur.usd ? Cur.php : Cur.usd;
}
