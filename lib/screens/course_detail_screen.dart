import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas/services/course_service.dart';
import 'package:uas/provider/auth_provider.dart';

class CourseDetailScreen extends StatefulWidget {
  final int? id; // Optional ID for fetching from API
  final String title;
  final String category;
  final String rating;
  final String reviewCount;
  final String joinedCount;
  final String duration;
  final int lessonsCount;
  final String description;

  const CourseDetailScreen({
    super.key,
    this.id,
    required this.title,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.joinedCount,
    required this.duration,
    required this.lessonsCount,
    this.description = '',
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  int _selectedIndex = 0; // 0: content, 1: reviews, 2: achievement
  List<Map<String, dynamic>> _lessons = [];
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _achievements = [];
  final Set<int> _completedLessonIds = {};

  final CourseService _courseService = CourseService();

  Course? _fullCourse;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateContent();
    if (widget.id != null) {
      _fetchFullCourseDetail();
      _fetchReviews();
    }
  }

  Future<void> _fetchFullCourseDetail() async {
    setState(() => _isLoading = true);
    final token = context.read<AuthProvider>().token;
    final course = await _courseService.getCourse(widget.id!, token: token);
    if (course != null) {
      setState(() {
        _fullCourse = course;
        if (course.lessons.isNotEmpty) {
          _lessons = course.lessons
              .map(
                (l) => {
                  'id': l.id,
                  'title': l.title,
                  'duration': '${l.duration}min',
                },
              )
              .toList();
        }
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchReviews() async {
    if (widget.id == null) return;
    final token = context.read<AuthProvider>().token;
    final reviews = await _courseService.getReviews(widget.id!, token: token);
    setState(() {
      _reviews = reviews;
    });
  }

  void _generateContent() {
    final cat = widget.category.toLowerCase();
    final count = widget.lessonsCount > 0 ? widget.lessonsCount : 4;

    // 1. Generate Lessons based on category and specified count
    _lessons = [];
    List<String> titles = [];

    if (cat.contains('dev')) {
      titles = [
        'Getting Started with the Environment',
        'Understanding Core Architecture',
        'Database Design and Migration',
        'Building the UI Components',
        'State Management Patterns',
        'API Integration & Authentication',
        'Advanced Feature Implementation',
        'Testing & Debugging Strategies',
        'Optimization and Performance',
        'Deployment and CI/CD Pipeline',
      ];
    } else if (cat.contains('mark')) {
      titles = [
        'Understanding Your Audience',
        'Social Media Ads Strategy',
        'Copywriting for Beginners',
        'Email Marketing Automation',
        'SEO Foundations & Keywords',
        'Content Marketing Mastery',
        'Analytics and Data Tracking',
        'Viral Growth Hacking Tips',
        'Conversion Rate Optimization',
        'Building a Brand Identity',
      ];
    } else if (cat.contains('design')) {
      titles = [
        'Visual Design Principles',
        'Color Theory & Typography',
        'Figma Essentials & Tools',
        'User Research & Personas',
        'Wireframing your First UI',
        'Interactive Prototyping',
        'Design Systems & Styles',
        'High Fidelity UI Design',
        'User Testing & Feedback',
        'Portfolio Building Secrets',
      ];
    } else {
      titles = [
        'Course Introduction',
        'Module 1: Foundations',
        'Essential Tools and Setup',
        'Core Concepts Explained',
        'Practical Exercise 1',
        'Advanced Process Guide',
        'Common Troubleshooting',
        'Efficient Workflow Tips',
        'Final Project Preparation',
        'Course Summary & Next Steps',
      ];
    }

    for (int i = 1; i <= count; i++) {
      String titleBase = titles[(i - 1) % titles.length];
      // Append "Part X" only if we are cycling through titles
      String finalTitle = i <= titles.length
          ? titleBase
          : '$titleBase (Part ${((i - 1) ~/ titles.length) + 1})';

      _lessons.add({
        'id': i,
        'title': finalTitle,
        'duration': '${12 + (i % 5) * 3}min',
      });
    }

    // 2. Reviews (Fetched from API)

    // 2. Initial Achievements
    _achievements = [
      {
        'id': 'first_lesson',
        'title': 'The First Step',
        'desc': 'Complete your first lesson',
        'icon': Icons.rocket_launch,
        'unlocked': false,
      },
      {
        'id': 'halfway',
        'title': 'Halfway Enthusiast',
        'desc': 'Complete at least 2 lessons',
        'icon': Icons.star,
        'unlocked': false,
      },
      {
        'id': 'complete',
        'title': 'Category Master',
        'desc': 'Complete all lessons in this course',
        'icon': Icons.emoji_events,
        'unlocked': false,
      },
    ];
  }

  void _completeLesson(int id, String title) {
    if (_completedLessonIds.contains(id)) return;

    setState(() {
      _completedLessonIds.add(id);
      _checkAchievements();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lesson "$title" completed!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _checkAchievements() {
    bool newlyUnlocked = false;
    final count = _completedLessonIds.length;

    if (count >= 1 && !_achievements[0]['unlocked']) {
      _achievements[0]['unlocked'] = true;
      newlyUnlocked = true;
    }
    if (count >= 2 && !_achievements[1]['unlocked']) {
      _achievements[1]['unlocked'] = true;
      newlyUnlocked = true;
    }
    if (count == _lessons.length && !_achievements[2]['unlocked']) {
      _achievements[2]['unlocked'] = true;
      newlyUnlocked = true;
    }

    if (newlyUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🏆 New Achievement Unlocked!'),
          backgroundColor: Colors.amber,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddReviewDialog() {
    final TextEditingController reviewController = TextEditingController();
    double currentRating = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'How was your experience with this course?',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => GestureDetector(
                    onTap: () {
                      setModalState(() {
                        currentRating = (index + 1).toDouble();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedScale(
                        scale: currentRating > index ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          index < currentRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts here...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF1665D8),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 4,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (reviewController.text.isNotEmpty) {
                      final token = context.read<AuthProvider>().token;
                      if (token == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Silakan login terlebih dahulu'),
                          ),
                        );
                        return;
                      }

                      // Show loading indicator inside button or dialog
                      // For simplicity, just submitting
                      final result = await _courseService.addReview(
                        widget.id!,
                        currentRating.toInt(),
                        reviewController.text,
                        token,
                      );

                      if (result['success']) {
                        Navigator.pop(context);
                        _fetchReviews();
                        _fetchFullCourseDetail(); // Update stats
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message']),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message']),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please write a comment'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1665D8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePurchase() async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    if (_fullCourse == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await _courseService.purchaseCourse(_fullCourse!.id, token);

    Navigator.pop(context); // Remove loading

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh profile to update balance
      authProvider.updateProfile();
      _fetchFullCourseDetail(); // Refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPurchased = _fullCourse?.isPurchased ?? false;
    final double price = _fullCourse?.price ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Course header section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1665D8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.rating,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${_reviews.length} reviews)',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Text(
                            '${widget.joinedCount} People Joined',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (widget.description.isNotEmpty ||
                          (_fullCourse?.description?.isNotEmpty == true))
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _fullCourse?.description ?? widget.description,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Tabs: Course Content | Reviews | Achievement
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTabItem('Course Content', 0),
                          _buildTabItem('Reviews', 1),
                          _buildTabItem('Achievement', 2),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // underline indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: _selectedIndex == 0
                            ? Alignment.centerLeft
                            : _selectedIndex == 1
                            ? Alignment.center
                            : Alignment.centerRight,
                        child: Container(
                          height: 3,
                          width: 100,
                          margin: const EdgeInsets.only(left: 8, right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1665D8),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildContentArea(),
                  ),
                ),

                // Bottom purchase section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        offset: const Offset(0, -4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF1665D8),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.bookmark_border,
                            color: Color(0xFF1665D8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_selectedIndex == 1) {
                              _showAddReviewDialog();
                            } else if (!isPurchased) {
                              _handlePurchase();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Anda sudah memiliki akses ke kursus ini.',
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPurchased && _selectedIndex == 0
                                ? Colors.green
                                : const Color(0xFF1665D8),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _selectedIndex == 1
                                ? 'WRITE A REVIEW'
                                : (isPurchased
                                      ? 'AKSES MATERI'
                                      : (price == 0
                                            ? 'AMBIL GRATIS'
                                            : 'BELI \$${price.toStringAsFixed(2)}')),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final bool selected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.black : Colors.grey,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    if (_selectedIndex == 0) {
      // Course content
      return ListView.builder(
        itemCount: _lessons.length,
        itemBuilder: (context, index) {
          final lesson = _lessons[index];
          final bool isCompleted = _completedLessonIds.contains(lesson['id']);
          return _buildContentItem(
            number: lesson['id'],
            title: lesson['title'],
            duration: lesson['duration'],
            isCompleted: isCompleted,
            onPlay: () => _completeLesson(lesson['id'], lesson['title']),
          );
        },
      );
    } else if (_selectedIndex == 1) {
      // Reviews
      if (_reviews.isEmpty) {
        return const Center(
          child: Text(
            'Belum ada ulasan untuk kursus ini.',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }
      return ListView.separated(
        itemCount: _reviews.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final r = _reviews[index];
          final user = r['user'] ?? {};
          final authProvider = context.read<AuthProvider>();
          final profile = authProvider.profile;

          // Check if current user is owner of the review
          final isMyReview =
              profile != null &&
              profile.uid.toString() == r['user_id'].toString();

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              backgroundImage:
                  (user['photo_url'] != null &&
                      user['photo_url'].toString().isNotEmpty)
                  ? NetworkImage(user['photo_url'])
                  : null,
              child:
                  (user['photo_url'] == null ||
                      user['photo_url'].toString().isEmpty)
                  ? Text((user['name'] ?? 'U')[0].toUpperCase())
                  : null,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.star, color: Colors.orange, size: 14),
                const SizedBox(width: 4),
                Text(r['rating'].toString()),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [const SizedBox(height: 4), Text(r['comment'] ?? '')],
            ),
            trailing: isMyReview
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Ulasan'),
                          content: const Text(
                            'Apakah Anda yakin ingin menghapus ulasan ini?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final success = await _courseService.deleteReview(
                          r['id'],
                          authProvider.token!,
                        );
                        if (success) {
                          _fetchReviews();
                          _fetchFullCourseDetail();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ulasan berhasil dihapus'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal menghapus ulasan'),
                            ),
                          );
                        }
                      }
                    },
                  )
                : null,
          );
        },
      );
    } else {
      // Achievement
      return ListView.builder(
        itemCount: _achievements.length,
        itemBuilder: (context, index) {
          final a = _achievements[index];
          final bool unlocked = a['unlocked'];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unlocked ? Colors.green.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: unlocked ? Colors.green.shade200 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: unlocked ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(a['icon'], color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: unlocked
                              ? Colors.green.shade900
                              : Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        a['desc'],
                        style: TextStyle(
                          fontSize: 13,
                          color: unlocked
                              ? Colors.green.shade700
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unlocked)
                  const Icon(Icons.check_circle, color: Colors.green)
                else
                  const Icon(Icons.lock_outline, color: Colors.grey),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildContentItem({
    required int number,
    required String title,
    required String duration,
    required bool isCompleted,
    required VoidCallback onPlay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : const Color(0xFF1665D8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '#$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isCompleted ? Colors.grey : Colors.black,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            duration,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onPlay,
            icon: Icon(
              isCompleted ? Icons.play_circle_outline : Icons.play_circle_fill,
              color: isCompleted ? Colors.grey : const Color(0xFF1665D8),
            ),
          ),
        ],
      ),
    );
  }
}
