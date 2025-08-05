import 'package:flutter/material.dart';
import '../../../../core/constants/design_constants.dart';

/// Виджет для отображения информации о ключе
class KeyInfoWidget extends StatelessWidget {
  final Map<String, dynamic>? keyInfo;

  const KeyInfoWidget({
    super.key,
    this.keyInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (keyInfo == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignConstants.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Информация о ключе',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: DesignConstants.padding),
          
          _buildInfoRow('Хеш ключа', keyInfo!['hash'] ?? 'N/A'),
          _buildInfoRow('Размер', '${keyInfo!['size'] ?? 'N/A'} байт'),
          _buildInfoRow('Алгоритм', keyInfo!['algorithm'] ?? 'N/A'),
          _buildInfoRow('Режим', keyInfo!['mode'] ?? 'N/A'),
          _buildInfoRow('Дополнение', keyInfo!['padding'] ?? 'N/A'),
          _buildInfoRow('Создан', _formatDate(keyInfo!['createdAt'])),
          _buildInfoRow('Статус', keyInfo!['isActive'] == true ? 'Активен' : 'Неактивен'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateString;
    }
  }
} 