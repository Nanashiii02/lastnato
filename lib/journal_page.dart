import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'auth_service.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final AuthService _authService = AuthService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
    _authService.authStateChanges.listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: _user == null
            ? _buildLoggedOutView()
            : JournalBody(user: _user!),
      ),
    );
  }

  Widget _buildLoggedOutView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Welcome to Your Digital Journal',
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Please log in to continue.',
            style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }
}

class JournalBody extends StatefulWidget {
  final User user;

  const JournalBody({super.key, required this.user});

  @override
  State<JournalBody> createState() => _JournalBodyState();
}

class _JournalBodyState extends State<JournalBody> {
  late final CollectionReference _journalCollection;
  String? _selectedEntryId;

  @override
  void initState() {
    super.initState();
    _journalCollection = FirebaseFirestore.instance
        .collection('journals')
        .doc(widget.user.uid)
        .collection('entries');
  }

  void _viewEntry(String docId) {
    setState(() {
      _selectedEntryId = docId;
    });
  }

  void _closeEntry() {
    setState(() {
      _selectedEntryId = null;
    });
  }

  Future<void> _addJournalEntry(String title, String text) async {
    if (text.isNotEmpty && title.isNotEmpty) {
      final entry = {
        'title': title,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      };
      try {
        await _journalCollection.add(entry);
        developer.log(
          'Journal entry added to Firestore.',
          name: 'journal.firestore',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Journal entry added!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        developer.log(
          'Failed to add journal entry: $error',
          name: 'journal.firestore',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add entry: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editJournalEntry(
    String docId,
    String newTitle,
    String newText,
  ) async {
    try {
      await _journalCollection.doc(docId).update({
        'title': newTitle,
        'text': newText,
      });
      developer.log('Journal entry updated.', name: 'journal.firestore');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal entry updated!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (error) {
      developer.log(
        'Failed to update journal entry: $error',
        name: 'journal.firestore',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update entry: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteJournalEntry(String docId) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text(
          'Are you sure you want to delete this journal entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _journalCollection.doc(docId).delete();
        developer.log('Journal entry deleted.', name: 'journal.firestore');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Journal entry deleted!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (error) {
        developer.log(
          'Failed to delete journal entry: $error',
          name: 'journal.firestore',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete entry: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showAddEntryDialog() {
    _showJournalEntryDialog();
  }

  void _showJournalEntryDialog({
    String? docId,
    String? currentTitle,
    String? currentText,
  }) {
    final titleController = TextEditingController(text: currentTitle);
    final textController = TextEditingController(text: currentText);
    final isEditing = docId != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Journal Entry' : 'New Journal Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'My First Thoughts',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Ewan koooooo',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(isEditing ? 'Save' : 'Add'),
              onPressed: () {
                final title = titleController.text;
                final text = textController.text;
                if (isEditing) {
                  _editJournalEntry(docId, title, text);
                } else {
                  _addJournalEntry(title, text);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedOpacity(
                  opacity: _selectedEntryId == null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Text(
                    'DIARY',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_selectedEntryId == null)
                  TextButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    label: const Text('Back'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _selectedEntryId != null
                    ? _JournalDetailView(
                        key: ValueKey(_selectedEntryId),
                        docId: _selectedEntryId!,
                        journalCollection: _journalCollection,
                        onClose: _closeEntry,
                        onEdit: (data) {
                          _showJournalEntryDialog(
                            docId: _selectedEntryId!,
                            currentTitle: data['title'],
                            currentText: data['text'],
                          );
                        },
                      )
                    : _JournalList(
                        key: const ValueKey('JournalList'),
                        journalCollection: _journalCollection,
                        onEntryTap: _viewEntry,
                        onEdit: (docId, data) {
                          _showJournalEntryDialog(
                            docId: docId,
                            currentTitle: data['title'],
                            currentText: data['text'],
                          );
                        },
                        onDelete: _deleteJournalEntry,
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedEntryId == null
          ? FloatingActionButton(
              onPressed: _showAddEntryDialog,
              backgroundColor: Colors.black,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _JournalList extends StatelessWidget {
  final CollectionReference journalCollection;
  final Function(String) onEntryTap;
  final Function(String, Map<String, dynamic>) onEdit;
  final Function(String) onDelete;

  const _JournalList({
    super.key,
    required this.journalCollection,
    required this.onEntryTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: journalCollection
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          developer.log(
            'Firestore error: ${snapshot.error}',
            name: 'journal.firestore',
          );
          return const Center(child: Text('Something went wrong.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs;
        if (docs == null || docs.isEmpty) {
          return const Center(child: Text('Your journal is empty.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _JournalListItem(
              docId: doc.id,
              data: data,
              onTap: onEntryTap,
              onEdit: onEdit,
              onDelete: onDelete,
            );
          },
        );
      },
    );
  }
}

class _JournalListItem extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final Function(String) onTap;
  final Function(String, Map<String, dynamic>) onEdit;
  final Function(String) onDelete;

  const _JournalListItem({
    required this.docId,
    required this.data,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? 'No Title';
    final text = data['text'] as String? ?? 'No text available.';
    final timestamp = data['timestamp'] as Timestamp?;
    String formattedDate = 'No date';

    if (timestamp != null) {
      formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
    }

    return GestureDetector(
      onTap: () => onTap(docId),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => onEdit(docId, data),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha((255 * 0.1).round()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => onDelete(docId),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalDetailView extends StatelessWidget {
  final String docId;
  final CollectionReference journalCollection;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onEdit;

  const _JournalDetailView({
    super.key,
    required this.docId,
    required this.journalCollection,
    required this.onClose,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: journalCollection.doc(docId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading entry.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        if (data == null) {
          return const Center(child: Text('Entry not found.'));
        }

        final title = data['title'] as String? ?? 'No Title';
        final text = data['text'] as String? ?? '';

        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: onClose,
                    ),
                    GestureDetector(
                      onTap: () => onEdit(data),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha((255 * 0.1).round()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 24,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
