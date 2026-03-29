import 'package:hive/hive.dart';

class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String,
      amount: (fields[1] as num).toDouble(),
      category: fields[2] as String,
      date: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeByte(5);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.amount);
    writer.writeByte(2);
    writer.write(obj.category);
    writer.writeByte(3);
    writer.write(obj.date.millisecondsSinceEpoch);
    writer.writeByte(4);
    writer.write(obj.note);
  }
}