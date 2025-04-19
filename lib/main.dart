import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(SortingVisualizerApp());

class SortingVisualizerApp extends StatefulWidget {
  @override
  _SortingVisualizerAppState createState() => _SortingVisualizerAppState();
}

class _SortingVisualizerAppState extends State<SortingVisualizerApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sort Visualizer',
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: SortingHomePage(onToggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SortingHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  SortingHomePage({required this.onToggleTheme});

  @override
  _SortingHomePageState createState() => _SortingHomePageState();
}

class _SortingHomePageState extends State<SortingHomePage> {
  List<int> _numbers = [];
  final int _maxValue = 100;
  final int _size = 30;
  int currentIndex = -1;
  int selectedIndex = -1;
  String selectedAlgorithm = 'Selection Sort';
  bool isSorting = false;
  bool stopRequested = false;

  final List<String> algorithms = [
    'Selection Sort',
    'Bubble Sort',
    'Insertion Sort',
    'Merge Sort',
    'Radix Sort',
  ];

  @override
  void initState() {
    super.initState();
    _generateNewList();
  }

  void _generateNewList() {
    if (isSorting) return;
    Random random = Random();
    _numbers = List.generate(_size, (_) => random.nextInt(_maxValue) + 10);
    setState(() {
      currentIndex = -1;
      selectedIndex = -1;
    });
  }

  Future<void> _startOrStopSort() async {
    if (isSorting) {
      setState(() => stopRequested = true);
      return;
    }

    setState(() {
      isSorting = true;
      stopRequested = false;
    });

    switch (selectedAlgorithm) {
      case 'Selection Sort':
        await _selectionSort();
        break;
      case 'Bubble Sort':
        await _bubbleSort();
        break;
      case 'Insertion Sort':
        await _insertionSort();
        break;
      case 'Merge Sort':
        await _mergeSort(0, _numbers.length - 1);
        break;
      case 'Radix Sort':
        await _radixSort();
        break;
    }

    setState(() {
      currentIndex = -1;
      selectedIndex = -1;
      isSorting = false;
    });
  }

  Future<void> _selectionSort() async {
    for (int i = 0; i < _numbers.length; i++) {
      int min = i;
      for (int j = i + 1; j < _numbers.length; j++) {
        if (stopRequested) return;
        setState(() {
          currentIndex = j;
          selectedIndex = min;
        });
        await Future.delayed(const Duration(milliseconds: 140));

        if (_numbers[j] < _numbers[min]) {
          min = j;
        }
      }
      if (min != i) {
        int temp = _numbers[i];
        _numbers[i] = _numbers[min];
        _numbers[min] = temp;
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 140));
      }
    }
  }

  Future<void> _bubbleSort() async {
    for (int i = 0; i < _numbers.length; i++) {
      for (int j = 0; j < _numbers.length - i - 1; j++) {
        if (stopRequested) return;
        setState(() {
          currentIndex = j;
          selectedIndex = j + 1;
        });
        await Future.delayed(const Duration(milliseconds: 140));

        if (_numbers[j] > _numbers[j + 1]) {
          int temp = _numbers[j];
          _numbers[j] = _numbers[j + 1];
          _numbers[j + 1] = temp;
          setState(() {});
        }
      }
    }
  }

  Future<void> _insertionSort() async {
    for (int i = 1; i < _numbers.length; i++) {
      int key = _numbers[i];
      int j = i - 1;

      while (j >= 0 && _numbers[j] > key) {
        if (stopRequested) return;
        setState(() {
          currentIndex = j;
          selectedIndex = i;
        });
        await Future.delayed(const Duration(milliseconds: 160));

        _numbers[j + 1] = _numbers[j];
        j--;
        setState(() {});
      }
      _numbers[j + 1] = key;
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 160));
    }
  }

  Future<void> _mergeSort(int left, int right) async {
    if (left < right) {
      int mid = (left + right) ~/ 2;
      await _mergeSort(left, mid);
      await _mergeSort(mid + 1, right);
      await _merge(left, mid, right);
    }
  }

  Future<void> _merge(int left, int mid, int right) async {
    List<int> leftList = _numbers.sublist(left, mid + 1);
    List<int> rightList = _numbers.sublist(mid + 1, right + 1);

    int i = 0, j = 0, k = left;
    while (i < leftList.length && j < rightList.length) {
      if (stopRequested) return;
      setState(() {
        currentIndex = k;
      });
      await Future.delayed(const Duration(milliseconds: 160));

      if (leftList[i] <= rightList[j]) {
        _numbers[k++] = leftList[i++];
      } else {
        _numbers[k++] = rightList[j++];
      }
    }
    while (i < leftList.length) {
      _numbers[k++] = leftList[i++];
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 160));
    }
    while (j < rightList.length) {
      _numbers[k++] = rightList[j++];
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 160));
    }
  }

  Future<void> _radixSort() async {
    int maxVal = _numbers.reduce(max);
    for (int exp = 1; maxVal ~/ exp > 0; exp *= 10) {
      if (stopRequested) return;
      await _countingSort(exp);
    }
  }

  Future<void> _countingSort(int exp) async {
    List<int> output = List.filled(_numbers.length, 0);
    List<int> count = List.filled(10, 0);

    for (int i = 0; i < _numbers.length; i++) {
      count[(_numbers[i] ~/ exp) % 10]++;
    }

    for (int i = 1; i < 10; i++) {
      count[i] += count[i - 1];
    }

    for (int i = _numbers.length - 1; i >= 0; i--) {
      output[count[(_numbers[i] ~/ exp) % 10] - 1] = _numbers[i];
      count[(_numbers[i] ~/ exp) % 10]--;
    }

    for (int i = 0; i < _numbers.length; i++) {
      _numbers[i] = output[i];
      setState(() {
        currentIndex = i;
      });
      await Future.delayed(const Duration(milliseconds: 140));
    }
  }

  Widget _buildBar(int value, bool isCurrent, bool isSelected) {
    final color = isCurrent
        ? Colors.red
        : isSelected
            ? Colors.orange
            : Theme.of(context).colorScheme.primary;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$value',
            style: const TextStyle(fontSize: 12),
          ),
          Container(
            height: value.toDouble() * 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sort Visualizer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context)
                      .colorScheme
                      .surface, // Fixed background color
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      focusColor: Colors.transparent,
                      value: selectedAlgorithm,
                      borderRadius: BorderRadius.circular(12),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      items: algorithms.map((String algorithm) {
                        return DropdownMenuItem<String>(
                          value: algorithm,
                          child: Text(algorithm),
                        );
                      }).toList(),
                      onChanged: isSorting
                          ? null
                          : (value) =>
                              setState(() => selectedAlgorithm = value!),
                    ),
                  ),
                ),
                Container(
                  width: 148,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _generateNewList,
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label: const Text(
                      "Generate",
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: _startOrStopSort,
                    icon: Icon(
                      isSorting ? Icons.stop : Icons.play_arrow,
                      color: isSorting
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    label: Text(
                      isSorting ? "Stop" : "Start",
                      style: TextStyle(
                        color: isSorting
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      backgroundColor: isSorting
                          ? Colors.redAccent
                          : Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _numbers.asMap().entries.map((entry) {
                  int index = entry.key;
                  int value = entry.value;
                  return _buildBar(
                    value,
                    index == currentIndex,
                    index == selectedIndex,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
