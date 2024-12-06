class Currency {
  int balance;

  Currency({required this.balance});

  void add(int amount) {
    balance += amount;
  }

  void subtract(int amount) {
    balance -= amount;
  }
}
