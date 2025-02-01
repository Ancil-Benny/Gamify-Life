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
            height: MediaQuery.of(context).size.height * 0.5, // Half the screen height
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusRow('Account Balance', '${appState.accountBalance}', Icons.account_balance),
          _buildStatusRow('Current Credit Interest', '${appState.creditInterest}%', Icons.percent),
          _buildStatusRow('Line of Credit', '${appState.lineOfCredit}', Icons.credit_card),
          _buildStatusRow('Credit Taken', '${appState.creditTaken}', Icons.money_off),
          _buildStatusRow('Deposit Interest', '${appState.depositInterest}%', Icons.savings),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon) {
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
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildActionRow(
            context,
            'Deposit',
            depositController,
            Icons.account_balance_wallet,
            () {
              final amount = int.tryParse(depositController.text) ?? 0;
              final appState = Provider.of<AppStateProvider>(context, listen: false);
              if (amount > 0 && amount <= appState.coins) {
                _showConfirmDialog(
                  context,
                  'Confirm Deposit',
                  'Are you sure you want to deposit $amount coins?',
                  () {
                    appState.deposit(amount);
                    _showSuccessSnackBar(context, 'Deposit Successful', Icons.check_circle, Colors.green);
                  },
                );
              } else {
                _showErrorSnackBar(context, 'Insufficient coins to deposit', Icons.error, Colors.red);
              }
            },
          ),
          _buildActionRow(
            context,
            'Take Credit',
            creditController,
            Icons.money,
            () {
              final amount = int.tryParse(creditController.text) ?? 0;
              final appState = Provider.of<AppStateProvider>(context, listen: false);
              if (amount > 0 && amount <= (appState.lineOfCredit - appState.creditTaken)) {
                _showConfirmDialog(
                  context,
                  'Confirm Credit',
                  'Are you sure you want to take $amount coins as credit?',
                  () {
                    appState.takeCredit(amount);
                    _showSuccessSnackBar(context, 'Credit Taken Successfully', Icons.check_circle, Colors.green);
                  },
                );
              } else {
                _showErrorSnackBar(context, 'Cannot take more credit than available', Icons.error, Colors.red);
              }
            },
          ),
          _buildActionRow(
            context,
            'Withdraw',
            withdrawController,
            Icons.money_off,
            () {
              final amount = int.tryParse(withdrawController.text) ?? 0;
              final appState = Provider.of<AppStateProvider>(context, listen: false);
              if (amount > 0 && amount <= appState.accountBalance) {
                _showConfirmDialog(
                  context,
                  'Confirm Withdraw',
                  'Are you sure you want to withdraw $amount coins?',
                  () {
                    appState.withdraw(amount);
                    _showSuccessSnackBar(context, 'Withdrawal Successful', Icons.check_circle, Colors.green);
                  },
                );
              } else {
                _showErrorSnackBar(context, 'Insufficient account balance to withdraw', Icons.error, Colors.red);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
    VoidCallback onPressed,
  ) {
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
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildUpgradeRow(
            context,
            'Increase Line of Credit',
            Icons.trending_up,
            'Increase by 100',
            () {
              if (appState.coins >= appState.lineOfCreditUpgradeCost) {
                _showConfirmDialog(
                  context,
                  'Confirm Upgrade',
                  'Upgrade costs ${appState.lineOfCreditUpgradeCost} coins. Increase line of credit by 100?',
                  () {
                    appState.increaseLineOfCredit();
                    _showSuccessSnackBar(context, 'Line of Credit Increased', Icons.check_circle, Colors.green);
                  },
                );
              } else {
                _showErrorSnackBar(context, 'Insufficient coins for upgrade', Icons.error, Colors.red);
              }
            },
          ),
          _buildUpgradeRow(
            context,
            'Decrease Credit Interest',
            Icons.trending_down,
            'Decrease by 5%',
            () {
              if (appState.coins >= appState.creditInterestUpgradeCost && appState.creditInterest > 5) {
                _showConfirmDialog(
                  context,
                  'Confirm Upgrade',
                  'Upgrade costs ${appState.creditInterestUpgradeCost} coins. Decrease credit interest by 5%?',
                  () {
                    appState.decreaseCreditInterest();
                    _showSuccessSnackBar(context, 'Credit Interest Decreased', Icons.check_circle, Colors.green);
                  },
                );
              } else {
                _showErrorSnackBar(context, 'Cannot decrease credit interest further or insufficient coins', Icons.error, Colors.red);
              }
            },
          ),
          _buildUpgradeRow(
            context,
            'Increase Deposit Interest',
            Icons.savings,
            'Increase by 1%',
            () {
              if (appState.coins >= appState.depositInterestUpgradeCost && appState.depositInterest < 100) {
                _showConfirmDialog(
                  context,
                  'Confirm Upgrade',
                  'Upgrade costs ${appState.depositInterestUpgradeCost} coins. Increase deposit interest by 1%?',
                  () {
                    appState.increaseDepositInterest();
                    _showSuccessSnackBar(context, 'Deposit Interest Increased', Icons.check_circle, Colors.green);
                  },
                );
              } else {
                _showErrorSnackBar(context, 'Cannot increase deposit interest further or insufficient coins', Icons.error, Colors.red);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeRow(
    BuildContext context,
    String label,
    IconData icon,
    String description,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text('$label ($description)')),
          ElevatedButton(
            onPressed: onPressed,
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  // New Method: Show Rewards Creation/Edit Dialog
  void _showCreateOrEditRewardDialog(BuildContext context, {int? index}) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController costController = TextEditingController();

    // If editing, pre-fill the fields
    if (index != null) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final reward = appState.rewards[index];
      titleController.text = reward.title;
      costController.text = reward.cost.toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == null ? 'Create Reward' : 'Edit Reward'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Title Field
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // Cost Field
                TextField(
                  controller: costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cost',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String title = titleController.text.trim();
                final int? cost = int.tryParse(costController.text.trim());

                if (title.isNotEmpty && cost != null && cost > 0) {
                  final appState = Provider.of<AppStateProvider>(context, listen: false);
                  if (index == null) {
                    // Create new reward with empty description
                    appState.addReward(title, '', cost);
                    _showSuccessSnackBar(context, 'Reward Created Successfully', Icons.check_circle, Colors.green);
                  } else {
                    // Update existing reward
                    appState.updateReward(index, title, '', cost);
                    _showSuccessSnackBar(context, 'Reward Updated Successfully', Icons.check_circle, Colors.green);
                  }
                  Navigator.of(context).pop();
                } else {
                  _showErrorSnackBar(context, 'Please fill all fields correctly.', Icons.error, Colors.red);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // New Method: Show Rewards List
  Widget _buildRewardsSection(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Rewards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            appState.rewards.isEmpty
                ? const Text('No rewards available.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appState.rewards.length,
                    itemBuilder: (context, index) {
                      final reward = appState.rewards[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.redeem, color: Colors.purple),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(reward.title),
                              Row(
                                children: [
                                  const Icon(Icons.monetization_on, color: Colors.amber),
                                  const SizedBox(width: 5),
                                  Text('${reward.cost}'),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey), // Set edit icon color to grey
                                onPressed: () {
                                  _showCreateOrEditRewardDialog(context, index: index);
                                },
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final appState = Provider.of<AppStateProvider>(context, listen: false);
                                  if (appState.coins >= reward.cost) {
                                    _showConfirmDialog(
                                      context,
                                      'Confirm Purchase',
                                      'Do you want to buy "${reward.title}" for ${reward.cost} coins?',
                                      () {
                                        appState.buyReward(index);
                                        _showSuccessSnackBar(context, 'Purchase Successful', Icons.check_circle, Colors.green);
                                      },
                                    );
                                  } else {
                                    _showErrorSnackBar(context, 'Insufficient coins to purchase this reward.', Icons.error, Colors.red);
                                  }
                                },
                                child: const Text('Buy'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        );
      },
    );
  }

  void _showConfirmDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content, style: const TextStyle(color: Colors.black)), // Set text color to black
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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

  void _showSuccessSnackBar(BuildContext context, String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView( // Added to make content scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Open ATM Section
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showATMDialog(context),
                      icon: const Icon(Icons.account_balance),
                      label: const Text('Open ATM'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(MediaQuery.of(context).size.width, 50), // Full width button
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Rewards Section
              _buildRewardsSection(context),
              // Add other ShopScreen content here
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateOrEditRewardDialog(context); // Open Rewards Creation Dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}