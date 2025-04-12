import 'package:flutter/material.dart';


class ClubManagerPage extends StatefulWidget {
  final Map<String, dynamic> managerData;

  const ClubManagerPage({Key? key, required this.managerData}) : super(key: key);

  @override
  _ClubManagerPageState createState() => _ClubManagerPageState();
}

class _ClubManagerPageState extends State<ClubManagerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  // Club type dropdown
  String? _selectedClubType;
  final List<String> _clubTypes = [
    'ACTIVITY BASED CLUBS',
    'INTERNATIONAL CLUBS',
    'RELIGIOUS CLUBS',
    'SPORTS CLUBS'
  ];

  // Add logout method
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _mailController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addClub() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClubType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a club type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('clubs').add({
        'name': _nameController.text.trim(),
        'clubtype': _selectedClubType,
        'contactnumber': _contactController.text.trim(),
        'description': _descriptionController.text.trim(),
        'image': _imageController.text.trim(),
        'mail': _mailController.text.trim(),
        'url': _urlController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': widget.managerData['name'] ?? 'Unknown Manager',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Club added successfully!')),
      );

      _formKey.currentState!.reset();
      setState(() => _selectedClubType = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding club: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteClub(String clubId, String clubName) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "$clubName"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('clubs').doc(clubId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Club deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting club: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Add Club Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'NSBM Club Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Club Name', _nameController, isRequired: true),
                  const SizedBox(height: 12),
                  _buildClubTypeDropdown(),
                  const SizedBox(height: 12),
                  _buildTextField('Contact', _contactController),
                  const SizedBox(height: 12),
                  _buildTextField('Image URL', _imageController),
                  const SizedBox(height: 12),
                  _buildTextField('Email', _mailController),
                  const SizedBox(height: 12),
                  _buildTextField('Website', _urlController),
                  const SizedBox(height: 12),
                  _buildDescriptionField(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addClub,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Add Club',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const SizedBox(height: 16),

            // Existing Clubs List
            const Text(
              'Your Clubs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('clubs')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No clubs found');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var club = snapshot.data!.docs[index];
                    var data = club.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        leading: data['image'] != null && data['image'].isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            data['image'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.group, size: 40),
                          ),
                        )
                            : const Icon(Icons.group, size: 40),
                        title: Text(
                          data['name'] ?? 'No name',
                          style: const TextStyle(fontSize: 15),
                        ),
                        subtitle: Text(
                          '${data['clubtype'] ?? ''} • ${data['contactnumber'] ?? ''}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _deleteClub(club.id, data['name'] ?? 'this club'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedClubType,
      decoration: InputDecoration(
        labelText: 'Club Type',
        labelStyle: const TextStyle(fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: _clubTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedClubType = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select a club type' : null,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: isRequired
          ? (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      }
          : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      style: const TextStyle(fontSize: 14),
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: const TextStyle(fontSize: 14),
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}