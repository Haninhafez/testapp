import 'package:flutter/material.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key, required this.tag});
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Details')),
      body: Column(
        children: [
          Hero(
            curve: Curves.easeInExpo,
            tag: tag, // نفس الـ tag بالظبط
            child: Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(color: Colors.blue),
              child: const Icon(
                Icons.play_circle,
                color: Colors.white,
                size: 80,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Flutter Basics'),
          ),
        ],
      ),
    );
  }
}

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(context: context, tag: 'index-$index');
        },
      ),
    );
  }

  Row Card({BuildContext? context, required String tag}) {
    return Row(
      children: [
        Hero(
          tag: tag,
          curve: Curves.easeInBack,

          // نفس الـ tag لازم يكون في الصفحتين
          child: GestureDetector(
            onTap: () => Navigator.push(
              context!,
              MaterialPageRoute(
                builder: (context) => CourseDetailsScreen(tag: tag),
              ),
            ),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_circle, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text('Flutter Basics'),
      ],
    );
  }
}

class PulseBox extends StatefulWidget {
  const PulseBox({super.key});

  @override
  State<PulseBox> createState() => _PulseBoxState();
}

class _PulseBoxState extends State<PulseBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnimation = Tween<double>(begin: 100, end: 200).animate(_controller);
  }

  void _toggle() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) => GestureDetector(
        onTap: _toggle,
        child: Container(
          width: _widthAnimation.value,
          color: Colors.red,
          height: 100,
        ),
      ),
    );
  }
}

class ImplicitAnimation extends StatefulWidget {
  const ImplicitAnimation({super.key});

  @override
  State<ImplicitAnimation> createState() => _ImplicitAnimationState();
}

class _ImplicitAnimationState extends State<ImplicitAnimation> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        height: _expanded ? 200 : 100,
        width: _expanded ? 200 : 100,
        decoration: BoxDecoration(
          color: !_expanded ? Colors.blue : Colors.cyan,
          shape: _expanded ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}

class CounterSwitcher extends StatefulWidget {
  const CounterSwitcher({super.key});

  @override
  State<CounterSwitcher> createState() => _CounterSwitcherState();
}

class _CounterSwitcherState extends State<CounterSwitcher> {
  bool isactive = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => isactive = !isactive),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isactive ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isactive),
              color: Colors.red,
              size: 50,
            ),
          ),
        ),
      ],
    );
  }
}

class RotatingIcon extends StatefulWidget {
  const RotatingIcon({super.key});

  @override
  State<RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon> {
  double end = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => end = end == 0 ? .75 : 0),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: end),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return LinearProgressIndicator(
            value: value,

            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          );
        },
      ),
    );
  }
}

class ManualBox extends StatefulWidget {
  const ManualBox({super.key});

  @override
  State<ManualBox> createState() => _ManualBoxState();
}

class _ManualBoxState extends State<ManualBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
    // لو الأنيميشن شغالة فعلاً (forward/reverse)، متعملش حاجة
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(opacity: _controller.value, child: child);
        },
        child: Container(width: 100, height: 100, color: Colors.blue),
      ),
    );
  }
}

class MultiTweenBox extends StatefulWidget {
  const MultiTweenBox({super.key});

  @override
  State<MultiTweenBox> createState() => _MultiTweenBoxState();
}

class _MultiTweenBoxState extends State<MultiTweenBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sizeAnimation;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _controller.repeat(reverse: true);

    _sizeAnimation = Tween<double>(
      begin: 50,
      end: 250,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInExpo));

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.blueGrey,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.stop();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: _sizeAnimation.value,
            height: _sizeAnimation.value,
            color: _colorAnimation.value,
          );
        },
      ),
    );
  }
}

class ColorAndCurveDemo extends StatefulWidget {
  const ColorAndCurveDemo({super.key});

  @override
  State<ColorAndCurveDemo> createState() => _ColorAndCurveDemoState();
}

