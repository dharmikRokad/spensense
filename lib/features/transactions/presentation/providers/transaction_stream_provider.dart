import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/datasources/notification_listener_datasource.dart';
import '../../domain/entities/transaction_entity.dart';

/// Provides the stream of auto-detected transactions for the current user.
/// Starts only when the user is authenticated.
final transactionStreamProvider = StreamProvider<List<TransactionEntity>>((
  ref,
) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();

  return ref
      .watch(notificationListenerServiceProvider(user.uid))
      .startListening()
      .scan<List<TransactionEntity>>((acc, tx, _) => [tx, ...acc], []);
});

// Extension for scan operator
extension StreamScan<T> on Stream<T> {
  Stream<R> scan<R>(R Function(R, T, int) combine, R initialValue) async* {
    var result = initialValue;
    int index = 0;
    await for (final value in this) {
      result = combine(result, value, index++);
      yield result;
    }
  }
}
