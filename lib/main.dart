import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shieldx/app/app.dart';
import 'package:shieldx/app/data/services/_supabase.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: ".env");
  await SupabaseService.initialize();
  runApp(const MyApp());
}