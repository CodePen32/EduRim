import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminScope extends ChangeNotifier {
  int? _learningPathId;
  int _bacBranchId = 0;

  static const _keyLp = 'scope_lp';
  static const _keyBac = 'scope_bac';
  static const _keySelected = 'scope_selected';
  static const int bacPathId = 3;

  int? get learningPathId => _learningPathId;
  int get bacBranchId => _bacBranchId;
  bool get isSelected => _learningPathId != null;

  String get label {
    if (_learningPathId == 1) return 'Concours';
    if (_learningPathId == 2) return 'BEPC';
    if (_learningPathId == 3 && _bacBranchId == 1) return 'Bac C';
    if (_learningPathId == 3 && _bacBranchId == 2) return 'Bac D';
    return '';
  }

  String get queryParams {
    if (_learningPathId == null) return '';
    var q = 'learning_path_id=$_learningPathId';
    if (_bacBranchId > 0) q += '&bac_branch_id=$_bacBranchId';
    return q;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final selected = prefs.getBool(_keySelected) ?? false;
    if (selected) {
      _learningPathId = prefs.getInt(_keyLp);
      _bacBranchId = prefs.getInt(_keyBac) ?? 0;
    } else {
      _learningPathId = null;
      _bacBranchId = 0;
    }
    notifyListeners();
  }

  Future<void> select(int lpId, int bacId) async {
    _learningPathId = lpId;
    _bacBranchId = bacId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySelected, true);
    await prefs.setInt(_keyLp, lpId);
    await prefs.setInt(_keyBac, bacId);
    notifyListeners();
  }

  Future<void> clear() async {
    _learningPathId = null;
    _bacBranchId = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySelected, false);
    notifyListeners();
  }

  static List<Map<String, dynamic>> get allPaths => [
    {'lpId': 1, 'bacId': 0, 'label': 'Concours'},
    {'lpId': 2, 'bacId': 0, 'label': 'BEPC'},
    {'lpId': 3, 'bacId': 1, 'label': 'Bac C'},
    {'lpId': 3, 'bacId': 2, 'label': 'Bac D'},
  ];
}

final adminScope = AdminScope();
