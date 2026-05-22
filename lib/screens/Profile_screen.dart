import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/faction_model.dart';
import '../services/faction_provider.dart';

/// Pantalla de perfil del agente de ShadowNet.
/// Operación Camaleón - Perfil Dinámico
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {

  final TextEditingController _nameController = TextEditingController();

  late AnimationController _symbolController;
  late Animation<double> _symbolAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();

    _symbolController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _symbolAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _symbolController, curve: Curves.elasticOut),
    );
    _symbolController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════
  //  LÓGICA
  // ═══════════════════════════════════════════

  void _selectFaction(Faction faction) {
    context.read<FactionProvider>().setFaction(faction);
    _symbolController.forward(from: 0);
  }

  void _saveName() {
    context.read<FactionProvider>().setAgentName(_nameController.text);
    setState(() => _isEditingName = false);
    FocusScope.of(context).unfocus();
  }

  // ═══════════════════════════════════════════
  //  ACCESIBILIDAD - BOTÓN DE CERRAR SESIÓN
  // ═══════════════════════════════════════════

  Widget _buildLogoutButton(Faction faction) => Semantics(
        label: 'Botón: Finalizar misión y borrar rastro',
        button: true,
        hint: 'Cerrar sesión y volver a la pantalla de login',
        child: GestureDetector(
          onTap: () => _showLogoutConfirmation(faction),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.redAccent.withOpacity(0.9), width: 2),
              color: Colors.redAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.power_settings_new, color: Colors.redAccent, size: 20),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'FINALIZAR MISIÓN Y BORRAR RASTRO',
                    style: faction.textStyle(size: 13, bold: true, color: Colors.redAccent),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  void _showLogoutConfirmation(Faction faction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: faction.backgroundColor,
        title: Text('¿FINALIZAR MISIÓN?', style: faction.textStyle(size: 18, bold: true)),
        content: Text(
          'Se borrará todo el rastro y volverás a la pantalla de autenticación.',
          style: faction.textStyle(size: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCELAR', style: faction.textStyle(color: faction.primaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Text('CONFIRMAR', style: faction.textStyle(color: Colors.redAccent, bold: true)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FactionProvider>();
    final faction = provider.currentFaction;

    return Scaffold(
      backgroundColor: faction.backgroundColor,
      appBar: _buildAppBar(faction, provider),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('IDENTIDAD DEL AGENTE', faction),
              const SizedBox(height: 12),
              _buildAgentNameField(faction, provider),
              const SizedBox(height: 8),
              _buildAgentStats(faction, provider),
              const SizedBox(height: 30),

              _buildSectionLabel('SÍMBOLO DE FACCIÓN', faction),
              const SizedBox(height: 16),
              _buildFactionSymbol(faction),
              const SizedBox(height: 30),

              _buildSectionLabel('SELECCIONAR FACCIÓN', faction),
              const SizedBox(height: 16),
              _buildFactionSelector(faction, provider),
              const SizedBox(height: 30),

              _buildSectionLabel('ESTADÍSTICAS', faction),
              const SizedBox(height: 12),
              _buildStatsPanel(faction, provider),
              const SizedBox(height: 30),

              _buildConfirmButton(faction),
              _buildLogoutButton(faction),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  WIDGETS AUXILIARES
  // ═══════════════════════════════════════════

  PreferredSizeWidget _buildAppBar(Faction faction, FactionProvider provider) =>
      AppBar(
        backgroundColor: faction.appBarColor,
        elevation: 0,
        titleSpacing: 0,
        leading: Semantics(
          label: 'Volver al radar',
          button: true,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: faction.primaryColor, size: 16),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'PERFIL // ${provider.agentName}',
          style: faction.textStyle(size: 14, bold: true),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          SizedBox(
            width: 50,
            child: Center(
              child: Text(faction.symbol, style: const TextStyle(fontSize: 22)),
            ),
          ),
        ],
      );

  Widget _buildSectionLabel(String label, Faction faction) => Text(
        '═══[ $label ]═══',
        style: faction.textStyle(size: 11, color: faction.primaryColor.withOpacity(0.6)),
        overflow: TextOverflow.ellipsis,
      );

  Widget _buildAgentNameField(Faction faction, FactionProvider provider) {
    if (_isEditingName) {
      return Row(
        children: [
          Expanded(
            child: Semantics(
              label: 'Campo de nombre del agente',
              child: TextField(
                controller: _nameController,
                autofocus: true,
                style: faction.textStyle(size: 18, bold: true),
                cursorColor: faction.primaryColor,
                decoration: InputDecoration(
                  hintText: 'INGRESA TU NOMBRE EN CLAVE',
                  hintStyle: faction.textStyle(size: 14, color: faction.primaryColor.withOpacity(0.4)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: faction.primaryColor)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: faction.accentColor, width: 2)),
                ),
                onSubmitted: (_) => _saveName(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: 'Guardar nombre del agente',
            button: true,
            child: GestureDetector(
              onTap: _saveName,
              child: Text('[ GUARDAR ]', style: faction.textStyle(size: 13, color: faction.accentColor)),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () {
        _nameController.text = provider.agentName;
        setState(() => _isEditingName = true);
      },
      child: Semantics(
        label: 'Nombre del agente: ${provider.agentName}. Toca para editar',
        button: true,
        child: Row(
          children: [
            Expanded(                          // ← FIX: evita el overflow
              child: Text(
                provider.agentName,
                style: faction.textStyle(size: 22, bold: true),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.edit, color: faction.primaryColor.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentStats(Faction faction, FactionProvider provider) =>
      Semantics(
        label: 'Rango: ${provider.agentRank}. Nivel ${provider.agentLevel}',
        child: Row(
          children: [
            Text('${provider.agentRank}  //  NIVEL ${provider.agentLevel}',
                style: faction.textStyle(size: 12, color: faction.accentColor)),
          ],
        ),
      );

  Widget _buildFactionSymbol(Faction faction) => Center(
        child: AnimatedBuilder(
          animation: _symbolAnimation,
          builder: (_, __) => Transform.scale(
            scale: _symbolAnimation.value,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) => Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: faction.primaryColor.withOpacity(_pulseAnimation.value),
                    width: 3,
                  ),
                  color: faction.primaryColor.withOpacity(0.08),
                ),
                child: ClipOval(
                  child: Image.asset(
                    faction.logoAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(faction.symbol, style: const TextStyle(fontSize: 80)),
                          const SizedBox(height: 8),
                          Text(faction.name, style: faction.textStyle(size: 16, bold: true)),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildFactionSelector(Faction activeFaction, FactionProvider provider) =>
      Column(
        children: shadowNetFactions.map((faction) {
          final bool isActive = faction.name == activeFaction.name;
          return Semantics(
            label: 'Facción ${faction.name}: ${faction.description}. '
                '${isActive ? "Seleccionada actualmente" : "Toca para seleccionar"}',
            button: true,
            selected: isActive,
            child: GestureDetector(
              onTap: () => _selectFaction(faction),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isActive
                        ? faction.primaryColor
                        : activeFaction.primaryColor.withOpacity(0.2),
                    width: isActive ? 2 : 1,
                  ),
                  color: isActive
                      ? faction.primaryColor.withOpacity(0.08)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Text(faction.symbol, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faction.name,
                            style: faction.textStyle(size: 16, bold: true),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            faction.description,
                            style: faction.textStyle(
                              size: 11,
                              color: faction.primaryColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"${faction.motto}"',
                            style: faction.textStyle(
                              size: 10,
                              color: faction.accentColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isActive
                          ? faction.primaryColor
                          : activeFaction.primaryColor.withOpacity(0.3),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );

  Widget _buildStatsPanel(Faction faction, FactionProvider provider) =>
      Semantics(
        label: 'Estadísticas: ${provider.missionsCompleted} misiones completadas',
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: faction.primaryColor.withOpacity(0.3)),
            color: faction.primaryColor.withOpacity(0.03),
          ),
          child: Column(
            children: [
              _buildStatRow('FACCIÓN ACTIVA', faction.name, faction),
              _buildStatRow('MISIONES COMPLETADAS', '${provider.missionsCompleted}', faction),
              _buildStatRow('NIVEL', '${provider.agentLevel} / 10', faction),
              _buildStatRow('RANGO', provider.agentRank, faction),
            ],
          ),
        ),
      );

  Widget _buildStatRow(String label, String value, Faction faction) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: faction.textStyle(
                  size: 12,
                  color: faction.primaryColor.withOpacity(0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: faction.textStyle(size: 13, bold: true),
            ),
          ],
        ),
      );

  Widget _buildConfirmButton(Faction faction) => Semantics(
        label: 'Confirmar facción ${faction.name} y volver al radar',
        button: true,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: faction.primaryColor, width: 2),
              color: faction.primaryColor.withOpacity(0.1),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '[ CONFIRMAR IDENTIDAD — ${faction.name} ]',
                style: faction.textStyle(size: 14, bold: true),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
}