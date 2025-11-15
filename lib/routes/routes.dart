import 'package:fanfoot/features/editor/screens/club_screen.dart';
import 'package:fanfoot/features/editor/screens/player_screen.dart';
import 'package:fanfoot/features/editor/screens/competition_screen.dart';
import 'package:fanfoot/features/editor/screens/configs_screen.dart';
import 'package:flutter/material.dart';

final routes = [
  {"title": "Clubes", "icon": Icons.shield, "screen": ClubScreen()},
  {"title": "Jogadores", "icon": Icons.person, "screen": PlayerScreen()},
  {
    "title": "Competições",
    "icon": Icons.emoji_events,
    "screen": CompetitionScreen(),
  },
  {"title": "Configurações", "icon": Icons.settings, "screen": ConfigsScreen()},
];
