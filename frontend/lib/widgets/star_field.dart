import 'package:flutter/material.dart';
import 'star.dart';
import 'glow_star.dart';

class StarField extends StatelessWidget {
  const StarField({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const Stack(
//       children: [
//         // ---------- Tiny Stars ----------

//         Star(top: 120, left: 55),
//         Star(top: 170, right: 80),
//         Star(top: 250, left: 90),
//         Star(top: 320, right: 50),
//         Star(top: 390, left: 70),
//         Star(top: 470, right: 95),
//         Star(top: 570, left: 40),
//         Star(top: 650, right: 35),
//         Star(top: 730, left: 80),
//         Star(top: 820, right: 60),

//         // ---------- Glowing Stars ----------

//         GlowStar(
//           top: 300,
//           left: 200,
//           size: 5,
//         ),

//         GlowStar(
//           top: 420,
//           left: 130,
//           size: 6,
//         ),

//         GlowStar(
//           top: 610,
//           right: 90,
//           size: 5,
//         ),

//         GlowStar(
//           top: 720,
//           left: 160,
//           size: 6,
//         ),

//         GlowStar(
//           top: 790,
//           right: 75,
//           size: 5,
//         ),
//       ],
//     );
//   }
// }
    @override
    Widget build(BuildContext context) {
     return const Stack(
       children: [

          Star(
            top: 120,
            left: 45,
          ),

          Star(
            top: 170,
            right: 70,
          ),

          Star(
            top: 250,
            left: 120,
          ),

          Star(
            top: 320,
            right: 40,
          ),

          Star(
            top: 420,
            right: 100,
          ),

          Star(
            top: 350,
            left: 60,
          ),

          Star(
            top: 520,
            left: 35,
          ),

          Star(
            top: 620,
            left: 77,
          ),
          
          Star(
            top: 720,
            left: 75,
          ),
          
          Star(
            top: 570,
            right: 25,
          ),
          
          Star(
            top: 850,
            right: 175,
          ),

          Star(
            top: 870,
            left : 105,
          ),

          GlowStar(
            top: 130,
            left: 200,
            size: 5,
          ),

          GlowStar(
            top: 390,
            left: 150,
            size: 5,
          ),

          GlowStar(
            top: 300,
            right: 120,
            size: 4,
          ),

          GlowStar(
            top: 610,
            right: 100,
            size: 5,
          ),

          GlowStar(
            top: 650,
            right: 200,
            size: 5,
          ),

          GlowStar(
            top: 800,
            right: 250,
            size: 5,
          ),

          GlowStar(
            top: 760,
            right: 85,
            size: 4,
          ),
       ],
     );
  }
}