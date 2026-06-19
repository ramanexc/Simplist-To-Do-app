import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Addnewitem extends StatefulWidget {
  final void Function(DateTime?, String, int, String) onsave;
  final TextEditingController controllers;
  final DateTime? initialDate;
  final String initialCategory;
  final int initialPriority;
  final String initialRecurring;
  final bool isEditing;

  const Addnewitem({
    super.key, 
    required this.onsave, 
    required this.controllers,
    this.initialDate,
    this.initialCategory = 'General',
    this.initialPriority = 1,
    this.initialRecurring = 'none',
    this.isEditing = false,
  });

  @override
  State<Addnewitem> createState() => _AddnewitemState();
}

class _AddnewitemState extends State<Addnewitem> {
  DateTime? _selectedDate;
  String _category = 'General';
  int _priority = 1;
  String _recurring = 'none';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _category = widget.initialCategory;
    _priority = widget.initialPriority;
    _recurring = widget.initialRecurring;
  }

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _handleSave() {
    if (widget.controllers.text.trim().isEmpty) return;
    // Close the dialog FIRST, then trigger the save callback
    Navigator.of(context).pop();
    widget.onsave(_selectedDate, _category, _priority, _recurring);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Theme-aware color definitions
    final bgColor = isDark ? const Color(0xFF1D1F36) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    final inputFillColor = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade50;
    final dateChipBg = isDark ? Colors.indigo.shade900.withValues(alpha: 0.3) : Colors.indigo.shade50;
    final dateChipBorder = isDark ? Colors.indigo.shade700 : Colors.indigo.shade100;
    final dateTextColor = _selectedDate == null 
        ? Colors.indigo.shade300
        : (isDark ? Colors.indigo.shade200 : Colors.indigo.shade700);
    final cancelColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final dropdownBorder = isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: bgColor,
      elevation: 10,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isEditing ? 'Edit Task' : 'New Task',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: widget.controllers,
                autofocus: true,
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  hintStyle: TextStyle(color: hintColor),
                  filled: true,
                  fillColor: inputFillColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.indigoAccent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: dateChipBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: dateChipBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, color: Colors.indigo.shade400),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDate == null 
                              ? 'Set Due Date (Optional)' 
                              : DateFormat('MMM d, y HH:mm').format(_selectedDate!),
                          style: TextStyle(
                            color: dateTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_selectedDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedDate = null),
                          child: Icon(Icons.close_rounded, size: 18, color: cancelColor),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      dropdownColor: bgColor,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : null),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: dropdownBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: dropdownBorder),
                        ),
                      ),
                      items: ['General', 'Work', 'Personal', 'Shopping']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setState(() => _category = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _priority,
                      dropdownColor: bgColor,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : null),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: dropdownBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: dropdownBorder),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 2, child: Text('High', style: TextStyle(color: isDark ? Colors.red.shade300 : Colors.red))),
                        DropdownMenuItem(value: 1, child: Text('Medium', style: TextStyle(color: isDark ? Colors.orange.shade300 : Colors.orange))),
                        DropdownMenuItem(value: 0, child: Text('Low', style: TextStyle(color: isDark ? Colors.green.shade300 : Colors.green))),
                      ],
                      onChanged: (val) => setState(() => _priority = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _recurring,
                dropdownColor: bgColor,
                decoration: InputDecoration(
                  labelText: 'Repeat',
                  labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : null),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dropdownBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dropdownBorder),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Do not repeat')),
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (val) => setState(() => _recurring = val!),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: cancelColor,
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
