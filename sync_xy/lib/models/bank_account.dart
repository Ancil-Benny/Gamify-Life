class BankAccount {
  int accountBalance;
  int lineOfCredit;
  int creditTaken;
  double creditInterest;
  double depositInterest;

  BankAccount({
    this.accountBalance = 0,
    this.lineOfCredit = 50,
    this.creditTaken = 0,
    this.creditInterest = 90.0,
    this.depositInterest = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'accountBalance': accountBalance,
        'lineOfCredit': lineOfCredit,
        'creditTaken': creditTaken,
        'creditInterest': creditInterest,
        'depositInterest': depositInterest,
      };

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
        accountBalance: json['accountBalance'] ?? 0,
        lineOfCredit: json['lineOfCredit'] ?? 50,
        creditTaken: json['creditTaken'] ?? 0,
        creditInterest: (json['creditInterest'] as num?)?.toDouble() ?? 90.0,
        depositInterest: (json['depositInterest'] as num?)?.toDouble() ?? 0.0,
      );
}