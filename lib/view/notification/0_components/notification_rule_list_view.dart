import 'package:flutter/material.dart';
import 'package:push_notification_test/data/domain/notification_rule.dart';

class NotificationRuleListView extends StatelessWidget {
  final List<NotificationRule> items;

  const NotificationRuleListView({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('예약 목록이 없습니다.'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _NotificationItem(item: items[index]);
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationRule item;

  const _NotificationItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(item.title),
          Text(item.description),
          Text(item.startDate.toString()),
          Text(item.endDate.toString()),
          Text(item.timeOfDay.toString()),
          Text(item.weekdays.toString()),
        ],
      ),
    );
  }
}
