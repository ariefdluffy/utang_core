import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

final authProvider = Provider((ref) => SupabaseService());
final userProvider = StateProvider((ref) => SupabaseService().currentUser);
