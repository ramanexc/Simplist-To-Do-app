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
  });
  
  final String tiletext;
  final bool tilebool;
  final void Function(bool?)? onChanged;
  final VoidCallback deletefunc;
  final VoidCallback editfunc;
  final DateTime? dueDate;

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: Colors.indigoAccent.withOpacity(0.9),
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
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              children: [
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
                      color: Colors.grey.shade300,
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
                          color: tilebool ? Colors.grey.shade400 : Colors.black87,
                          decoration: tilebool
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: Colors.grey.shade400,
                        ),
                      ),
                      if (dueDate != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: isOverdue ? Colors.red.shade50 : Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isOverdue ? Colors.red.shade100 : Colors.indigo.shade100,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: isOverdue ? Colors.red.shade700 : Colors.indigo.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d, HH:mm').format(dueDate!),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isOverdue ? Colors.red.shade700 : Colors.indigo.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
