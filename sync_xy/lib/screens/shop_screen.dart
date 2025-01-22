import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_xy/providers/app_state_provider.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  void _showATMDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            padding: const EdgeInsets.all(20),
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ATM', style: TextStyle(fontSize: 18)),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.amber),
                          const SizedBox(width: 5),
                          Consumer<AppStateProvider>(
                            builder: (context, appState, child) {
                              return Text('${appState.coins}');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Status'),
                      Tab(text: 'Action'),
                      Tab(text: 'Upgrade'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildStatusTab(context),
                        _buildActionTab(context),
                        _buildUpgradeTab(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusTab(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusRow('Account Balance', appState.accountBalance, Icons.account_balance),
        _buildStatusRow('Current Credit Interest', appState.creditInterest, Icons.percent),
        _buildStatusRow('Line of Credit', appState.lineOfCredit, Icons.credit_card),
        _buildStatusRow('Credit Taken', appState.creditTaken, Icons.money_off),
        _buildStatusRow('Deposit Interest', appState.depositInterestUpgradeCost, Icons.savings),
      ],
    );
  }

  Widget _buildStatusRow(String label, int value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text('$label: $value'),
        ],
      ),
    );
  }

  Widget _buildActionTab(BuildContext context) {
    final TextEditingController depositController = TextEditingController();
    final TextEditingController creditController = TextEditingController();
    final TextEditingController withdrawController = TextEditingController();
    return Column(
      children: [
        _buildActionRow('Deposit', depositController, Icons.account_balance_wallet, () {
          final amount = int.tryParse(depositController.text) ?? 0;
          if (amount > 0) {
            _showConfirmDialog(context, 'Confirm Deposit', 'Are you sure you want to deposit $amount coins?', () {
              Provider.of<AppStateProvider>(context, listen: false).deposit(amount);
            });
          }
        }),
        _buildActionRow('Take Credit', creditController, Icons.money, () {
          final amount = int.tryParse(creditController.text) ?? 0;
          if (amount > 0) {
            _showConfirmDialog(context, 'Confirm Credit', 'Are you sure you want to take $amount coins as credit?', () {
              Provider.of<AppStateProvider>(context, listen: false).takeCredit(amount);
            });
          }
        }),
        _buildActionRow('Withdraw', withdrawController, Icons.money_off, () {
          final amount = int.tryParse(withdrawController.text) ?? 0;
          if (amount > 0) {
            _showConfirmDialog(context, 'Confirm Withdraw', 'Are you sure you want to withdraw $amount coins?', () {
              Provider.of<AppStateProvider>(context, listen: false).withdraw(amount);
            });
          }
        }),
      ],
    );
  }

  Widget _buildActionRow(String label, TextEditingController controller, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onPressed,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeTab(BuildContext context) {
    return Column(
      children: [
        _buildUpgradeRow('Increase Line of Credit', Icons.trending_up, () {
          _showConfirmDialog(context, 'Confirm Upgrade', 'Are you sure you want to increase the line of credit?', () {
            Provider.of<AppStateProvider>(context, listen: false).increaseLineOfCredit();
          });
        }),
        _buildUpgradeRow('Decrease Credit Interest', Icons.trending_down, () {
          _showConfirmDialog(context, 'Confirm Upgrade', 'Are you sure you want to decrease the credit interest?', () {
            Provider.of<AppStateProvider>(context, listen: false).decreaseCreditInterest();
          });
        }),
        _buildUpgradeRow('Increase Deposit Interest', Icons.savings, () {
          _showConfirmDialog(context, 'Confirm Upgrade', 'Are you sure you want to increase the deposit interest?', () {
            Provider.of<AppStateProvider>(context, listen: false).increaseDepositInterest();
          });
        }),
      ],
    );
  }

  Widget _buildUpgradeRow(String label, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          ElevatedButton(
            onPressed: onPressed,
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topCenter,
          child: ElevatedButton.icon(
            onPressed: () => _showATMDialog(context),
            icon: const Icon(Icons.account_balance),
            label: const Text('Open ATM'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
            ),
          ),
        ),
      ),
    );
  }
}