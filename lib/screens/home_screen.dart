import 'package:flutter/material.dart';
import 'dart:async';
import 'courses_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'course_detail_screen.dart';
import '../services/course_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _selectedCategory;
  final ScrollController _categoryScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final CourseService _courseService = CourseService();
  List<Course> _featuredCourses = [];
  List<Course> _popularCourses = [];
  List<Course> _allCourses = [];
  List<String> _categories = ['Design', 'Marketing', 'Business', 'Development'];
  bool _isLoading = true;
  Timer? _refreshTimer;
  int _lastCourseCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'All';
    _loadCourses();
    // Auto refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _currentIndex == 0) {
        _loadCourses(isAutoRefresh: true);
      }
    });
  }

  Future<void> _loadCourses({bool isAutoRefresh = false}) async {
    if (!isAutoRefresh) {
      setState(() => _isLoading = true);
    }
    try {
      final results = await Future.wait([
        _courseService.getFeaturedCourses(),
        _courseService.getPopularCourses(
          category: _selectedCategory == 'All' ? null : _selectedCategory,
          search: _searchController.text.isEmpty
              ? null
              : _searchController.text,
        ),
        _courseService.getCourses(
          category: _selectedCategory == 'All' ? null : _selectedCategory,
          search: _searchController.text.isEmpty
              ? null
              : _searchController.text,
        ),
        _courseService.getCategories(),
      ]);
      final newAllCourses = results[2] as List<Course>;

      // Check if there are new courses (only show notification if count increases and it's an auto-refresh)
      if (isAutoRefresh &&
          _lastCourseCount > 0 &&
          newAllCourses.length > _lastCourseCount) {
        _showNewCourseBanner();
      }

      if (mounted) {
        setState(() {
          _featuredCourses = results[0] as List<Course>;
          _popularCourses = results[1] as List<Course>;
          _allCourses = newAllCourses;
          _lastCourseCount = newAllCourses.length;
          if ((results[3] as List<String>).isNotEmpty) {
            _categories = ['All', ...(results[3] as List<String>)];

            // If selected category is not in the new list, select 'All'
            if (!_categories.contains(_selectedCategory)) {
              _selectedCategory = 'All';
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading courses in HomeScreen: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  void _showNewCourseBanner() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
            SizedBox(width: 12),
            Text(
              'New course available! Check it out.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1665D8),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () => _loadCourses(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const CoursesScreen();
      case 2:
        return ChatScreen(
          onBackToHome: () => setState(() => _currentIndex = 0),
        );
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _loadCourses,
      child: SafeArea(
        child: Column(
          children: [
            // App bar like row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Color(0xFF1665D8),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Ajari',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1665D8),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      color: Color(0xFF1665D8),
                    ),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
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
                        onSubmitted: (value) => _loadCourses(),
                        decoration: const InputDecoration(
                          hintText: 'Search here',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      onPressed: _loadCourses,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Featured cards from API
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 140,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _featuredCourses.isEmpty
                    ? _buildDefaultFeaturedCards()
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _featuredCourses.length,
                        itemBuilder: (context, index) {
                          final course = _featuredCourses[index];
                          final colors = [
                            const Color(0xFFFF9800),
                            const Color(0xFF4CAF50),
                            const Color(0xFF1665D8),
                            const Color(0xFF9C27B0),
                          ];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < _featuredCourses.length - 1
                                  ? 12
                                  : 0,
                            ),
                            child: _featuredCard(
                              id: course.id,
                              title: course.title,
                              subtitle: '${course.lessonsCount} Lessons',
                              joined: '${course.joinedCount}+ Joined',
                              color: colors[index % colors.length],
                              imageUrl:
                                  course.imageUrl ??
                                  'https://i.pravatar.cc/100?img=${index + 1}',
                              lessonsCount: course.lessonsCount,
                              category: course.category,
                              description: course.description ?? '',
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 64,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            // when scroll ends, compute the nearest item and select it
                            if (notification is ScrollEndNotification) {
                              final metrics = notification.metrics;
                              const double itemWidth =
                                  140; // match _categoryCard width
                              const double itemSpacing =
                                  12; // right margin used
                              final double center =
                                  metrics.pixels +
                                  metrics.viewportDimension / 2;
                              int index = (center / (itemWidth + itemSpacing))
                                  .round();
                              final titles = _categories;
                              if (index < 0) index = 0;
                              if (index >= titles.length)
                                index = titles.length - 1;
                              final selected = titles[index];
                              if (_selectedCategory != selected) {
                                setState(() => _selectedCategory = selected);
                              }
                            }
                            return false;
                          },
                          child: ListView(
                            controller: _categoryScrollController,
                            scrollDirection: Axis.horizontal,
                            children: _categories.map((cat) {
                              final icons = {
                                'Design': Icons.brush,
                                'Marketing': Icons.campaign,
                                'Business': Icons.business_center,
                                'Development': Icons.code,
                                'Language': Icons.language,
                                'Data Science': Icons.bar_chart,
                                'Data': Icons.bar_chart,
                              };
                              return _categoryCard(
                                cat,
                                icon: icons[cat] ?? Icons.category,
                                selected: _selectedCategory == cat,
                                onTap: () {
                                  if (_selectedCategory != cat) {
                                    setState(() {
                                      _selectedCategory = cat;
                                      _isLoading =
                                          true; // Show loading immediately
                                    });
                                    _loadCourses();
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Popular Course',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _currentIndex = 1),
                            child: const Text(
                              'View more',
                              style: TextStyle(color: Color(0xFF1665D8)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _popularCourses.isEmpty
                            ? _buildDefaultPopularCourses()
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _popularCourses.length,
                                itemBuilder: (context, index) {
                                  final course = _popularCourses[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index < _popularCourses.length - 1
                                          ? 12
                                          : 0,
                                    ),
                                    child: _courseCard(
                                      id: course.id,
                                      title: course.title,
                                      instructor:
                                          course.instructor ?? 'Instructor',
                                      lessons: '${course.lessonsCount} lessons',
                                      lessonsCount: course.lessonsCount,
                                      imageUrl:
                                          course.imageUrl ??
                                          'https://picsum.photos/seed/${course.id}/260/140',
                                      category: course.category.toUpperCase(),
                                      rating: course.rating.toString(),
                                      reviewCount: course.reviewCount
                                          .toString(),
                                      joinedCount: '${course.joinedCount}+',
                                      duration: course.duration ?? '0h',
                                      description: course.description ?? '',
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 20),
                      // Recent Course section (from attachment)
                      const Text(
                        'Recent Course',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: _isLoading
                            ? [const Center(child: CircularProgressIndicator())]
                            : _allCourses.isEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 32.0,
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.search_off,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'No courses found for this category',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]
                            : _allCourses.map((course) {
                                return Column(
                                  children: [
                                    _recentCourseItem(
                                      id: course.id,
                                      category: course.category.toUpperCase(),
                                      title: course.title,
                                      contentCount:
                                          '${course.lessonsCount} Content',
                                      lessonsCount: course.lessonsCount,
                                      rating: course.rating.toString(),
                                      imageUrl:
                                          course.imageUrl ??
                                          'https://picsum.photos/seed/${course.id}/120',
                                      reviewCount: course.reviewCount
                                          .toString(),
                                      joinedCount: course.joinedCount
                                          .toString(),
                                      duration: course.duration ?? '0h',
                                      description: course.description ?? '',
                                    ),
                                    if (course != _allCourses.last)
                                      const Divider(height: 20),
                                  ],
                                );
                              }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultFeaturedCards() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _featuredCard(
          title: 'Principal UI Design',
          subtitle: '26 Courses',
          joined: '459+ Joined',
          color: const Color(0xFFFF9800),
          imageUrl: 'https://i.pravatar.cc/100?img=1',
          lessonsCount: 26,
          category: 'Design',
          description: 'Basic design principles for beginners',
        ),
        const SizedBox(width: 12),
        _featuredCard(
          title: 'Flutter Bootcamp',
          subtitle: '20 Courses',
          joined: '1K+ Joined',
          color: const Color(0xFF4CAF50),
          imageUrl: 'https://i.pravatar.cc/100?img=5',
          lessonsCount: 20,
          category: 'Development',
          description: 'Intensive flutter development course',
        ),
      ],
    );
  }

  Widget _buildDefaultPopularCourses() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _courseCard(
          title: 'UX Foundations',
          instructor: 'Instructor',
          lessons: '12 lessons',
          lessonsCount: 12,
          imageUrl: 'https://picsum.photos/seed/ux/260/140',
          category: 'DESIGN',
          rating: '4.5',
          reviewCount: '120',
          joinedCount: '459+',
          duration: '4h 24min',
          description: 'Learn the core foundations of UX design.',
        ),
        const SizedBox(width: 12),
        _courseCard(
          title: 'Product Design',
          instructor: 'Instructor',
          lessons: '8 lessons',
          lessonsCount: 8,
          imageUrl: 'https://picsum.photos/seed/product/260/140',
          category: 'DESIGN',
          rating: '4.2',
          reviewCount: '89',
          joinedCount: '320+',
          duration: '3h 10min',
          description: 'Advanced product design strategies.',
        ),
      ],
    );
  }

  Widget _categoryCard(
    String title, {
    IconData? icon,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    Color color = _categoryColor(title);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(color: color.withOpacity(0.9), width: 1.2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(selected ? 0.06 : 0.03),
              blurRadius: selected ? 8 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected ? color : color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon ?? Icons.category,
                color: selected ? Colors.white : color,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? color : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String title) {
    final key = title.toLowerCase();
    if (key.contains('design')) return const Color(0xFF1665D8);
    if (key.contains('marketing')) return const Color(0xFFFF9800);
    if (key.contains('business')) return const Color(0xFF4CAF50);
    if (key.contains('development')) return const Color(0xFF9C27B0);
    return const Color(0xFF1665D8);
  }

  Widget _featuredCard({
    int? id,
    required String title,
    required String subtitle,
    required String joined,
    required Color color,
    required String imageUrl,
    required int lessonsCount,
    required String category,
    String description = '',
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(
              id: id,
              title: title,
              category: category,
              rating: '4.8',
              reviewCount: '120',
              joinedCount: joined,
              duration: '4h',
              lessonsCount: lessonsCount,
              description: description,
            ),
          ),
        );
      },
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                  const Spacer(),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text('4.5', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 12),
                      Icon(Icons.access_time, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text('4h', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    joined,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseCard({
    int? id,
    required String title,
    required String instructor,
    required String lessons,
    required int lessonsCount,
    required String imageUrl,
    required String category,
    required String rating,
    required String reviewCount,
    required String joinedCount,
    required String duration,
    String description = '',
  }) {
    final double r = double.tryParse(rating) ?? 0.0;
    int full = r.floor();
    bool half = (r - full) >= 0.5;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(
              id: id,
              title: title,
              category: category,
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
        width: 200,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image with play button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 40,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1665D8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF1665D8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lessons,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(5, (i) {
                          if (i < full)
                            return const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 14,
                            );
                          if (i == full && half)
                            return const Icon(
                              Icons.star_half,
                              color: Colors.orange,
                              size: 14,
                            );
                          return const Icon(
                            Icons.star_border,
                            color: Colors.orange,
                            size: 14,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentCourseItem({
    int? id,
    required String category,
    required String title,
    required String contentCount,
    required int lessonsCount,
    required String rating,
    required String imageUrl,
    required String reviewCount,
    required String joinedCount,
    required String duration,
    String description = '',
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(
              id: id,
              title: title,
              category: category,
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
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                    category,
                    style: const TextStyle(
                      color: Color(0xFF1665D8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        contentCount,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star, color: Colors.orange, size: 14),
                      const SizedBox(width: 6),
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
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      selectedItemColor: const Color(0xFF1665D8),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Courses'),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
