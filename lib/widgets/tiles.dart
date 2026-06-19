import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class Tiles extends StatelessWidget {
  const Tiles({
    super.key,
    required this.tiletext,
    required this.tilebool,
    required this.onChanged,
    required this.deletefunc,
    required this.editfunc,
    this.dueDate,
    this.category = 'General',
    this.priority = 1,
    this.dragIndex,
  });
  
  final String tiletext;
  final bool tilebool;
  final void Function(bool?)? onChanged;
  final VoidCallback deletefunc;
  final VoidCallback editfunc;
  final DateTime? dueDate;
  final String category;
  final int priority;
  final int? dragIndex; // If non-null, show drag handle for manual reorder

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isOverdue = false;
    if (dueDate != null) {
      isOverdue = dueDate!.isBefore(DateTime.now()) && !tilebool;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                editfunc();
              },
              borderRadius: BorderRadius.circular(16),
              icon: Icons.edit_rounded,
              backgroundColor: Colors.indigoAccent.withValues(alpha: 0.9),
              foregroundColor: Colors.white,
            ),
            SlidableAction(
              onPressed: (context) {
                deletefunc();
              },
              borderRadius: BorderRadius.circular(16),
              icon: Icons.delete_rounded,
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? const Color(0xFF1D1F36) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border(
              left: BorderSide(
                width: 4, 
                color: priority == 2 ? Colors.redAccent : (priority == 1 ? Colors.orangeAccent : Colors.greenAccent)
              )
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            child: Row(
              children: [
                // Only show drag handle when in manual sort mode
                if (dragIndex != null)
                  ReorderableDragStartListener(
                    index: dragIndex!,
                    child: Icon(Icons.drag_indicator_rounded, 
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, 
                      size: 20,
                    ),
                  )
                else
                  const SizedBox(width: 4),
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: tilebool,
                    onChanged: onChanged,
                    activeColor: Colors.indigoAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tiletext,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: tilebool ? FontWeight.normal : FontWeight.w500,
                          color: tilebool 
                              ? Colors.grey.shade500
                              : (isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87),
                          decoration: tilebool
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (dueDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: isOverdue 
                                    ? (isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50)
                                    : (isDark ? Colors.indigo.shade900.withValues(alpha: 0.3) : Colors.indigo.shade50),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isOverdue 
                                      ? (isDark ? Colors.red.shade700 : Colors.red.shade100) 
                                      : (isDark ? Colors.indigo.shade700 : Colors.indigo.shade100),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: isOverdue 
                                        ? (isDark ? Colors.red.shade300 : Colors.red.shade700)
                                        : (isDark ? Colors.indigo.shade300 : Colors.indigo.shade700),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM d, HH:mm').format(dueDate!),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isOverdue 
                                          ? (isDark ? Colors.red.shade300 : Colors.red.shade700)
                                          : (isDark ? Colors.indigo.shade300 : Colors.indigo.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
