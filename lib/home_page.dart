import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  final List<Map<String, String>> bibleQuotes = [
    {
      'quote':
          'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
      'reference': 'John 3:16',
    },
    {
      'quote': 'I can do all things through Christ who strengthens me.',
      'reference': 'Philippians 4:13',
    },
    {
      'quote':
          'Trust in the Lord with all your heart and lean not on your own understanding.',
      'reference': 'Proverbs 3:5',
    },
    {
      'quote': 'The Lord is my shepherd; I shall not want.',
      'reference': 'Psalm 23:1',
    },
    {
      'quote':
          'Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
      'reference': 'Joshua 1:9',
    },
    {
      'quote':
          'And we know that in all things God works for the good of those who love him.',
      'reference': 'Romans 8:28',
    },
    {
      'quote': 'Cast all your anxiety on him because he cares for you.',
      'reference': '1 Peter 5:7',
    },
    {
      'quote':
          'The Lord is close to the brokenhearted and saves those who are crushed in spirit.',
      'reference': 'Psalm 34:18',
    },
    {
      'quote':
          'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.',
      'reference': 'Philippians 4:6',
    },
    {
      'quote':
          'But those who hope in the Lord will renew their strength. They will soar on wings like eagles.',
      'reference': 'Isaiah 40:31',
    },
    {
      'quote':
          'The Lord himself goes before you and will be with you; he will never leave you nor forsake you.',
      'reference': 'Deuteronomy 31:8',
    },
    {
      'quote':
          'Do not worry about tomorrow, for tomorrow will worry about itself. Each day has enough trouble of its own.',
      'reference': 'Matthew 6:34',
    },
    {
      'quote':
          'Come to me, all you who are weary and burdened, and I will give you rest.',
      'reference': 'Matthew 11:28',
    },
    {
      'quote':
          'The Lord is my light and my salvation—whom shall I fear? The Lord is the stronghold of my life—of whom shall I be afraid?',
      'reference': 'Psalm 27:1',
    },
    {
      'quote': 'If God is for us, who can be against us?',
      'reference': 'Romans 8:31',
    },
    {
      'quote':
          'For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.',
      'reference': 'Jeremiah 29:11',
    },
    {
      'quote':
          'The Lord is gracious and compassionate, slow to anger and rich in love.',
      'reference': 'Psalm 145:8',
    },
    {
      'quote':
          'God is our refuge and strength, an ever-present help in trouble.',
      'reference': 'Psalm 46:1',
    },
    {
      'quote':
          'Taste and see that the Lord is good; blessed is the one who takes refuge in him.',
      'reference': 'Psalm 34:8',
    },
    {
      'quote':
          'The name of the Lord is a fortified tower; the righteous run to it and are safe.',
      'reference': 'Proverbs 18:10',
    },
    {
      'quote':
          'Peace I leave with you; my peace I give you. I do not give to you as the world gives. Do not let your hearts be troubled and do not be afraid.',
      'reference': 'John 14:27',
    },
    {
      'quote':
          'The Lord bless you and keep you; the Lord make his face shine on you and be gracious to you.',
      'reference': 'Numbers 6:24-25',
    },
    {
      'quote': 'Rejoice in the Lord always. I will say it again: Rejoice!',
      'reference': 'Philippians 4:4',
    },
    {
      'quote':
          'Let us not become weary in doing good, for at the proper time we will reap a harvest if we do not give up.',
      'reference': 'Galatians 6:9',
    },
    {
      'quote':
          'The Lord your God is in your midst, a mighty one who will save; he will rejoice over you with gladness.',
      'reference': 'Zephaniah 3:17',
    },
    {
      'quote':
          'In all your ways acknowledge him, and he will make straight your paths.',
      'reference': 'Proverbs 3:6',
    },
    {
      'quote':
          'With man this is impossible, but with God all things are possible.',
      'reference': 'Matthew 19:26',
    },
    {
      'quote':
          'This is the day that the Lord has made; let us rejoice and be glad in it.',
      'reference': 'Psalm 118:24',
    },
    {'quote': 'Be still, and know that I am God.', 'reference': 'Psalm 46:10'},
    {
      'quote':
          'Give thanks to the Lord, for he is good; his love endures forever.',
      'reference': 'Psalm 107:1',
    },
  ];

  late Map<String, String> randomQuote;

  @override
  void initState() {
    super.initState();
    randomQuote = bibleQuotes[Random().nextInt(bibleQuotes.length)];
  }

  // When the user signs out, GoRouter's refreshListenable will handle the redirect automatically.
  Future<void> _signOut() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0D0D0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'WELCOME',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _signOut,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.logout, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.05),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.go('/home/weather');
                      },
                      child: const FeatureBox(
                        icon: Icons.cloud_outlined,
                        label: 'Weather',
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.go('/home/journal');
                      },
                      child: const FeatureBox(
                        icon: Icons.book_outlined,
                        label: 'Diary',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'SPECIAL FOR YOU',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.format_quote),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bible Quotes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  randomQuote['quote']!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '- ${randomQuote['reference']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureBox extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureBox({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF252528),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 80),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
