import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadRemindersPage extends StatelessWidget {
  UploadRemindersPage({super.key});

  // Parsed reminders data
  static const List<Map<String, String>> coping = [
    {
      "title": "Attend a Support Group Meeting (e.g., NA, AA)",
      "content": "Connecting with others in recovery helps reduce isolation and provides accountability."
    },
    {
      "title": "Call a Sponsor or Trusted Recovery Friend",
      "content": "Having someone to talk to during tough moments can prevent relapse."
    },
    {
      "title": "Practice the HALT Check (Hungry, Angry, Lonely, Tired)",
      "content": "Recognizing these states early helps avoid impulsive, risky behavior."
    },
    {
      "title": "Use a Craving Journal",
      "content": "Write down what triggered the craving, how you felt, and how you coped without using."
    },
    {
      "title": "Create a Safe, Drug-Free Environment",
      "content": "Remove paraphernalia and avoid places linked to past use."
    },
    {
      "title": "Focus on One Day at a Time",
      "content": "Thinking long-term can be overwhelming—just stay clean today."
    },
    {
      "title": "Exercise to Channel Energy",
      "content": "Work out to release built-up tension and boost feel-good chemicals naturally."
    },
    {
      "title": "Practice Deep Breathing or Mindfulness",
      "content": "Helps ground you during moments of anxiety or craving."
    },
    {
      "title": "Have a Distraction List Ready",
      "content": "Activities like reading, walking, puzzles, or cooking can shift focus from cravings."
    },
    {
      "title": "Listen to Recovery Podcasts or Audiobooks",
      "content": "Hearing others’ stories can inspire and remind you why you’re staying clean."
    },
    {
      "title": "Develop a Daily Routine",
      "content": "Structure provides stability and reduces idle time that can lead to temptation."
    },
    {
      "title": "Celebrate Small Victories",
      "content": "Acknowledge clean days, completed tasks, or resisted cravings to stay motivated."
    },
    {
      "title": "Volunteer or Help Others",
      "content": "Giving back can strengthen your purpose and reinforce recovery."
    },
    {
      "title": "Use Positive Affirmations",
      "content": "Repeat phrases like “I am stronger than my addiction” to build self-belief."
    },
    {
      "title": "Identify and Avoid Triggers",
      "content": "Stay away from people, places, or events linked to drug use—especially early in recovery."
    },
    {
      "title": "Replace Old Habits with Healthy Ones",
      "content": "Trade using for painting, running, writing, or other positive outlets."
    },
    {
      "title": "Seek Professional Counseling",
      "content": "Therapists trained in addiction can help you work through trauma, shame, or stress."
    },
    {
      "title": "Create a Recovery Vision Board",
      "content": "Visualize your goals and the life you're building beyond addiction."
    },
    {
      "title": "Take Up a New Hobby",
      "content": "Learn something new to engage your mind and find joy in sober activities."
    },
    {
      "title": "Set Boundaries with Toxic People",
      "content": "Protect your recovery by limiting contact with those who don’t support it."
    },
    {
      "title": "Use Prayer or Spiritual Reflection",
      "content": "Many find strength in a higher power or personal belief system."
    },
    {
      "title": "Keep a Recovery Gratitude Journal",
      "content": "List what you’re thankful for each day to shift focus from what you’ve lost to what you’re gaining."
    },
    {
      "title": "Attend Relapse Prevention Workshops",
      "content": "Equip yourself with tools and strategies to stay on track long-term."
    },
    {
      "title": "Keep Emergency Coping Cards",
      "content": "Write quick coping reminders or motivational quotes to keep with you."
    },
    {
      "title": "Limit Social Media and News Exposure",
      "content": "Minimize negativity and comparison triggers that might increase stress."
    },
    {
      "title": "Talk About Your Feelings Honestly",
      "content": "Don’t bottle things up—share with someone safe before it builds up."
    },
    {
      "title": "Have a Relapse Plan Ready",
      "content": "Know who to call and what to do if you feel like you might slip."
    },
    {
      "title": "Engage in Spiritual or Religious Activities",
      "content": "This can give deeper meaning and structure to your recovery journey."
    },
    {
      "title": "Practice Self-Compassion",
      "content": "You’re not your mistakes. Be kind to yourself when things get hard."
    },
    {
      "title": "Visualize Your Future Self",
      "content": "Picture the person you’re becoming: healthy, strong, and free from addiction."
    },
  ];


  final List<Map<String, String>> article = [
    {
      "title": "Triggers are Normal, But Here’s How to Handle Them",
      "content": "In recovery, experiencing triggers is not a sign of weakness—it’s a sign your brain is healing and adjusting. Triggers can be people, places, emotions, or memories tied to past substance use. Handling them starts with awareness. Learn to identify what sets you off, and prepare a plan: use grounding techniques like deep breathing, distraction methods like a walk or a phone call, and, most importantly, reach out for support. Over time, you'll respond to triggers with control, not compulsion."
    },
    {
      "title": "Why Relapse Happens and How to Prevent It",
      "content": "Relapse doesn’t mean failure—it means something needs attention. It often follows emotional distress, social pressure, or lack of structure. Preventing relapse involves building awareness of your personal warning signs: skipping support meetings, feeling overwhelmed, or isolating. Create a relapse prevention plan, stay engaged with your support network, and keep your goals visible. The path to recovery isn’t always straight, but every step teaches resilience."
    },
    {
      "title": "Coping with Stress Without Drugs: Alternative Strategies",
      "content": "Stress is one of the biggest challenges in recovery—but you don’t need substances to cope. Try building a stress toolkit: include practices like deep breathing, journaling, physical activity, and music. Break down tasks to avoid overwhelm and give yourself permission to rest. Talk about what you're going through—whether with a friend, therapist, or support group. The more tools you have, the less tempting old habits will feel."
    },
    {
      "title": "Therapy vs. Self-Help: Finding the Right Support for Your Journey",
      "content": "Recovery isn’t one-size-fits-all. Therapy offers structured, professional guidance that helps address underlying trauma and build coping skills. Self-help methods—like books, podcasts, or support groups—can be more flexible and empowering. You don’t have to choose one over the other; many people benefit from both. The most important thing is to keep moving forward and to find support that aligns with your needs and personality."
    },
    {
      "title": "Turning Pain into Purpose: Finding Meaning in Recovery",
      "content": "The pain of addiction doesn’t disappear—but it can be transformed. Many people in recovery discover strength and purpose by helping others, sharing their story, or pursuing new goals. Whether it’s returning to school, volunteering, or becoming a sponsor, these acts provide a sense of direction and fulfillment. Your past doesn’t define you—it equips you to make a difference."
    },
    {
      "title": "Real Stories of Recovery: How People Overcame Drug Addiction",
      "content": "Recovery looks different for everyone. One person might credit rehab and therapy, another might say peer support groups saved their life. Some found hope in faith, others in fitness or art. What these stories share is courage—the daily decision to keep going. They prove that addiction doesn’t have the final word. Every recovered life is a testament that healing is possible, and change is real."
    },
    {
      "title": "Life After Addiction: How to Rebuild and Stay on Track",
      "content": "Life after addiction can be a time of discovery and rebuilding. Start with structure: regular routines help reduce stress and increase stability. Focus on healthy habits—nutrition, exercise, sleep—and reconnect with things that bring you joy. Relationships may need time to heal, but honesty and effort go a long way. Continue support, whether through groups or counseling. Recovery doesn’t end—it evolves. And so do you."
    },
    {
      "title": "How to Rebuild Trust with Loved Ones After Addiction",
      "content": "Addiction can damage relationships, but recovery offers a chance to rebuild. Start with honesty—own your past actions without excuses. Follow through on promises and show consistency in your behavior. Understand that trust takes time, and let your actions speak louder than words. Patience, humility, and communication are your greatest tools in healing those bonds."
    },
    {
      "title": "What to Do When Cravings Hit",
      "content": "Cravings can feel overwhelming, but they do pass. When they hit, pause and acknowledge the feeling—don’t ignore it. Distract yourself with an activity, call a support person, or practice deep breathing. Remind yourself why you chose recovery. Over time, the intensity of cravings decreases, and your ability to ride them out gets stronger."
    },
    {
      "title": "Building a Sober Support Network",
      "content": "You don’t have to go it alone. A strong sober support network can make a big difference in your recovery. This might include family, sober friends, recovery groups, therapists, or online communities. Surround yourself with people who uplift you and respect your journey. Healthy connections help you stay grounded and motivated."
    },
    {
      "title": "Understanding the Root Causes of Addiction",
      "content": "Addiction isn’t just about substances—it’s often rooted in trauma, mental health issues, or emotional pain. Understanding these root causes through therapy or self-reflection is key to healing. When you address the \"why\" behind the addiction, recovery becomes more sustainable and meaningful."
    },
    {
      "title": "The Power of Routine in Recovery",
      "content": "Creating a daily routine brings structure, stability, and purpose to your life. It reduces the chaos that often fuels relapse and helps you build healthy habits. Start simple: set a wake-up time, plan your meals, and schedule time for self-care and reflection. A steady routine creates a strong foundation for long-term sobriety."
    },
    {
      "title": "Mindfulness in Recovery: Staying Present",
      "content": "Mindfulness—the practice of staying present in the moment—can be a powerful recovery tool. It helps reduce anxiety, manage cravings, and increase emotional awareness. Start with short daily practices like mindful breathing or body scans. The more present you are, the less power the past and future hold over you."
    },
    {
      "title": "The Role of Gratitude in Healing",
      "content": "Gratitude shifts your focus from what's missing to what’s meaningful. In recovery, this mindset can be transformational. Keep a gratitude journal, thank people who support you, and take time to notice small wins. Gratitude keeps you grounded and reinforces the progress you’re making."
    },
    {
      "title": "How to Deal with Shame in Recovery",
      "content": "Shame is common after addiction, but it doesn't have to define you. Talk about it in therapy or with someone you trust. Remember that recovery is about growth, not punishment. Replace self-criticism with self-compassion. You are more than your mistakes—you are your efforts, your courage, and your future."
    },
    {
      "title": "Healthy Habits That Support Sobriety",
      "content": "Your body and mind are healing—support them with healthy habits. Eat nutritious meals, drink water, sleep regularly, and stay physically active. These habits improve mood, reduce cravings, and give you a sense of control. Recovery thrives in a healthy environment."
    },
    {
      "title": "Setting Boundaries in Recovery",
      "content": "Boundaries protect your peace and your progress. Learn to say no to people or situations that could threaten your sobriety. Boundaries might mean avoiding certain friends, declining invitations, or limiting stress. Clear, respectful boundaries are a sign of strength—not selfishness."
    },
    {
      "title": "When Friends or Family Don’t Understand Your Recovery",
      "content": "Not everyone will get it—and that’s okay. Focus on those who do, and try to educate those who don’t with patience and boundaries. You don’t owe anyone a justification, but you deserve respect. Your recovery is for you, not for their approval."
    },
    {
      "title": "Journaling as a Recovery Tool",
      "content": "Writing down your thoughts can help you process emotions, track triggers, and celebrate growth. It creates a safe space to explore your recovery without judgment. Whether it’s daily entries, lists of wins, or letters you’ll never send—journaling helps you stay honest with yourself."
    },
    {
      "title": "How to Celebrate Sobriety Milestones",
      "content": "Sobriety anniversaries, 30-day streaks, or even tough days you overcame—celebrate them! These moments matter. Treat yourself, share the win with friends, or reflect on your journey. Celebrating milestones keeps you motivated and reminds you of how far you've come."
    },
    {
      "title": "Relapse Doesn’t Erase Your Progress",
      "content": "If relapse happens, don’t throw away your progress—it still counts. One slip doesn’t undo months of growth. Take it as a lesson, recommit, and reach out for support. You're not starting over—you're continuing wiser and stronger than before."
    },
    {
      "title": "Staying Sober During the Holidays",
      "content": "Holidays can be joyful but also full of triggers. Plan ahead: bring a sober friend to gatherings, have an exit strategy, and keep a non-alcoholic drink in hand. Focus on connection, not consumption. With preparation, you can enjoy the holidays your way—clear, present, and proud."
    },
    {
      "title": "How Exercise Supports Recovery",
      "content": "Exercise isn’t just about fitness—it boosts mood, reduces stress, and improves sleep. It also gives a healthy outlet for frustration or anxiety. Whether it's a walk, a run, or dancing in your room, moving your body can become a powerful part of your recovery toolkit."
    },
    {
      "title": "Learning to Forgive Yourself",
      "content": "Self-forgiveness is one of the hardest parts of recovery—but also one of the most freeing. You made mistakes, yes. But you're making amends, growing, and choosing a better path. Let go of the constant guilt. You deserve to be at peace with yourself."
    },
    {
      "title": "Finding Joy in Sobriety",
      "content": "Sobriety doesn’t mean life becomes dull—it often becomes richer. As your mind clears, you may rediscover old passions or find new ones. Laughter, creativity, meaningful relationships—all feel more real. Recovery opens the door to genuine joy."
    },
    {
      "title": "The Importance of Sleep in Recovery",
      "content": "Sleep restores both the brain and body—especially after substance use. Insomnia is common in early recovery, but good sleep hygiene can help: go to bed at the same time, avoid screens before bed, and limit caffeine. Rested bodies heal faster and think clearer."
    },
    {
      "title": "Creating a Safe Home Environment for Recovery",
      "content": "Your surroundings matter. Declutter, remove any reminders of substance use, and create a calm, peaceful space. Add things that support you: books, art, calming scents, affirmations. A safe home supports a safe mind."
    },
    {
      "title": "How Volunteering Can Boost Your Recovery",
      "content": "Giving back reminds you of your value. Volunteering connects you with others, provides structure, and boosts self-esteem. Whether it's helping in a recovery center, mentoring, or supporting a cause—service heals in both directions."
    },
    {
      "title": "Staying Sober in a Social World",
      "content": "Social life doesn’t end in sobriety—it just changes. Learn how to say no with confidence, find sober-friendly activities, and build connections that don’t revolve around substances. You’ll discover that real connection doesn't need intoxication."
    },
    {
      "title": "Dealing with Boredom in Early Recovery",
      "content": "Boredom can be a hidden trigger. Fill your time with new hobbies, physical activity, learning opportunities, or connection. Early recovery is the perfect time to explore who you are without substances. Life has more to offer—you just have to try new things."
    },
  ];

  final List<Map<String, String>> motivational = [
    {
      "quote": "Believe you can and you're halfway there.",
      "author": "Theodore Roosevelt"
    },
    {
      "quote": "Do not wait for the perfect moment. Take the moment and make it perfect.",
      "author": "Zoey Sayward"
    },
    {
      "quote": "Success is not final, failure is not fatal: It is the courage to continue that counts.",
      "author": "Winston Churchill"
    },
    {
      "quote": "Hardships often prepare ordinary people for an extraordinary destiny.",
      "author": "C.S. Lewis"
    },
    {
      "quote": "It does not matter how slowly you go as long as you do not stop.",
      "author": "Confucius"
    },
    {
      "quote": "The only way to do great work is to love what you do.",
      "author": "Steve Jobs"
    },
    {
      "quote": "You are never too old to set another goal or to dream a new dream.",
      "author": "C.S. Lewis"
    },
    {
      "quote": "Don’t watch the clock; do what it does. Keep going.",
      "author": "Sam Levenson"
    },
    {
      "quote": "Act as if what you do makes a difference. It does.",
      "author": "William James"
    },
    {
      "quote": "You don’t have to see the whole staircase, just take the first step.",
      "author": "Martin Luther King Jr."
    },
    {
      "quote": "Start where you are. Use what you have. Do what you can.",
      "author": "Arthur Ashe"
    },
    {
      "quote": "The comeback is always stronger than the setback.",
      "author": "Unknown"
    },
    {
      "quote": "Fall seven times, stand up eight.",
      "author": "Japanese Proverb"
    },
    {
      "quote": "You are stronger than you think.",
      "author": "Unknown"
    },
    {
      "quote": "Happiness is not something ready made. It comes from your own actions.",
      "author": "Dalai Lama"
    },
    {
      "quote": "If you're going through hell, keep going.",
      "author": "Winston Churchill"
    },
    {
      "quote": "Be yourself; everyone else is already taken.",
      "author": "Oscar Wilde"
    },
    {
      "quote": "Your present circumstances don’t determine where you can go; they merely determine where you start.",
      "author": "Nido Qubein"
    },
    {
      "quote": "Push yourself, because no one else is going to do it for you.",
      "author": "Unknown"
    },
    {
      "quote": "Little by little, one travels far.",
      "author": "J.R.R. Tolkien"
    },
    {
      "quote": "Believe in yourself and all that you are. Know that there is something inside you that is greater than any obstacle.",
      "author": "Christian D. Larson"
    },
    {
      "quote": "Dream big. Start small. Act now.",
      "author": "Robin Sharma"
    },
    {
      "quote": "Pain is temporary. Quitting lasts forever.",
      "author": "Lance Armstrong"
    },
    {
      "quote": "Discipline is the bridge between goals and accomplishment.",
      "author": "Jim Rohn"
    },
    {
      "quote": "Everything you’ve ever wanted is on the other side of fear.",
      "author": "George Addair"
    },
    {
      "quote": "Success usually comes to those who are too busy to be looking for it.",
      "author": "Henry David Thoreau"
    },
    {
      "quote": "Life is 10% what happens to us and 90% how we react to it.",
      "author": "Charles R. Swindoll"
    },
    {
      "quote": "Don’t be afraid to give up the good to go for the great.",
      "author": "John D. Rockefeller"
    },
    {
      "quote": "The best way to predict your future is to create it.",
      "author": "Abraham Lincoln"
    },
    {
      "quote": "Difficulties in life are intended to make us better, not bitter.",
      "author": "Dan Reeves"
    },
  ];


  Future<void> _uploadToFirestore(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    try {
      for (final item in coping) {
        await firestore.collection('coping').add(item);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminders uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading reminders: $e')),
      );
    }
  }
  Future<void> _uploadToFirestore2(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    try {
      for (final item in article) {
        await firestore.collection('article').add(item);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminders uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading reminders: $e')),
      );
    }
  }
  Future<void> _uploadToFirestore3(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    try {
      for (final item in motivational) {
        await firestore.collection('motivational').add(item);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminders uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading reminders: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Reminders')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _uploadToFirestore3(context),
          child: const Text('Upload Reminders to Firestore'),
        ),
      ),
    );
  }
}

