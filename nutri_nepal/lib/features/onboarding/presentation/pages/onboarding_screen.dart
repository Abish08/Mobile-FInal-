import 'package:flutter/material.dart';
import 'package:nutri_nepal/features/auth/presentation/pages/login_screen.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView ({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData =[
    {
      'icon': Icons.restaurant,
      'title':'Track your Nutrition',
      'description':'Log meals,track macros, and stay on top of your daily calories.',
    },
    {
      'icon':Icons.fitness_center,
      'title':'Personalized Workouts',
      'description':'Get expercise plans tailored to your fitness goals and health conditons',

    },
    {
      'icon':Icons.show_chart,
      'title':'Monitor Your Progress',
      'description':'Track weight, view charts, and celebrate your health milestones'
    },
  ];
  void _onPageChanged(int page){
    setState(() {
      _currentPage = page;
    });
  }
  
  void _nextOrFinish(){
    if(_currentPage< _onboardingData.length-1){
      _pageController.nextPage(duration: const Duration(milliseconds: 300),
       curve: Curves.easeInOut,
      );
    }else{
      Navigator.pushReplacement(context,
       MaterialPageRoute(builder: (context) => const LoginScreen()),
       );
    }
  }
  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index){
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _onboardingData[index]['icon'] as IconData,
                          size: 100,
                          color: const Color(0xFF1B4332),
                        ),
                        const SizedBox(height: 32),
                        Text(
                         _onboardingData[index]['title'] as String,
                         style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                         ),
                         textAlign: TextAlign.center,

                        ),
                        const SizedBox(height: 16,),
                        Text(
                          _onboardingData[index]['description']as String,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    );
                    

                },
                ),
            ),
            Padding(padding: 
            const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(duration: const Duration(microseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage ==index
                    ?const Color(0xFF1B4332)
                   :const Color(0xFF1B4332).withOpacity(0.3),
                   borderRadius: BorderRadius.circular(4),


                    ),
                    ),
                  ),
                ),
                const SizedBox(height: 32,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextOrFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB85C00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
            ),



          ],
        ),
        ),
    );
  }
}
