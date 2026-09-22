import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  static final List<_EventModel> _events = [
    _EventModel(
      title: 'Festival des Cultures Africaines',
      date: '12 Octobre 2026',
      city: 'Paris • Parc de la Villette',
      description: 'Musique, danse, gastronomie et artisanat des cultures d\'Afrique de l\'Ouest.',
      emoji: '🥁',
      color: const Color(0xFFE65100),
    ),
    _EventModel(
      title: 'Soirée Dioula & Hausa',
      date: '20 Octobre 2026',
      city: 'Lyon • Maison des Associations',
      description: 'Rencontre conviviale pour pratiquer et célébrer les langues africaines.',
      emoji: '🗣️',
      color: const Color(0xFF1565C0),
    ),
    _EventModel(
      title: 'Marché Africain de Noël',
      date: '14 Décembre 2026',
      city: 'Marseille • Vieux-Port',
      description: 'Produits alimentaires, vêtements et bijoux d\'Afrique subsaharienne.',
      emoji: '🎄',
      color: const Color(0xFF2E7D32),
    ),
    _EventModel(
      title: 'Atelier Langue & Culture Hausa',
      date: '5 Novembre 2026',
      city: 'Paris • 18ème arrondissement',
      description: 'Apprenez les bases du Hausa avec un professeur natif. Ouvert à tous.',
      emoji: '📚',
      color: const Color(0xFF6A1B9A),
    ),
  ];

  static final List<_PartnerModel> _partners = [
    _PartnerModel(
      name: 'Afrimarket',
      promo: '−15% sur tous les transferts d\'argent vers l\'Afrique de l\'Ouest ce mois-ci.',
      emoji: '💸',
      color: const Color(0xFFFF6F00),
    ),
    _PartnerModel(
      name: 'Saveurs d\'Afrique',
      promo: 'Livraison gratuite pour toute commande de produits alimentaires africains.',
      emoji: '🍲',
      color: const Color(0xFF00796B),
    ),
    _PartnerModel(
      name: 'Diaspora Connect',
      promo: 'Cours de Dioula & Hausa en ligne. 1er mois offert avec le code DIAKSLANGUE.',
      emoji: '🎓',
      color: const Color(0xFF283593),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text(
          'Communauté',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section événements
          _SectionHeader(
            icon: Icons.event_rounded,
            title: 'Événements culturels',
            color: const Color(0xFFE65100),
          ),
          const SizedBox(height: 12),
          ..._events.map((e) => _EventCard(event: e)),

          const SizedBox(height: 24),

          // Section partenaires
          _SectionHeader(
            icon: Icons.handshake_rounded,
            title: 'Offres partenaires',
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(height: 12),
          ..._partners.map((p) => _PartnerCard(partner: p)),

          const SizedBox(height: 20),

          // Bannière "Proposer un événement"
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Text('📣', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu organises un événement ?',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Contacte-nous pour apparaître ici.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final _EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // En-tête coloré
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: event.color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Text(event.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: event.color),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.date,
                        style: TextStyle(
                            fontSize: 12,
                            color: event.color.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Corps
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(event.city,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 13, color: AppColors.navy, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final _PartnerModel partner;
  const _PartnerCard({required this.partner});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: partner.color.withValues(alpha: 0.25)),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: partner.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(partner.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: partner.color),
                ),
                const SizedBox(height: 4),
                Text(
                  partner.promo,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.navy, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventModel {
  final String title, date, city, description, emoji;
  final Color color;
  const _EventModel({
    required this.title,
    required this.date,
    required this.city,
    required this.description,
    required this.emoji,
    required this.color,
  });
}

class _PartnerModel {
  final String name, promo, emoji;
  final Color color;
  const _PartnerModel({
    required this.name,
    required this.promo,
    required this.emoji,
    required this.color,
  });
}
