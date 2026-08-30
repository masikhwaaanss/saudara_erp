import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/tables/expenses_table.dart';
import 'package:saudara_erp/database/tables/cash_transactions_table.dart';

class ExpensesDao {
  final AppDatabase db;

  ExpensesDao(this.db);

  /// Get expense by ID
  Future<Expense?> getExpenseById(int id) {
    return (db.select(db.expenses)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  /// Get all expenses
  Future<List<Expense>> getAllExpenses() {
    return (db.select(db.expenses)
          ..orderBy([(e) => OrderingTerm(expression: e.expenseDate, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) {
    return (db.select(db.expenses)
          ..where((e) => e.category.equals(category))
          ..orderBy([(e) => OrderingTerm(expression: e.expenseDate, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return (db.select(db.expenses)
          ..where((e) => e.expenseDate.isBetweenValues(startDate, endDate))
          ..orderBy([(e) => OrderingTerm(expression: e.expenseDate, mode: OrderingMode.desc)]))
        .get();
  }

  /// Create expense
  Future<int> createExpense(ExpensesCompanion expense) {
    return db.into(db.expenses).insert(expense);
  }

  /// Update expense
  Future<bool> updateExpense(Expense expense) {
    return db.update(db.expenses).replace(expense);
  }
}

class CashTransactionsDao {
  final AppDatabase db;

  CashTransactionsDao(this.db);

  /// Get cash transaction by ID
  Future<CashTransaction?> getCashTransactionById(int id) {
    return (db.select(db.cashTransactions)..where((ct) => ct.id.equals(id))).getSingleOrNull();
  }

  /// Get all cash transactions
  Future<List<CashTransaction>> getAllCashTransactions() {
    return (db.select(db.cashTransactions)
          ..orderBy([(ct) => OrderingTerm(expression: ct.transactionDate, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get cash transactions by date range
  Future<List<CashTransaction>> getCashTransactionsByDateRange(
      DateTime startDate, DateTime endDate) {
    return (db.select(db.cashTransactions)
          ..where((ct) => ct.transactionDate.isBetweenValues(startDate, endDate))
          ..orderBy([(ct) => OrderingTerm(expression: ct.transactionDate, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get cash in transactions
  Future<int> getTotalCashIn(DateTime startDate, DateTime endDate) async {
    final result = await (db.selectOnly(db.cashTransactions)
          ..addColumns([db.cashTransactions.amount.sum()])
          ..where(db.cashTransactions.type.equals('cash_in') &
              db.cashTransactions.transactionDate.isBetweenValues(startDate, endDate)))
        .map((row) => row.read(db.cashTransactions.amount.sum()))
        .getSingle();
    return result ?? 0;
  }

  /// Get cash out transactions
  Future<int> getTotalCashOut(DateTime startDate, DateTime endDate) async {
    final result = await (db.selectOnly(db.cashTransactions)
          ..addColumns([db.cashTransactions.amount.sum()])
          ..where(db.cashTransactions.type.equals('cash_out') &
              db.cashTransactions.transactionDate.isBetweenValues(startDate, endDate)))
        .map((row) => row.read(db.cashTransactions.amount.sum()))
        .getSingle();
    return result ?? 0;
  }

  /// Create cash transaction
  Future<int> createCashTransaction(CashTransactionsCompanion transaction) {
    return db.into(db.cashTransactions).insert(transaction);
  }
}
