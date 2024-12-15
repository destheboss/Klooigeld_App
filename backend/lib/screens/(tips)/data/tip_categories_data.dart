// data/tip_categories_data.dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/tip.dart';
import '../models/tip_category.dart';
import '/theme/app_theme.dart';

List<TipCategory> initialTipCategories = [
  TipCategory(
    index: 0,
    title: 'PAY LATER',
    icon: FontAwesomeIcons.clock,
    progress: 0.0,
    backgroundColor: AppTheme.klooigeldRoze,
    tips: [
        Tip(title: 'Understand the Terms', description: 'Always read the terms and conditions before choosing "Pay Later".'),
        Tip(title: 'Avoid Accumulating Debt', description: 'Use "Pay After" sparingly and ensure you can pay on time.'),
        Tip(title: 'Keep Track of Deadlines', description: 'Set reminders to avoid late fees or penalties.'),
        Tip(title: 'Interest Rates', description: 'Check if interest is applied after a period; pay before the deadline to avoid extra costs.'),
        Tip(title: 'Alternatives', description: 'Consider paying upfront to avoid forgetting or overspending.'),
    ],
  ),
  TipCategory(
    index: 1,
    title: 'INSURANCES',
    icon: FontAwesomeIcons.shieldHalved,
    progress: 0.0,
    backgroundColor: AppTheme.klooigeldGroen,
    tips: [
        Tip(title: 'Compare Policies', description: 'Shop around and compare multiple providers for best coverage.'),
        Tip(title: 'Assess Your Needs', description: 'Choose policies that align with your insurance requirements.'),
        Tip(title: 'Understand Coverage', description: 'Know what is included and excluded to avoid surprises.'),
        Tip(title: 'Bundle Policies', description: 'Some companies offer discounts when bundling multiple insurances.'),
        Tip(title: 'Emergency Fund', description: 'Keep funds for situations not covered by insurance.'),
    ],
  ),
  TipCategory(
    index: 2,
    title: 'GAMBLING',
    icon: FontAwesomeIcons.coins,
    progress: 0.0,
    backgroundColor: AppTheme.klooigeldPaars,
    tips: [
        Tip(title: 'Set a Budget', description: 'Only gamble with money you can afford to lose.'),
        Tip(title: 'Time Management', description: 'Limit gambling time to prevent affecting daily life.'),
        Tip(title: 'Know the Odds', description: 'Understand your probability of winning vs. losing.'),
        Tip(title: 'Avoid Chasing Losses', description: 'Do not try to recover losses by gambling more.'),
        Tip(title: 'Seek Help', description: 'If uncontrollable, reach out to support groups or hotlines.'),
    ],
  ),
  TipCategory(
    index: 3,
    title: 'SAVE',
    icon: FontAwesomeIcons.piggyBank,
    progress: 0.0,
    backgroundColor: AppTheme.klooigeldBlauw,
    tips: [
        Tip(title: 'Automate Savings', description: 'Set up automatic transfers every payday.'),
        Tip(title: 'Set Goals', description: 'Save for specific targets like an emergency fund or vacation.'),
        Tip(title: 'Cut Expenses', description: 'Review and reduce non-essential monthly spending.'),
        Tip(title: 'Use Savings Tools', description: 'High-interest accounts or apps can grow savings faster.'),
        Tip(title: 'Start Small', description: 'Even small amounts saved regularly grow significantly over time.'),
    ],
  ),
  TipCategory(
    index: 4,
    title: 'BORROWING',
    icon: FontAwesomeIcons.handHoldingDollar,
    progress: 0.0,
    backgroundColor: AppTheme.klooigeldRozeAlt,
    tips: [
        Tip(title: 'Borrow Only When Necessary', description: 'Avoid borrowing unless essential.'),
        Tip(title: 'Understand Interest Rates', description: 'Check APR and total repayment amounts.'),
        Tip(title: 'Shorter Terms Are Better', description: 'Pay off loans quickly to reduce interest.'),
        Tip(title: 'Avoid Payday Loans', description: 'These often have very high interest rates.'),
        Tip(title: 'Check Credit Score', description: 'Maintain good credit for lower interest rates.'),
    ],
  ),
  TipCategory(
    index: 5,
    title: 'INVESTING',
    icon: FontAwesomeIcons.chartLine,
    progress: 0.0,
    backgroundColor: AppTheme.klooigeldGroen,
    tips: [
        Tip(title: 'Start Small', description: 'Begin with small investments to learn and reduce risk.'),
        Tip(title: 'Diversify', description: 'Spread money across different assets like stocks and bonds.'),
        Tip(title: 'Do Your Research', description: 'Understand what you are investing in.'),
        Tip(title: 'Long-Term Focus', description: 'Avoid speculation; focus on long-term growth.'),
        Tip(title: 'Know Your Risk Tolerance', description: 'Choose investments matching your comfort level.'),
    ],
  ),
];
