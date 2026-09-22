class FlashcardModel {
  final String dioulaText;
  final String frenchText;
  final String englishText;
  final String exampleDioula;
  final String exampleFrench;
  final String imagePath;
  final String? audioPath;

  const FlashcardModel({
    required this.dioulaText,
    required this.frenchText,
    required this.englishText,
    required this.exampleDioula,
    required this.exampleFrench,
    required this.imagePath,
    this.audioPath,
  });
}

const List<FlashcardModel> dioulaSalutations = [
  FlashcardModel(
    dioulaText: 'Aka nögö ka frafin kan déguin',
    frenchText: 'Il est facile d\'apprendre les langues africaines',
    englishText: 'It is easy to learn African languages',
    exampleDioula: 'Aka nögö ka frafin kan déguin — c\'est la devise !',
    exampleFrench: 'Learning African languages is easy — that\'s the motto!',
    imagePath: 'assets/images/dioula_facile.png',
    audioPath: 'audio/dioula/aka_nogo_ka_frafin.mp3',
  ),
  FlashcardModel(
    dioulaText: 'I ni sɔgɔma',
    frenchText: 'Bonjour (le matin)',
    englishText: 'Good morning',
    exampleDioula: 'I ni sɔgɔma ! I ka kɛnɛ wa ?',
    exampleFrench: 'Bonjour ! Comment vas-tu ?',
    imagePath: 'assets/images/character_dioula.png',
  ),
  FlashcardModel(
    dioulaText: 'I ni tile',
    frenchText: 'Bon après-midi',
    englishText: 'Good afternoon',
    exampleDioula: 'I ni tile, i ka kɛnɛ wa ?',
    exampleFrench: 'Bon après-midi, comment vas-tu ?',
    imagePath: 'assets/images/character_dioula.png',
  ),
  FlashcardModel(
    dioulaText: 'I ni wula',
    frenchText: 'Bonsoir',
    englishText: 'Good evening',
    exampleDioula: 'I ni wula ! I sigira wa ?',
    exampleFrench: 'Bonsoir ! Tu es bien rentré ?',
    imagePath: 'assets/images/character_dioula.png',
  ),
  FlashcardModel(
    dioulaText: 'I ka kɛnɛ wa ?',
    frenchText: 'Comment vas-tu ?',
    englishText: 'How are you?',
    exampleDioula: 'I ni sɔgɔma ! I ka kɛnɛ wa ?',
    exampleFrench: 'Bonjour ! Comment vas-tu ?',
    imagePath: 'assets/images/character_dioula.png',
  ),
  FlashcardModel(
    dioulaText: 'N ka kɛnɛ, i ni ce',
    frenchText: 'Je vais bien, merci',
    englishText: 'I\'m fine, thank you',
    exampleDioula: 'N ka kɛnɛ, i ni ce. E fana ka kɛnɛ wa ?',
    exampleFrench: 'Je vais bien, merci. Et toi, tu vas bien ?',
    imagePath: 'assets/images/character_dioula.png',
  ),
  FlashcardModel(
    dioulaText: 'Aw ni ce',
    frenchText: 'Merci / Bonjour (à plusieurs)',
    englishText: 'Thank you / Hello (plural)',
    exampleDioula: 'Aw ni ce, aw bɛɛ ka kɛnɛ wa ?',
    exampleFrench: 'Bonjour à tous, vous allez bien ?',
    imagePath: 'assets/images/character_dioula.png',
  ),
  FlashcardModel(
    dioulaText: 'Sambou bata aboulo lāwouli adê kontô rôla',
    frenchText: 'Sambou lève la main pour saluer',
    englishText: 'Sambou raises his hand to greet',
    exampleDioula: 'Sambou bata aboulo lāwouli adê kontô rôla — i ni sɔgɔma !',
    exampleFrench: 'Sambou lève la main pour saluer — bonjour !',
    imagePath: 'assets/images/sambou_salut.png',
    audioPath: 'audio/dioula/sambou_bata.mp3',
  ),
  // Tana manssii — à venir
];
