import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';

void main() {
  runApp(const PasswordGeneratorApp());
}

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password Generator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PasswordGeneratorScreen(),
    );
  }
}

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final TextEditingController lengthController = TextEditingController(
    text: "8",
  );

  bool includeLowercase = true;
  bool includeCapital = false;
  bool includeNumbers = false;
  bool includeSpecial = false;

  String generatedPassword = "";

  @override
  void dispose() {
    lengthController.dispose();
    super.dispose();
  }

  bool get _isGeneratedPasswordValid {
    if (generatedPassword.isEmpty) return false;
    if (generatedPassword.startsWith("Please")) return false;
    if (generatedPassword.startsWith("Length")) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Generator"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Password Length",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: lengthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter length (4 - 64)",
                ),
              ),

              const SizedBox(height: 20),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Include Lowercase Letters (a-z)"),
                value: includeLowercase,
                onChanged: (value) {
                  setState(() {
                    includeLowercase = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Include Capital Letters (A-Z)"),
                value: includeCapital,
                onChanged: (value) {
                  setState(() {
                    includeCapital = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Include Numbers (0-9)"),
                value: includeNumbers,
                onChanged: (value) {
                  setState(() {
                    includeNumbers = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Include Special Characters (!@#\$%.)"),
                value: includeSpecial,
                onChanged: (value) {
                  setState(() {
                    includeSpecial = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: generatePassword,
                  child: const Text("Generate Password"),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Generated Password:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              SelectableText(
                generatedPassword,
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isGeneratedPasswordValid
                        ? () async {
                            await Clipboard.setData(
                              ClipboardData(text: generatedPassword),
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Password copied!")),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.copy),
                    label: const Text("Copy"),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        generatedPassword = "";
                      });
                    },
                    child: const Text("Clear"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void generatePassword() {
    int length = int.tryParse(lengthController.text) ?? 8;

    if (length < 4) length = 4;
    if (length > 64) length = 64;

    final lowercase = "abcdefghijklmnopqrstuvwxyz";
    final uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    final numbers = "0123456789";
    final special = "!@#\$%.";

    final List<String> selectedPools = [];
    if (includeLowercase) selectedPools.add(lowercase);
    if (includeCapital) selectedPools.add(uppercase);
    if (includeNumbers) selectedPools.add(numbers);
    if (includeSpecial) selectedPools.add(special);

    if (selectedPools.isEmpty) {
      setState(() {
        generatedPassword = "Please select at least one option";
      });
      return;
    }

    if (length < selectedPools.length) {
      setState(() {
        generatedPassword = "Length must be at least ${selectedPools.length}";
      });
      return;
    }

    final random = Random.secure();

    final List<String> chars = selectedPools
        .map((pool) => pool[random.nextInt(pool.length)])
        .toList();

    // 2) Fill remaining from combined pool
    final allAllowed = selectedPools.join();
    for (int i = chars.length; i < length; i++) {
      chars.add(allAllowed[random.nextInt(allAllowed.length)]);
    }

    chars.shuffle(random);

    setState(() {
      generatedPassword = chars.join();
      lengthController.text = length.toString();
    });
  }
}
