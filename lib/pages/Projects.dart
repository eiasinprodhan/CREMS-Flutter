import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:crems/entity/Project.dart';
import 'package:crems/services/ProjectService.dart';

class Projects extends StatefulWidget {
  const Projects({Key? key}) : super(key: key);

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      final projects = await _projectService.getAllProjects();
      setState(() {
        _projects = projects;
      });
    } catch (e) {
      debugPrint("Error fetching projects: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load projects")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat.yMMMd().format(date);
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return 'N/A';
    return NumberFormat.simpleCurrency().format(amount);
  }

  String _getProjectStatus(Project project) {
    final now = DateTime.now();
    if (project.expectedEndDate != null && now.isAfter(project.expectedEndDate!)) {
      return "Completed";
    }
    return "Ongoing";
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green.shade600;
      case "Ongoing":
      default:
        return Colors.orange.shade600;
    }
  }

  void _viewProject(Project project) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(project.name ?? 'Project Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.description ?? 'No description provided.'),
              const SizedBox(height: 12),
              Text('Budget: ${_formatCurrency(project.budget)}'),
              Text('Start Date: ${_formatDate(project.startDate)}'),
              Text('Expected End Date: ${_formatDate(project.expectedEndDate)}'),
              Text('Project Type: ${project.projectType ?? 'N/A'}'),
              Text('Project Manager: ${project.projectManager?.name ?? 'N/A'}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAddEditDialog({Project? project}) {
    final _formKey = GlobalKey<FormState>();
    String? _name = project?.name;
    double? _budget = project?.budget;
    DateTime? _startDate = project?.startDate;
    DateTime? _expectedEndDate = project?.expectedEndDate;
    String? _projectType = project?.projectType;
    String? _description = project?.description;

    Future<void> _pickDate(BuildContext context, DateTime? initialDate, ValueChanged<DateTime> onDatePicked) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        onDatePicked(picked);
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(project == null ? 'Add Project' : 'Edit Project'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Project Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter project name' : null,
                  onSaved: (value) => _name = value,
                ),
                TextFormField(
                  initialValue: _budget?.toString(),
                  decoration: const InputDecoration(labelText: 'Budget'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter budget';
                    if (double.tryParse(value) == null) return 'Enter valid number';
                    return null;
                  },
                  onSaved: (value) => _budget = double.tryParse(value ?? ''),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Start Date: '),
                    Text(_startDate == null ? 'Not selected' : _formatDate(_startDate)),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        await _pickDate(context, _startDate, (picked) {
                          _startDate = picked;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Expected End Date: '),
                    Text(_expectedEndDate == null ? 'Not selected' : _formatDate(_expectedEndDate)),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        await _pickDate(context, _expectedEndDate, (picked) {
                          _expectedEndDate = picked;
                        });
                      },
                    ),
                  ],
                ),
                TextFormField(
                  initialValue: _projectType,
                  decoration: const InputDecoration(labelText: 'Project Type'),
                  onSaved: (value) => _projectType = value,
                ),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  onSaved: (value) => _description = value,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();

                Project newProject = Project(
                  id: project?.id,
                  name: _name,
                  budget: _budget,
                  startDate: _startDate,
                  expectedEndDate: _expectedEndDate,
                  projectType: _projectType,
                  description: _description,
                );

                Navigator.pop(context);

                // Optimistic UI: Show success immediately
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(project == null
                        ? 'Project saved (pending server confirmation)'
                        : 'Project updated (pending server confirmation)'),
                  ),
                );

                bool success;
                if (project == null) {
                  success = await _projectService.saveProject(newProject);
                } else {
                  success = await _projectService.updateProject(newProject);
                }

                if (!success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Server failed to save project')),
                  );
                }

                if (mounted) _fetchProjects();
              }
            },
            child: Text(project == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteProject(Project project) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${project.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // close dialog

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project deleted (pending server confirmation)')),
              );

              bool success = await _projectService.deleteProject(project.id!);

              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Server failed to delete project')),
                );
              }

              if (mounted) _fetchProjects();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount;

    if (width >= 1200) {
      crossAxisCount = 4;
    } else if (width >= 900) {
      crossAxisCount = 3;
    } else if (width >= 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add),
              label: const Text("Add Project"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
          ? const Center(child: Text("No projects found."))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _projects.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) {
            final project = _projects[index];
            return _buildProjectCard(project);
          },
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    final status = _getProjectStatus(project);
    final statusColor = _getStatusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + status badge
          Row(
            children: [
              Expanded(
                child: Text(
                  project.name ?? 'Unnamed Project',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Budget
          Row(
            children: [
              const Icon(Icons.monetization_on, size: 18, color: Colors.deepPurple),
              const SizedBox(width: 6),
              Text(
                _formatCurrency(project.budget),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Manager
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: Colors.deepPurple),
              const SizedBox(width: 6),
              Text(
                project.projectManager?.name ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Dates
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.deepPurple),
              const SizedBox(width: 6),
              Text(
                "Start: ${_formatDate(project.startDate)}",
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.flag, size: 16, color: Colors.deepPurple),
              const SizedBox(width: 6),
              Text(
                "End: ${_formatDate(project.expectedEndDate)}",
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),

          const Spacer(),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'View',
                icon: const Icon(Icons.visibility_outlined, color: Colors.blueAccent),
                onPressed: () => _viewProject(project),
              ),
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                onPressed: () => _showAddEditDialog(project: project),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteProject(project),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
