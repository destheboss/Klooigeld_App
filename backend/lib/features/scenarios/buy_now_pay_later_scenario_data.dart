// lib/features/scenarios/buy_now_pay_later_scenario_data.dart
import 'models/scenario_model.dart';
import 'models/scenario_step.dart';
import 'models/scenario_choice.dart';

ScenarioModel buildBuyNowPayLaterScenario() {
  // Added dialogueText: what the user says after choosing the option.
  // Keep language simple and relatable.
  // BNPL reminders included as before.
  // The scenario remains mostly the same, just with added dialogueText.

  return ScenarioModel(steps: [
    // Step 0: Intro
    ScenarioStep(
      npcName: "The Voices",
      npcMessage: "⏰ It’s late, and you’re chillin’ in your tiny apartment. You’re lowkey wondering how to enjoy life without going broke 💸 Big decisions are coming, and yeah… they might cost you—now or later",
      choices: [
        ScenarioChoice(
          text: "Continue",
          kChange: 0.0,
          outcome: "Your phone vibrates and you wonder who it is",
          dialogueText: "Ugh, overthinking again... let’s see who’s texting"
        ),
      ],
    ),

    // Step 1: Friend and concert ticket
    ScenarioStep(
      npcName: "Viktor",
      npcMessage: "Hey 😺😺 Since you asked, I got us tickets for that band you love — only 20K! Can you pay me now, or wanna use Klaro and deal with it later?",
      choices: [
        ScenarioChoice(
          text: "Pay 20K now.",
          kChange: -20.0,
          outcome: "You pay 20K right away. No debt, just less cash.. for now..",
          dialogueText: "I’ll just pay now and get it over with. Can’t deal with future me hating present me"
        ),
        ScenarioChoice(
          text: "Use Klaro (pay 20K later)",
          kChange: 0.0,
          outcome: "You skip the payment for now but owe Klaro 20K later. Future you can handle that",
          dialogueText: "Let’s just Klaro it. More cash for snacks tonight, right?"
        ),
      ],
    ),

    // Step 2: After concert narrative
    ScenarioStep(
      npcName: "The Voices",
      npcMessage: "🎶 You go to the concert, but how was it..? Absolutely mad. For a moment, no stress, just vibes. Then… you drop your phone on the way out — screen cracked.. ✈️📱 Now what?",
      choices: [
        ScenarioChoice(
          text: "Continue",
          kChange: 0.0,
          outcome: "You pick up your phone and sigh 😔😔",
          dialogueText: "Bruh"
        ),
      ],
    ),

    // Step 3: Phone decision
    ScenarioStep(
      npcName: "The Voices",
      npcMessage: "A repair stall offers to fix your phone for 70K 💰 Or Klaro can hook you up with a shiny new one, but you’ll owe 700K later. Or hey, keep it cracked and hope for the best 💥 What’s the move?",
      choices: [
        ScenarioChoice(
          text: "Pay 70K now to fix it",
          kChange: -70.0,
          outcome: "You fix the phone and take the hit now.. but at least no debt, right?",
          dialogueText: "Alright, lemme just get this fixed. It hurts, but what's done is done.."
        ),
        ScenarioChoice(
          text: "Get a new phone via Klaro (700K later)",
          kChange: 0.0,
          outcome: "You walk away with a new phone. But oof… you owe Klaro 700K now.. Big yikes 💀",
          dialogueText: "A new phone? Say less. I’ll deal with Klaro later... future me’s problem"
        ),
        ScenarioChoice(
          text: "Keep it cracked.",
          kChange: 0.0,
          outcome: "You keep your cash but risk that phone dying when you need it most",
          dialogueText: "I’ll survive with a cracked phone for now. Who even needs a perfect screen anyway?"
        ),
      ],
    ),

    // Step 4: Morning before grandma visit
    ScenarioStep(
      npcName: "The Voices",
      npcMessage: "🌄 Morning hits. It’s Grandma’s birthday 🎂 She never asks for much, but a little something would make her smile. The shop nearby has flowers for 10K and chocolates for 5K.. hmm..",
      choices: [
        ScenarioChoice(
          text: "Continue",
          kChange: 0.0,
          outcome: "‘Aight imma head out’🚶, you say, deciding what to grab for Grandma.",
          dialogueText: "Grandma deserves something nice. Let’s see..."
        ),
      ],
    ),

    // Step 5: Grandma
    ScenarioStep(
      npcName: "Grandma",
      npcMessage: "💞 Oh, my dear! You being here is all I could ever hope for. It’s moments like these, surrounded by family, that I cherish the most 🥰 Thank you for being here, sweetheart 🥰🥰🥰",
      choices: [
        ScenarioChoice(
          text: "Buy the 10K flowers.",
          kChange: -10.0,
          outcome: "🌺 Grandma’s eyes light up as you hand her the flowers. ‘You’re such a thoughtful soul’, she says, slipping 30K into your hand 💸",
          dialogueText: "These are for you, Grandma. Happy birthday! You deserve the best"
        ),
        ScenarioChoice(
          text: "Buy the 5K chocolates.",
          kChange: -5.0,
          outcome: "🍫 Grandma glows as she takes the chocolates. ‘You always know how to make me smile’, she says, gifting you a small sum of 15K 🎁",
          dialogueText: "Got these just for you, Grandma! Sweet treats for the sweetest person"
        ),
      ],
    ),
  ]);
}
