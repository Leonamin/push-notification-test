import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:push_notification_test/data/domain/notification_instance.dart';
import 'package:push_notification_test/data/domain/notification_rule.dart';
import 'package:push_notification_test/data/entity/notification_instance_entity.dart';
import 'package:push_notification_test/data/entity/notification_rule_entity.dart';
import 'package:push_notification_test/view/notification/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  static Database? _database;
  static const _databaseName = "notification.db";
  static const _databaseVersion = 1;

  static const _tableRules = 'notification_rules';
  static const _tableInstances = 'notification_instances';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory =
        await path_provider.getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableRules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        weekdays TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableInstances (
        id INTEGER PRIMARY KEY,
        rule_id INTEGER NOT NULL,
        scheduled_time TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (rule_id) REFERENCES $_tableRules (id) ON DELETE CASCADE
      )
    ''');
  }

  @override
  Future<NotificationRule> createRule(
      NotificationRuleCreateRequest request) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final ruleEntity = NotificationRuleEntity(
      id: 0, // DB에서 자동 생성
      title: request.title,
      description: request.description,
      startDate: request.startDate,
      endDate: request.endDate,
      hour: request.timeOfDay.hour,
      minute: request.timeOfDay.minute,
      weekdays: request.weekdays,
    );

    final id = await db.insert(
      _tableRules,
      {
        ...ruleEntity.toJson(),
        'created_at': now,
        'updated_at': now,
      }..remove('id'),
    );

    return NotificationRule(
      id: id,
      title: ruleEntity.title,
      description: ruleEntity.description,
      startDate: ruleEntity.startDate,
      endDate: ruleEntity.endDate,
      timeOfDay: TimeOfDay(
        hour: ruleEntity.hour,
        minute: ruleEntity.minute,
      ),
      weekdays: ruleEntity.weekdays,
    );
  }

  @override
  Future<void> deleteAllRules() async {
    final db = await database;
    await db.delete(_tableRules);
  }

  @override
  Future<void> deleteRule(int id) async {
    final db = await database;
    await db.delete(
      _tableRules,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<NotificationRule>> getRules() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableRules);

    return maps.map((map) {
      final entity = NotificationRuleEntity.fromJson(map);
      return NotificationRule(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        startDate: entity.startDate,
        endDate: entity.endDate,
        timeOfDay: TimeOfDay(
          hour: entity.hour,
          minute: entity.minute,
        ),
        weekdays: entity.weekdays,
      );
    }).toList();
  }

  @override
  Future<void> createInstance(NotificationInstanceCreateRequest request) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final instanceEntity = NotificationInstanceEntity(
      id: request.id,
      ruleId: request.ruleId,
      scheduledTime: request.scheduledTime,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.insert(
      _tableInstances,
      {
        ...instanceEntity.toJson(),
        'created_at': now,
        'updated_at': now,
      },
    );
  }

  @override
  Future<void> deleteInstance(int id) async {
    final db = await database;
    await db.delete(
      _tableInstances,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAllInstances() async {
    final db = await database;
    await db.delete(_tableInstances);
  }

  @override
  Future<List<NotificationInstance>> getInstancesByRuleId(int ruleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableInstances,
      where: 'rule_id = ?',
      whereArgs: [ruleId],
    );

    return maps.map((map) {
      final entity = NotificationInstanceEntity.fromJson(map);
      return NotificationInstance(
        id: entity.id,
        ruleId: entity.ruleId,
        scheduledTime: entity.scheduledTime,
      );
    }).toList();
  }

  @override
  Future<List<NotificationInstance>> getAllInstances() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableInstances);

    return maps.map((map) {
      final entity = NotificationInstanceEntity.fromJson(map);
      return NotificationInstance(
        id: entity.id,
        ruleId: entity.ruleId,
        scheduledTime: entity.scheduledTime,
      );
    }).toList();
  }
}
