import 'package:crems/entity/Employee.dart';
import 'package:crems/entity/Project.dart';
import 'package:flutter/material.dart';

class Projects extends StatefulWidget {
  const Projects({Key? key}) : super(key: key);

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  List<Project> _projects = [];

  // Mock employees list (replace with your real employee list)
  final List<Employee> _employees = [
    Employee(id: 1, name: 'Alice Johnson'),
    Employee(id: 2, name: 'Bob Smith'),
    Employee(id: 3, name: 'Carol Williams'),
  ];

  final List<String> _projectTypes = ['Residential', 'Commercial', 'Industrial', 'Infrastructure'];

  void _addOrEditProject({Project? existingProject, int? index}) {
    final _formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: existingProject?.name ?? '');
    final budgetController = TextEditingController(text: existingProject?.budget?.toString() ?? '');
    final startDateController = TextEditingController(text: existingProject?.startDate ?? '');
    final endDateController = TextEditingController(text: existingProject?.expectedEndDate ?? '');
    final descriptionController = TextEditingController(text: existingProject?.description ?? '');

    String? selectedProjectType = existingProject?.projectType;
    Employee? selectedManager = existingProject?.projectManager;

    Future<void> _pickDate(TextEditingController controller) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        controller.text = pickedDate.toIso8601String().split('T')[0];
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existingProject == null ? 'Add Project' : 'Edit Project'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Project Name
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Project Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter project name';
                    }
                    return null;
                  },
                ),

                // Budget
                TextFormField(
                  controller: budgetController,
                  decoration: const InputDecoration(labelText: 'Budget'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter budget';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter valid number';
                    }
                    return null;
                  },
                ),

                // Start Date picker
                TextFormField(
                  controller: startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(startDateController),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select start date';
                    }
                    return null;
                  },
                ),

                // Expected End Date picker
                TextFormField(
                  controller: endDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Expected End Date',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(endDateController),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select end date';
                    }
                    return null;
                  },
                ),

                // Project Type Dropdown
                DropdownButtonFormField<String>(
                  value: selectedProjectType,
                  decoration: const InputDecoration(labelText: 'Project Type'),
                  items: _projectTypes
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProjectType = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select project type' : null,
                ),

                // Project Manager Dropdown
                DropdownButtonFormField<Employee>(
                  value: selectedManager,
                  decoration: const InputDecoration(labelText: 'Project Manager'),
                  items: _employees
                      .map(
                        (e) => DropdownMenuItem(
                      value: e,
                      child: Text("Employee"),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedManager = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select project manager' : null,
                ),

                // Description
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(existingProject == null ? 'Add' : 'Save'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newProject = Project(
                  id: existingProject?.id ?? DateTime.now().millisecondsSinceEpoch,
                  name: nameController.text.trim(),
                  budget: int.tryParse(budgetController.text.trim()),
                  startDate: startDateController.text.trim(),
                  expectedEndDate: endDateController.text.trim(),
                  projectType: selectedProjectType,
                  projectManager: selectedManager,
                  description: descriptionController.text.trim(),
                );

                setState(() {
                  if (index != null) {
                    _projects[index] = newProject;
                  } else {
                    _projects.add(newProject);
                  }
                });

                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _deleteProject(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              setState(() => _projects.removeAt(index));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
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
              _buildInfoRow('Budget:', project.budget != null ? '\$${project.budget}' : 'N/A'),
              _buildInfoRow('Start Date:', project.startDate ?? 'N/A'),
              _buildInfoRow('Expected End Date:', project.expectedEndDate ?? 'N/A'),
              _buildInfoRow('Project Type:', project.projectType ?? 'N/A'),
              _buildInfoRow('Project Manager:', project.projectManager?.name ?? 'N/A'),
              const SizedBox(height: 12),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(project.description ?? 'No description provided'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _projects.isEmpty
            ? const Center(child: Text('No projects added yet.'))
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWideScreen ? 2 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3,
          ),
          itemCount: _projects.length,
          itemBuilder: (context, index) {
            final project = _projects[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _viewProject(project),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              project.name ?? 'Unnamed Project',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Budget: \$${project.budget ?? 'N/A'}'),
                            Text('Type: ${project.projectType ?? 'N/A'}'),
                            Text('Manager: ${project.projectManager?.name ?? 'N/A'}'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _addOrEditProject(existingProject: project, index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProject(index),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditProject(),
        icon: const Icon(Icons.add),
        label: const Text('Add Project'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
