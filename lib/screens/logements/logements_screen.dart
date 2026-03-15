import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/auth_provider.dart';
import 'package:tement_mobile/providers/logement_provider.dart';
import 'package:tement_mobile/widgets/logement_card.dart';
import 'package:tement_mobile/screens/logements/ajouter_logement_screen.dart';
import 'package:tement_mobile/screens/logements/detail_logement_screen.dart';
import 'package:tement_mobile/screens/logements/mes_logements_screen.dart';

class LogementsScreen extends StatefulWidget {
  const LogementsScreen({super.key});

  @override
  State<LogementsScreen> createState() => _LogementsScreenState();
}

class _LogementsScreenState extends State<LogementsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String? _selectedType;
  RangeValues _prixRange = const RangeValues(0, 200000);
  bool _showFilters = false;
  late AnimationController _animationController;
  late Animation<double> _filtersAnimation;

  @override
  void initState() {
    super.initState();
    _loadLogements();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _filtersAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLogements() async {
    await Provider.of<LogementProvider>(context, listen: false).loadLogements(
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      type: _selectedType,
      minPrix: _prixRange.start > 0 ? _prixRange.start : null,
      maxPrix: _prixRange.end < 200000 ? _prixRange.end : null,
    );
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = null;
      _prixRange = const RangeValues(0, 200000);
    });
    _loadLogements();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Logements disponibles',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF16213E), const Color(0xFF1A1A2E)]
                  : [Colors.white, Colors.grey.shade50],
            ),
          ),
        ),
        foregroundColor: TementColors.indigoTech,
        actions: [
          if (user?.isProprietaire ?? false)
            Container(
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: TementColors.indigoTech.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.format_list_bulleted),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MesLogementsScreen(),
                    ),
                  );
                },
                tooltip: 'Mes logements',
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: TementColors.indigoTech.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadLogements,
              tooltip: 'Actualiser',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche premium
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                Hero(
                  tag: 'searchBar',
                  child: Material(
                    elevation: _searchFocusNode.hasFocus ? 8 : 2,
                    shadowColor: TementColors.indigoTech.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Rechercher par ville, quartier...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: TementColors.indigoTech,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 22),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadLogements();
                                },
                              ),
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: _showFilters
                                    ? TementColors.sunsetOrange
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  _showFilters ? Icons.filter_list : Icons.tune,
                                  color: _showFilters
                                      ? Colors.white
                                      : TementColors.indigoTech,
                                ),
                                onPressed: _toggleFilters,
                                tooltip: 'Filtres',
                              ),
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                      onSubmitted: (_) => _loadLogements(),
                    ),
                  ),
                ),

                // Filtres animés premium
                SizeTransition(
                  sizeFactor: _filtersAnimation,
                  axisAlignment: -1.0,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF16213E).withOpacity(0.9),
                                const Color(0xFF1A1A2E).withOpacity(0.95),
                              ]
                            : [
                                Colors.white,
                                Colors.grey.shade50,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: TementColors.indigoTech.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.filter_alt,
                              size: 20,
                              color: TementColors.sunsetOrange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Filtres avancés',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Type de logement
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isDark ? Colors.grey.shade900 : Colors.white,
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedType,
                            hint: Text(
                              'Type de logement',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: TementColors.indigoTech,
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: null, child: Text('Tous les types')),
                              DropdownMenuItem(
                                value: 'maison',
                                child: Row(
                                  children: [
                                    Icon(Icons.house, size: 20),
                                    SizedBox(width: 8),
                                    Text('Maison'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'appartement',
                                child: Row(
                                  children: [
                                    Icon(Icons.apartment, size: 20),
                                    SizedBox(width: 8),
                                    Text('Appartement'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'studio',
                                child: Row(
                                  children: [
                                    Icon(Icons.meeting_room, size: 20),
                                    SizedBox(width: 8),
                                    Text('Studio'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor:
                                  isDark ? Colors.grey.shade900 : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Fourchette de prix
                        Text(
                          'Budget (FCFA)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RangeSlider(
                          values: _prixRange,
                          min: 0,
                          max: 200000,
                          divisions: 20,
                          activeColor: TementColors.sunsetOrange,
                          inactiveColor:
                              TementColors.sunsetOrange.withOpacity(0.2),
                          labels: RangeLabels(
                            '${_prixRange.start.toStringAsFixed(0)} FCFA',
                            '${_prixRange.end.toStringAsFixed(0)} FCFA',
                          ),
                          onChanged: (values) {
                            setState(() {
                              _prixRange = values;
                            });
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      TementColors.indigoTech.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Min: ${_prixRange.start.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      TementColors.indigoTech.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Max: ${_prixRange.end.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Boutons d'action
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _clearFilters,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: TementColors.greySecondary,
                                  side: BorderSide(
                                    color: TementColors.greySecondary
                                        .withOpacity(0.3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Effacer'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _toggleFilters();
                                  _loadLogements();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: TementColors.sunsetOrange,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: TementColors.sunsetOrange
                                      .withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'Appliquer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des logements
          Expanded(
            child: Consumer<LogementProvider>(
              builder: (context, logementProvider, child) {
                if (logementProvider.isLoading &&
                    logementProvider.logements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: TementColors.indigoTech.withOpacity(0.1),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Chargement des logements...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (logementProvider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.red.shade300,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Oups ! Une erreur est survenue',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            logementProvider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadLogements,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TementColors.indigoTech,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (logementProvider.logements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: TementColors.indigoTech.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.home_outlined,
                            size: 80,
                            color: TementColors.greySecondary.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Aucun logement trouvé',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez de modifier vos filtres',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_selectedType != null ||
                            _prixRange.start > 0 ||
                            _prixRange.end < 200000)
                          ElevatedButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Effacer les filtres'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: TementColors.indigoTech,
                              elevation: 0,
                              side: BorderSide(
                                color: TementColors.indigoTech.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadLogements,
                  color: TementColors.sunsetOrange,
                  backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logementProvider.logements.length,
                    itemBuilder: (context, index) {
                      final logement = logementProvider.logements[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LogementCard(
                          logement: logement,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailLogementScreen(
                                  logement: logement,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: user?.isProprietaire ?? false
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AjouterLogementScreen(),
                  ),
                ).then((_) => _loadLogements());
              },
              backgroundColor: TementColors.sunsetOrange,
              elevation: 8,
              icon: const Icon(Icons.add, size: 24),
              label: const Text(
                'Ajouter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
    );
  }
}
