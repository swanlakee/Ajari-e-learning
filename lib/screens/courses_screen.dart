import 'package:flutter/material.dart';
import 'dart:async';
import 'course_detail_screen.dart';
import '../services/course_service.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CourseService _courseService = CourseService();
  List<Course> _courses = [];
  List<String> _categories = ['Design', 'Marketing', 'Business', 'Work'];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadData(isAutoRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData({bool isAutoRefresh = false}) async {
    if (!isAutoRefresh) {
      setState(() => _isLoading = true);
    }
    try {
      final results = await Future.wait([
        _courseService.getCourses(
          category: _selectedCategory == 'All' ? null : _selectedCategory,
          search: _searchController.text.isEmpty
              ? null
              : _searchController.text,
        ),
        _courseService.getCategories(),
      ]);

      setState(() {
        _courses = results[0] as List<Course>;
        if ((results[1] as List<String>).isNotEmpty) {
          _categories = ['All', ...results[1] as List<String>];
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error in CoursesScreen: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEBEEF3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    _loadData();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search here',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.grey),
                onPressed: () => _loadData(),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${_courses.length} Courses Found',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          // Category chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    _loadData();
                  },
                  child: _categoryChip(
                    cat,
                    _getCategoryIcon(cat),
                    selected: _selectedCategory == cat,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _courses.isEmpty
                ? const Center(child: Text('No courses found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      return _courseListItem(
                        id: course.id,
                        tag: course.category.toUpperCase(),
                        title: course.title,
                        content: '${course.lessonsCount} Content',
                        lessonsCount: course.lessonsCount,
                        rating: course.rating.toString(),
                        price: course.price.toStringAsFixed(2),
                        imageUrl:
                            course.imageUrl ??
                            'https://picsum.photos/seed/${course.id}/120',
                        reviewCount: course.reviewCount.toString(),
                        joinedCount: course.joinedCount.toString(),
                        duration: course.duration ?? '0h',
                        description: course.description ?? '',
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    final icons = {
      'Design': Icons.draw,
      'Marketing': Icons.trending_up,
      'Business': Icons.business,
      'Development': Icons.code,
      'Work': Icons.work,
      'All': Icons.grid_view,
    };
    return icons[cat] ?? Icons.category;
  }

  Widget _categoryChip(String label, IconData icon, {bool selected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1665D8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xFF1665D8) : const Color(0xFFE6EDF7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? Colors.white : const Color(0xFF1665D8),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseListItem({
    int? id,
    required String tag,
    required String title,
    required String content,
    required int lessonsCount,
    required String rating,
    required String price,
    required String imageUrl,
    required String reviewCount,
    required String joinedCount,
    required String duration,
    String description = '',
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(
              id: id,
              title: title,
              category: tag,
              rating: rating,
              reviewCount: reviewCount,
              joinedCount: joinedCount,
              duration: duration,
              lessonsCount: lessonsCount,
              description: description,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag,
                    style: const TextStyle(
                      color: Color(0xFF1665D8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        content,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '\$$price',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