class _ColorAndCurveDemoState extends State<ColorAndCurveDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _colorAnimation;
  late final Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // الخطوة 1: نلف الـ controller بـ CurvedAnimation
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // الخطوة 2: نستخدم الـ curved animation دي مع Tween مختلفين
    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(curved);

    _sizeAnimation = Tween<double>(begin: 50, end: 150).animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _controller.status == AnimationStatus.completed
          ? _controller.reverse()
          : _controller.forward(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: _sizeAnimation.value,
            height: _sizeAnimation.value,
            color: _colorAnimation.value,
          );
        },
      ),
    );
  }
}

class RotatingBox extends AnimatedWidget {
  const RotatingBox({
    super.key,
    required Animation<double> animation,
    required this.child,
  }) : super(listenable: animation);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Transform.rotate(angle: animation.value * 6.28319, child: child);
  }
}

// الاستخدام:
class TransitionsDemo extends StatefulWidget {
  const TransitionsDemo({super.key});

  @override
  State<TransitionsDemo> createState() => _TransitionsDemoState();
}

class _TransitionsDemoState extends State<TransitionsDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // SlideTransition محتاج Animation<Offset> مش double مباشرة
    _slideAnimation = Tween<Offset>(
      begin: const Offset(10, 0), // برة الشاشة من الشمال
      end: Offset.zero, // مكانه الطبيعي
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _controller.status == AnimationStatus.completed
          ? Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SlideTransition(
                  position: _slideAnimation,
                  child: SecondScreen(),
                ),
              ),
            )
          : _controller.forward(),
      child: Column(
        children: [
          FadeTransition(
            opacity: _controller, // Controller نفسه Animation<double>
            child: const Text('Fading Text'),
          ),
          ScaleTransition(
            scale: _controller,
            child: const FlutterLogo(size: 80),
          ),
          RotationTransition(
            turns: _controller,
            child: const Icon(Icons.settings, size: 60),
          ),
        ],
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go Back!'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class TransitionHeart extends StatefulWidget {
  const TransitionHeart({super.key});

  @override
  State<TransitionHeart> createState() => _TransitionHeartState();
}

class _TransitionHeartState extends State<TransitionHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(_controller);
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(_controller);
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _controller.status == AnimationStatus.completed
          ? _controller.reverse()
          : _controller.forward(),
      child: RotationTransition(
        turns: _rotationAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: const Icon(Icons.favorite, color: Colors.red, size: 50),
        ),
      ),
    );
  }
}

class ExpandableSection extends StatefulWidget {
  const ExpandableSection({super.key});

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            children: [
              const Text('What is Flutter?'),
              const Spacer(),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0, // من غير Controller خالص
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(height: 0, width: double.infinity),
          secondChild: const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Flutter is a UI toolkit by Google...'),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
}

class StaggeredListDemo extends StatefulWidget {
  const StaggeredListDemo({super.key});

  @override
  State<StaggeredListDemo> createState() => _StaggeredListDemoState();
}

class _StaggeredListDemoState extends State<StaggeredListDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<String> _items = List.generate(6, (i) => 'Course ${i + 1}');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // مدة كافية لكل الليستة
    );
    _controller.forward(); // يبدأ تلقائي أول ما الشاشة تفتح
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staggered List')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return StaggeredListItem(
            index: index,
            animation: _controller, // نفس الـ Controller لكل العناصر
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(_items[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

// نفس الـ widget من قبل كده، من غير تغيير
class StaggeredListItem extends StatelessWidget {
  const StaggeredListItem({
    super.key,
    required this.index,
    required this.animation,
    required this.child,
  });

  final int index;
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delayedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(
        (index * 0.1).clamp(0.0, 1.0),
        ((index * 0.1) + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: delayedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(delayedAnimation),
        child: child,
      ),
    );
  }
}

class AddToFavorite extends StatefulWidget {
  const AddToFavorite({super.key});

  @override
  State<AddToFavorite> createState() => _AddToFavoriteState();
}

class _AddToFavoriteState extends State<AddToFavorite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool isFavorite = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });

    _scaleAnimation = Tween<double>(begin: 1.0, end: 5).animate(_controller);
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        isFavorite = !isFavorite;
        _controller.forward(from: 0.0);
      }),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedSwitcher(
          duration: const Duration(seconds: 1),
         
           
        child: isFavorite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border),
          key: ValueKey(isFavorite),
        ),
      ),
    );
  }
}
