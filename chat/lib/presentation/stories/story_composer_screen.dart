import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/stories/application/story_notifier.dart';

/// Screen for creating a new story (photo / video / text).
///
/// Requirements: 7.1, 7.6, 7.7
class StoryComposerScreen extends ConsumerStatefulWidget {
  const StoryComposerScreen({super.key});

  @override
  ConsumerState<StoryComposerScreen> createState() =>
      _StoryComposerScreenState();
}

class _StoryComposerScreenState extends ConsumerState<StoryComposerScreen> {
  final _textController = TextEditingController();
  String _mediaType = 'text';
  File? _selectedFile;
  String _privacy = 'all_contacts';
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('New Story', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _publishStory,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Publish',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildMediaTypeSelector(),
          const SizedBox(height: 16),
          _buildPrivacySelector(),
          const SizedBox(height: 16),
          Expanded(child: _buildPreviewArea()),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildMediaTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _mediaTypeButton(LucideIcons.type, 'Text', 'text'),
        _mediaTypeButton(LucideIcons.camera, 'Camera', 'camera'),
        _mediaTypeButton(LucideIcons.image, 'Gallery', 'image'),
        _mediaTypeButton(LucideIcons.video, 'Video', 'video'),
      ],
    );
  }

  Widget _mediaTypeButton(IconData icon, String label, String type) {
    final isSelected = _isForType(type);
    return InkWell(
      onTap: () => _onMediaTypeChanged(type),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isSelected ? Colors.white38 : Colors.transparent,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  bool _isForType(String type) {
    if (type == 'text' && _mediaType == 'text') return true;
    if (type == 'camera' && _selectedFile != null && _mediaType == 'image') {
      return true;
    }
    if (type == 'video' && _selectedFile != null && _mediaType == 'video') {
      return true;
    }
    return false;
  }

  void _onMediaTypeChanged(String type) {
    setState(() {
      _mediaType = 'text';
      _selectedFile = null;
    });

    switch (type) {
      case 'camera':
        _pickMedia(ImageSource.camera, 'image');
        break;
      case 'image':
        _pickMedia(ImageSource.gallery, 'image');
        break;
      case 'video':
        _pickMedia(ImageSource.gallery, 'video');
        break;
      case 'text':
        setState(() {
          _mediaType = 'text';
          _selectedFile = null;
        });
        break;
    }
  }

  Future<void> _pickMedia(ImageSource source, String type) async {
    try {
      if (type == 'video') {
        final picked = await _picker.pickVideo(source: source);
        if (picked != null) {
          setState(() {
            _selectedFile = File(picked.path);
            _mediaType = 'video';
          });
        }
      } else {
        final picked = await _picker.pickImage(source: source);
        if (picked != null) {
          setState(() {
            _selectedFile = File(picked.path);
            _mediaType = 'image';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick media: $e')),
        );
      }
    }
  }

  Widget _buildPrivacySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('Privacy: ', style: TextStyle(color: Colors.white70)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _privacy,
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(
                value: 'all_contacts',
                child: Text('All Contacts'),
              ),
              DropdownMenuItem(
                value: 'selected',
                child: Text('Selected Contacts'),
              ),
              DropdownMenuItem(
                value: 'public',
                child: Text('Public'),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _privacy = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    if (_selectedFile != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: FileImage(_selectedFile!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: 'Type your story…',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                _isUploading ? 'Publishing…' : 'Tap above to create your story',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publishStory() async {
    if (_mediaType == 'text' && _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text for your story')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final notifier = ref.read(storyNotifierProvider.notifier);

      if (_mediaType == 'text') {
        await notifier.createStory(
          mediaType: 'text',
          content: _textController.text.trim(),
          privacy: _privacy,
        );
      } else if (_selectedFile != null) {
        await notifier.createStory(
          mediaType: _mediaType,
          content: _selectedFile!.path,
          privacy: _privacy,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story published!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
}
