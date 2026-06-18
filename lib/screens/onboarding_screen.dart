// import 'package:flutter/material.dart';
// import '../routes/app_routes.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({Key? key}) : super(key: key);

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _controller = PageController();
//   int _currentIndex = 0;

//   void _next() {
//     if (_currentIndex == 2) {
//       Navigator.pushReplacementNamed(context, AppRoutes.login);
//     } else {
//       _controller.nextPage(
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _skip() {
//     Navigator.pushReplacementNamed(context, AppRoutes.login);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             /// SKIP BUTTON
//             Align(
//               alignment: Alignment.topRight,
//               child: TextButton(
//                 onPressed: _skip,
//                 child: const Text(
//                   "SKIP",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),

//             Expanded(
//               child: PageView(
//                 controller: _controller,
//                 onPageChanged: (index) {
//                   setState(() {
//                     _currentIndex = index;
//                   });
//                 },
//                 children: const [PageOne(), PageTwo(), PageThree()],
//               ),
//             ),

//             /// INDICATOR
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(
//                 3,
//                 (index) => Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 4),
//                   width: _currentIndex == index ? 24 : 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: _currentIndex == index
//                         ? const Color(0xFFE53935)
//                         : Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 25),

//             /// BUTTON
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 60,
//                 child: ElevatedButton(
//                   onPressed: _next,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFE53935),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(40),
//                     ),
//                   ),
//                   child: Text(
//                     _currentIndex == 2 ? "GET STARTED" : "NEXT →",
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// PAGE 1
// class PageTwo extends StatelessWidget {
//   const PageTwo({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(30),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             height: 220,
//             width: 220,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: const Icon(
//               Icons.qr_code_scanner,
//               size: 90,
//               color: Color(0xFFE53935),
//             ),
//           ),

//           const SizedBox(height: 50),

//           const Text(
//             "Scan & Enter Gym Easily",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 20),

//           const Text(
//             "Use QR code to scan and enter the gym quickly without manual attendance.",
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// PAGE 2
// class PageThree extends StatelessWidget {
//   const PageThree({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),

//             Container(
//               height: 200,
//               width: 200,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: const Icon(
//                 Icons.access_time,
//                 size: 80,
//                 color: Color(0xFFE53935),
//               ),
//             ),

//             const SizedBox(height: 40),

//             const Text(
//               "Book Your Time Slot",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 15),

//             const Text(
//               "Choose your preferred gym timing and avoid peak hour crowd.",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
//             ),

//             const SizedBox(height: 30),

//             Row(
//               children: [
//                 Expanded(
//                   child: _timeCard("MORNING", "06:00 AM", "Low Traffic"),
//                 ),
//                 const SizedBox(width: 15),
//                 Expanded(child: _timeCard("EVENING", "05:30 PM", "Peak Hour")),
//               ],
//             ),

//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _timeCard(title, time, status) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(color: Colors.red)),
//           const SizedBox(height: 6),
//           Text(
//             time,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//           const SizedBox(height: 8),
//           Text(status, style: const TextStyle(color: Colors.grey)),
//         ],
//       ),
//     );
//   }
// }

// /// PAGE 3
// class PageOne extends StatelessWidget {
//   const PageOne({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(30),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             height: 220,
//             width: 220,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: const Icon(
//               Icons.fitness_center,
//               size: 90,
//               color: Color(0xFFE53935),
//             ),
//           ),

//           const SizedBox(height: 50),

//           const Text(
//             "Track Membership & Trainer",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 20),

//           const Text(
//             "View trainer details, membership plan, expiry date and payment status.",
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
//           ),
//         ],
//       ),
//     );
//   }
// }
