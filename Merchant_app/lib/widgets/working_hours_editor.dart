import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/working_hours.dart';
import '../utils/app_colors.dart';

class WorkingHoursEditor extends StatefulWidget {
  final List<WorkingHours> workingHours;
  final Function(List<WorkingHours>) onWorkingHoursChanged;

  const WorkingHoursEditor({
    super.key,
    required this.workingHours,
    required this.onWorkingHoursChanged,
  });

  @override
  State<WorkingHoursEditor> createState() => _WorkingHoursEditorState();
}

class _WorkingHoursEditorState extends State<WorkingHoursEditor> {
  late List<WorkingHours> _workingHours;
  final List<TextEditingController> _startTimeControllers = [];
  final List<TextEditingController> _endTimeControllers = [];

  @override
  void initState() {
    super.initState();
    _workingHours = List.from(widget.workingHours);
    _initializeControllers();
  }

  void _initializeControllers() {
    _startTimeControllers.clear();
    _endTimeControllers.clear();
    
    for (int i = 0; i < _workingHours.length; i++) {
      _startTimeControllers.add(TextEditingController(text: _workingHours[i].startTime));
      _endTimeControllers.add(TextEditingController(text: _workingHours[i].endTime));
    }
  }

  @override
  void dispose() {
    for (var controller in _startTimeControllers) {
      controller.dispose();
    }
    for (var controller in _endTimeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateWorkingHours(int index, WorkingHours updatedHours) {
    setState(() {
      _workingHours[index] = updatedHours;
    });
    widget.onWorkingHoursChanged(_workingHours);
  }

  void _toggleDayOpen(int index) {
    final current = _workingHours[index];
    final updated = current.copyWith(isOpen: !current.isOpen);
    _updateWorkingHours(index, updated);
  }

  void _updateStartTime(int index, String time) {
    final current = _workingHours[index];
    final updated = current.copyWith(startTime: time);
    _updateWorkingHours(index, updated);
  }

  void _updateEndTime(int index, String time) {
    final current = _workingHours[index];
    final updated = current.copyWith(endTime: time);
    _updateWorkingHours(index, updated);
  }

  void _resetToDefault() {
    setState(() {
      _workingHours = WorkingHours.getDefaultWorkingHours();
      _initializeControllers();
    });
    widget.onWorkingHoursChanged(_workingHours);
  }

  void _setAllDaysOpen() {
    setState(() {
      for (int i = 0; i < _workingHours.length; i++) {
        _workingHours[i] = _workingHours[i].copyWith(isOpen: true);
      }
    });
    widget.onWorkingHoursChanged(_workingHours);
  }

  void _setAllDaysClosed() {
    setState(() {
      for (int i = 0; i < _workingHours.length; i++) {
        _workingHours[i] = _workingHours[i].copyWith(isOpen: false);
      }
    });
    widget.onWorkingHoursChanged(_workingHours);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Working Hours',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _resetToDefault,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _setAllDaysOpen,
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('All Open'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _setAllDaysClosed,
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('All Closed'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Working hours list
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _workingHours.asMap().entries.map((entry) {
              final index = entry.key;
              final hours = entry.value;
              
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: index < _workingHours.length - 1
                        ? BorderSide(color: AppColors.border.withOpacity(0.3))
                        : BorderSide.none,
                  ),
                ),
                child: _buildDayRow(index, hours),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Summary
        _buildSummary(),
      ],
    );
  }

  Widget _buildDayRow(int index, WorkingHours hours) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Day name
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Switch(
                  value: hours.isOpen,
                  onChanged: (value) => _toggleDayOpen(index),
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  hours.day,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: hours.isOpen ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Time inputs
          if (hours.isOpen) ...[
            Expanded(
              flex: 2,
              child: _buildTimeInput(
                controller: _startTimeControllers[index],
                label: 'Start',
                onChanged: (time) => _updateStartTime(index, time),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildTimeInput(
                controller: _endTimeControllers[index],
                label: 'End',
                onChanged: (time) => _updateEndTime(index, time),
              ),
            ),
          ] else ...[
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Closed',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
          
          // Status indicator
          const SizedBox(width: 16),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hours.isOpen ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'HH:MM',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: IconButton(
              icon: const Icon(Icons.access_time, size: 20),
              onPressed: () => _showTimePicker(controller, onChanged),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
            LengthLimitingTextInputFormatter(5),
          ],
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
              return 'Invalid time format (HH:MM)';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _showTimePicker(TextEditingController controller, Function(String) onChanged) {
    final currentTime = controller.text;
    int hour = 9;
    int minute = 0;
    
    if (currentTime.isNotEmpty) {
      final parts = currentTime.split(':');
      if (parts.length == 2) {
        hour = int.tryParse(parts[0]) ?? 9;
        minute = int.tryParse(parts[1]) ?? 0;
      }
    }
    
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              hourMinuteTextColor: AppColors.primary,
              hourMinuteColor: AppColors.primary,
              dialHandColor: AppColors.primary,
              dialBackgroundColor: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    ).then((time) {
      if (time != null) {
        final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        controller.text = timeString;
        onChanged(timeString);
      }
    });
  }

  Widget _buildSummary() {
    final openDays = _workingHours.where((h) => h.isOpen).length;
    final closedDays = _workingHours.where((h) => !h.isOpen).length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Working Hours Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$openDays days open, $closedDays days closed',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
