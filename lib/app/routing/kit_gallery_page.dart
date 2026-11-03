import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/di/debug_probe.dart';
import 'package:kiveto_mobile/core/security/token_pair.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

// Debug builds only (the route is registered under kDebugMode). The sample
// texts are the mockup's French sample content, hard-coded on purpose: this
// page is not shipped.

/// Every component of the UI kit with its states, the icons, the type
/// scale, the colour tokens; a network probe and a fake session.
class KitGalleryPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<KitGalleryPage> createState() => _KitGalleryPageState();
}

class _KitGalleryPageState extends ConsumerState<KitGalleryPage> {
  var _segment = 0;
  var _petSegment = 'moka';
  var _filter = 'Tous';
  final _choices = <String>{'Démangeaisons'};
  var _switchOn = true;
  var _checkbox = true;
  var _consent = false;
  var _sms = true;
  var _email = false;
  var _pet = 0;
  var _motif = 0;
  var _tab = 0;
  var _probe = false;
  var _loading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: KivetoColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            KivetoIconButton.back(
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            KivetoPageHeader(
              l10n.screenKitGalleryTitle,
              subtitle: 'Composants, icônes, typographie, couleurs',
            ),
            ..._section('Réseau', _network()),
            ..._section('Session factice', _session()),
            ..._section('Boutons', _buttons()),
            ..._section('Surfaces et lignes', _surfaces()),
            ..._section('Pastilles, puces, avatars', _pills()),
            ..._section('Navigation et structure', _navigation()),
            ..._section('Formulaires', _forms()),
            ..._section('Retours', _feedback()),
            ..._section('Formats', _formats()),
            ..._section('Icônes', [_icons()]),
            ..._section('Typographie', _typography()),
            ..._section('Couleurs', [_colors()]),
          ],
        ),
      ),
    );
  }

  List<Widget> _section(String title, List<Widget> children) => [
    const SizedBox(height: KivetoSpace.xl6),
    KivetoSectionHeader(title),
    const SizedBox(height: KivetoSpace.m),
    for (var i = 0; i < children.length; i++) ...[
      if (i > 0) const SizedBox(height: KivetoSpace.m),
      children[i],
    ],
  ];

  List<Widget> _network() => [
    KivetoButton.tonal(
      label: 'GET /legal/terms/current',
      size: KivetoButtonSize.medium,
      onPressed: () {
        if (_probe) ref.invalidate(termsProbeProvider);
        setState(() => _probe = true);
      },
    ),
    if (_probe)
      KivetoCard(
        padding: const EdgeInsets.all(14),
        child: AsyncValueView<String>(
          value: ref.watch(termsProbeProvider),
          onRetry: () => ref.invalidate(termsProbeProvider),
          data: (status) => Text(
            'GET /legal/terms/current → $status',
            style: KivetoText.label,
          ),
        ),
      ),
  ];

  List<Widget> _session() {
    final session = ref.watch(sessionManagerProvider);
    return [
      KivetoButton.primary(
        label: 'Ouvrir une session factice',
        size: KivetoButtonSize.medium,
        expand: true,
        onPressed: () => unawaited(
          session.open(
            const TokenPair(accessToken: 'debug', refreshToken: 'debug'),
          ),
        ),
      ),
      KivetoButton.outline(
        label: 'Fermer la session',
        expand: true,
        onPressed: () => unawaited(session.signOut()),
      ),
    ];
  }

  List<Widget> _buttons() => [
    KivetoButton.primary(label: 'Recevoir mon code', onPressed: () {}),
    KivetoButton.primary(
      label: 'Continuer',
      size: KivetoButtonSize.medium,
      onPressed: () {},
    ),
    KivetoButton.primary(
      label: 'Rattacher ce dossier',
      size: KivetoButtonSize.small,
      onPressed: () {},
    ),
    KivetoButton.primary(label: 'Envoyer la demande', onPressed: null),
    KivetoButton.primary(
      label: 'Valider',
      loading: _loading,
      onPressed: () => setState(() => _loading = !_loading),
    ),
    KivetoButton.dark(
      label: 'Prendre rendez-vous',
      icon: LucideGlyph.plus,
      onPressed: () {},
    ),
    KivetoButton.danger(label: 'Annuler le rendez-vous', onPressed: () {}),
    KivetoButton.danger(label: 'Annuler le rendez-vous', onPressed: null),
    Row(
      children: [
        KivetoButton.danger(
          label: 'Appeler',
          size: KivetoButtonSize.small,
          onPressed: () {},
        ),
      ],
    ),
    KivetoButton.outline(
      label: 'Se déconnecter',
      size: KivetoButtonSize.large,
      onPressed: () {},
    ),
    KivetoButton.outline(
      label: 'Ajouter à mon calendrier',
      icon: LucideGlyph.calendar,
      onPressed: () {},
    ),
    Row(
      children: [
        KivetoButton.outline(
          label: 'Modifier',
          size: KivetoButtonSize.small,
          onPressed: () {},
        ),
        const SizedBox(width: 10),
        KivetoButton.tonal(
          label: 'Carnet PDF',
          icon: LucideGlyph.download,
          onPressed: () {},
        ),
      ],
    ),
    KivetoButton.outlineBrand(
      label: 'Demander un renouvellement',
      onPressed: () {},
    ),
    KivetoButton.outlineDanger(label: 'Annuler', onPressed: () {}),
    KivetoButton.tonal(
      label: 'Me prévenir',
      size: KivetoButtonSize.medium,
      onPressed: () {},
    ),
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KivetoColors.brand,
        borderRadius: BorderRadius.circular(KivetoRadius.xl),
      ),
      child: Row(
        children: [
          Expanded(
            child: KivetoButton.onBrand(
              label: 'Remplir le questionnaire',
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 10),
          KivetoButton.onBrandOutline(label: 'Gérer', onPressed: () {}),
        ],
      ),
    ),
    const KivetoTextButton(label: 'Renvoyer le SMS dans 0:24', onPressed: null),
    KivetoTextButton(label: 'Recevoir le code par email', onPressed: () {}),
    KivetoLinkButton(label: 'Garder mon rendez-vous', onPressed: () {}),
    KivetoInlineLinks([
      const InlinePart.text("J'accepte les "),
      InlinePart.link("conditions d'utilisation", onTap: () {}),
      const InlinePart.text(' et la '),
      InlinePart.link('politique de confidentialité', onTap: () {}),
      const InlinePart.text('.'),
    ]),
    KivetoInlineLinks([
      InlinePart.link(
        "J'ai un lien d'invitation",
        onTap: () {},
        underline: false,
        strong: true,
      ),
    ]),
    Wrap(
      spacing: 12,
      children: [
        KivetoIconButton.back(onPressed: () {}, offset: 0),
        KivetoIconButton.close(onPressed: () {}, offset: 0),
        KivetoIconButton.roundOutline(
          glyph: LucideGlyph.bell,
          semanticLabel: 'Notifications',
          onPressed: () {},
        ),
        KivetoIconButton.fab(
          glyph: LucideGlyph.plus,
          semanticLabel: 'Nouveau rendez-vous',
          onPressed: () {},
        ),
        KivetoIconButton.squareMuted(
          glyph: LucideGlyph.download,
          semanticLabel: 'Télécharger',
          onPressed: () {},
        ),
      ],
    ),
  ];

  List<Widget> _surfaces() => [
    KivetoCard.list(
      children: const [
        KivetoListRow(
          title: 'Pistache — Rappel typhus/coryza',
          meta: 'Avant le 18 nov.',
          trailing: StatusPill('Dans 3 sem.', tone: StatusTone.warning),
        ),
        KivetoListRow(
          title: 'Moka — Antiparasitaire',
          meta: 'Avant le 12 déc.',
          trailing: StatusPill('Dans 6 sem.', tone: StatusTone.neutral),
        ),
      ],
    ),
    KivetoCard.list(
      children: [
        KivetoListRow.navigation(
          title: 'Vaccination annuelle',
          meta: '30 min',
          onTap: () {},
        ),
        KivetoListRow.navigation(
          title: 'Consultation',
          meta: '20 min',
          onTap: () {},
        ),
      ],
    ),
    KivetoCard.list(
      children: [
        KivetoListRow.tile(
          leading: const KivetoLeadingTile(
            colors: KivetoColorSets.indigo,
            glyph: LucideGlyph.fileText,
          ),
          title: 'Compte-rendu de consultation',
          meta: 'Moka · 14 oct.',
          onTap: () {},
        ),
        KivetoListRow.tile(
          leading: const KivetoLeadingTile(
            colors: KivetoColorSets.green,
            text: '€',
          ),
          title: 'Facture F-2026-0412',
          meta: '68,00 € · Payée',
          onTap: () {},
        ),
        const KivetoListRow.tile(
          leading: KivetoLeadingTile(
            colors: KivetoColorSets.orange,
            text: 'Rx',
            size: 40,
          ),
          title: 'Ordonnance',
          meta: 'Moka · 14 oct.',
        ),
      ],
    ),
    KivetoCard.list(
      children: [
        KivetoActionRow(
          glyph: LucideGlyph.download,
          label: 'Exporter mes données',
          onTap: () {},
        ),
        KivetoActionRow(
          glyph: LucideGlyph.trash,
          label: 'Demander la suppression de mon compte',
          danger: true,
          onTap: () {},
        ),
      ],
    ),
    KivetoCard.list(
      radius: KivetoRadius.xl,
      children: [
        const KivetoKeyValueRow(label: 'Animal', value: 'Moka'),
        KivetoKeyValueRow(
          label: 'Clinique',
          value: 'Clinique des Lices',
          secondary: '12 rue des Lices, 49100 Angers',
          actionLabel: 'Modifier',
          onAction: () {},
        ),
      ],
    ),
    KivetoCard.list(
      children: [
        KivetoSwitchRow(
          title: 'Rappels de soins',
          description: 'Vaccins, antiparasitaires : un rappel avant échéance.',
          value: _switchOn,
          onChanged: (value) => setState(() => _switchOn = value),
        ),
        const KivetoSwitchRow(
          title: 'Rappels de rendez-vous',
          description: 'Obligatoire tant que vous avez un rendez-vous.',
          value: true,
          onChanged: null,
        ),
        KivetoCheckboxRow(
          title: 'Apoquel 16 mg',
          meta: '1 comprimé par jour',
          value: _checkbox,
          onChanged: (value) => setState(() => _checkbox = value),
        ),
      ],
    ),
    KivetoSectionHeader(
      'Derniers documents',
      actionLabel: 'Tout voir',
      onAction: () {},
    ),
    const KivetoSectionHeader('Mes animaux', trailingCaption: '2 animaux'),
    KivetoSectionHeader(
      'Vaccins et préventions',
      trailing: KivetoButton.tonal(
        label: 'Carnet PDF',
        icon: LucideGlyph.download,
        onPressed: () {},
      ),
    ),
    const KivetoSectionHeader(
      'Mes consentements',
      description: 'Ce que la clinique peut vous envoyer.',
    ),
    KivetoPageHeader(
      'Rendez-vous',
      subtitle: 'Clinique des Lices',
      trailing: KivetoIconButton.fab(
        glyph: LucideGlyph.plus,
        semanticLabel: 'Nouveau rendez-vous',
        onPressed: () {},
      ),
    ),
    KivetoDetailHeader(
      title: 'Clinique des Lices',
      subtitle: '12 rue des Lices, 49100 Angers',
      extra: 'Ouvert · ferme à 19:00',
      extraIsPositive: true,
      onBack: () {},
    ),
    const KivetoBrandLockup(),
  ];

  List<Widget> _pills() => [
    const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        StatusPill('À jour', tone: StatusTone.success),
        StatusPill('Dans 3 sem.', tone: StatusTone.warning),
        StatusPill('En attente', tone: StatusTone.neutral),
        StatusPill('Active', tone: StatusTone.brand),
        StatusPill('Confirmé', tone: StatusTone.onBrand),
        StatusPill('Annulé', tone: StatusTone.danger),
        StatusPill('Rappel à faire', tone: StatusTone.warning, compact: true),
      ],
    ),
    const KivetoTag.brand('Invitation de la Clinique des Lices'),
    const KivetoTag.success('06 12 34 56 78 vérifié'),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in ['Tous', 'Comptes-rendus', 'Factures'])
          KivetoFilterChip(
            label: filter,
            selected: _filter == filter,
            onSelected: () => setState(() => _filter = filter),
          ),
      ],
    ),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final choice in ['Démangeaisons', 'Vomissements', 'Boiterie'])
          KivetoChoiceChip(
            label: choice,
            selected: _choices.contains(choice),
            onSelected: () => setState(
              () => _choices.contains(choice)
                  ? _choices.remove(choice)
                  : _choices.add(choice),
            ),
          ),
      ],
    ),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        KivetoSummaryChip(label: 'Moka', onPressed: () {}),
        KivetoSummaryChip(
          label: 'Clinique des Lices',
          trailingGlyph: LucideGlyph.chevronDown,
          onPressed: () {},
        ),
        KivetoSummaryChip.action(
          label: 'Autour de moi',
          leadingGlyph: LucideGlyph.mapPin,
          onPressed: () {},
        ),
        KivetoDocumentChip(label: 'Compte-rendu', onPressed: () {}),
        KivetoDocumentChip(label: 'Ordonnance', onPressed: () {}),
      ],
    ),
    const Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InitialsAvatar('SB', size: 24, tone: AvatarTone.ink),
        InitialsAvatar('SB', size: 24, tone: AvatarTone.brand),
        InitialsAvatar('M'),
        InitialsAvatar('P', tone: AvatarTone.orange),
        InitialsAvatar('SB', size: 48, tone: AvatarTone.ink),
        InitialsAvatar('M', size: 48, pet: true),
        InitialsAvatar('M', size: 64),
        StatusDot(),
        StatusDot(active: false),
      ],
    ),
  ];

  List<Widget> _navigation() => [
    KivetoSegmentedControl<int>(
      segments: const [
        KivetoSegment(0, 'À venir (2)'),
        KivetoSegment(1, 'Passés'),
      ],
      selected: _segment,
      onChanged: (value) => setState(() => _segment = value),
    ),
    Center(
      child: KivetoSegmentedControl<String>(
        compact: true,
        segments: const [
          KivetoSegment('moka', 'Moka'),
          KivetoSegment('pistache', 'Pistache'),
        ],
        selected: _petSegment,
        onChanged: (value) => setState(() => _petSegment = value),
      ),
    ),
    KivetoCard(
      padding: const EdgeInsets.all(16),
      child: WizardHeader(
        step: 3,
        stepLabel: 'Étape 3 sur 4',
        title: 'Choisissez un créneau',
        onBack: () {},
        onClose: () {},
      ),
    ),
    StickySummaryBar(
      label: 'Créneau choisi',
      value: 'Mar. 4 nov. · 10:30',
      action: KivetoButton.primary(
        label: 'Continuer',
        size: KivetoButtonSize.medium,
        onPressed: () {},
      ),
    ),
    StickyCtaBar(
      child: KivetoButton.primary(
        label: 'Confirmer le rendez-vous',
        onPressed: () {},
      ),
    ),
    BottomCtaArea(
      success: true,
      children: [
        KivetoButton.primary(label: "Revenir à l'accueil", onPressed: () {}),
        KivetoLinkButton(label: 'Plus tard', onPressed: () {}),
      ],
    ),
    KivetoBottomNav(
      currentIndex: _tab,
      onTap: (tab) => setState(() => _tab = tab),
      items: const [
        KivetoNavItem(label: 'Accueil', glyph: LucideGlyph.house),
        KivetoNavItem(label: 'Animaux', glyph: LucideGlyph.pawPrint),
        KivetoNavItem(label: 'Rendez-vous', glyph: LucideGlyph.calendar),
        KivetoNavItem(
          label: 'Documents',
          glyph: LucideGlyph.fileText,
          badgeCount: 2,
          semanticLabel: 'Documents, 2 nouveaux',
        ),
        KivetoNavItem(label: 'Compte', avatar: true, initials: 'SB'),
      ],
    ),
    KivetoButton.outline(
      label: 'Ouvrir la feuille',
      onPressed: () => unawaited(
        showKivetoSheet<void>(
          context: context,
          builder: (context) => KivetoSheet(
            title: 'Annuler ce rendez-vous ?',
            subtitle: 'Mar. 4 nov. · 10:30 — Moka, vaccination annuelle',
            children: [
              const KivetoCallout.warning(
                body: 'Annulation possible jusqu’à 24 h avant le rendez-vous.',
              ),
              KivetoButton.danger(
                label: 'Annuler le rendez-vous',
                onPressed: () => Navigator.of(context).pop(),
              ),
              KivetoButton.outline(
                label: 'Reporter plutôt',
                size: KivetoButtonSize.large,
                onPressed: () => Navigator.of(context).pop(),
              ),
              KivetoLinkButton(
                label: 'Garder mon rendez-vous',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  ];

  List<Widget> _forms() => [
    const KivetoTextField(
      label: 'Prénom',
      hintText: 'Sarah',
      helpText: 'Comme sur votre dossier à la clinique.',
    ),
    const KivetoTextField(
      label: 'Email',
      readOnly: true,
      helpText: 'Renseigné par la clinique.',
    ),
    const KivetoTextField(
      label: 'Nom',
      errorText: 'Le nom ne peut pas être vide.',
    ),
    const KivetoTextField.multiline(
      label: 'Précisions',
      optional: true,
      hintText: 'Nom du médicament, dose',
    ),
    const KivetoSearchField(
      semanticLabel: 'Rechercher une clinique',
      hintText: 'Ville, nom de clinique',
    ),
    const KivetoPhoneField(
      label: 'Numéro de mobile',
      hintText: '6 12 34 56 78',
      helpText: 'Vous recevrez un code par SMS. Pas de mot de passe.',
    ),
    const KivetoCodeField(
      label: 'Code reçu par SMS au •• •• •• 42 18',
      hintText: '6 chiffres',
    ),
    const KivetoOtpField(
      legend: 'Code de vérification',
      helpText: 'Valable 10 minutes.',
    ),
    KivetoConsentCheckbox(
      value: _consent,
      onChanged: (value) => setState(() => _consent = value),
      label: [
        const InlinePart.text("J'accepte les "),
        InlinePart.link("conditions d'utilisation", onTap: () {}),
        const InlinePart.text(' et la '),
        InlinePart.link('politique de confidentialité', onTap: () {}),
        const InlinePart.text('.'),
      ],
    ),
    Row(
      children: [
        Expanded(
          child: KivetoCheckboxTile(
            label: 'SMS',
            value: _sms,
            onChanged: (value) => setState(() => _sms = value),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: KivetoCheckboxTile(
            label: 'Email',
            value: _email,
            onChanged: (value) => setState(() => _email = value),
          ),
        ),
      ],
    ),
    Row(
      children: [
        KivetoCheckbox(
          value: _checkbox,
          onChanged: (value) => setState(() => _checkbox = value),
        ),
        const SizedBox(width: 16),
        KivetoSwitch(
          value: _switchOn,
          onChanged: (value) => setState(() => _switchOn = value),
        ),
        const SizedBox(width: 16),
        const KivetoSwitch(value: true, onChanged: null),
      ],
    ),
    for (final (index, name, detail) in [
      (0, 'Moka', 'Chien · 4 ans'),
      (1, 'Pistache', 'Chat · 7 ans'),
    ])
      KivetoRadioCard(
        title: name,
        subtitle: detail,
        selected: _pet == index,
        leading: InitialsAvatar(
          name[0],
          size: 48,
          pet: true,
          tone: AvatarTone.forPetIndex(index),
        ),
        onTap: () => setState(() => _pet = index),
      ),
    KivetoAddCard(label: 'Un autre animal', onTap: () {}),
    for (final (index, motif, detail) in [
      (0, 'Vaccination', '30 min'),
      (1, 'Consultation', '20 min'),
    ])
      KivetoRadioCard(
        title: motif,
        subtitle: detail,
        selected: _motif == index,
        pill: index == 0
            ? const StatusPill(
                'Rappel à faire',
                tone: StatusTone.warning,
                compact: true,
              )
            : null,
        onTap: () => setState(() => _motif = index),
      ),
    const KivetoDashedBorder(
      color: KivetoColors.borderChip,
      radius: KivetoRadius.m,
      child: SizedBox(height: 60, child: Center(child: Text('Fermé'))),
    ),
  ];

  List<Widget> _feedback() => [
    KivetoCallout.info(
      title: 'Votre clinique vous a envoyé une invitation ?',
      body:
          'Ouvrez le lien reçu par SMS ou email : vos animaux et votre '
          'historique seront déjà là.',
      actionLabel: "J'ai un lien d'invitation",
      onAction: () {},
    ),
    KivetoCallout.brand(
      title: 'Un dossier à votre nom ?',
      body: 'La Clinique des Lices a un dossier à ce numéro.',
      actionLabel: 'Rattacher ce dossier',
      onAction: () {},
    ),
    const KivetoCallout.warning(
      body: 'La clinique vous recontactera si le délai ne convient pas.',
    ),
    KivetoCallout.danger(
      body: 'Urgence ? Appelez directement la clinique.',
      actionLabel: 'Appeler',
      onAction: () {},
    ),
    const KivetoFootnote(
      'Vérifiée par la clinique avant mise à jour de la fiche.',
    ),
    const KivetoFootnote('Le prix final est fixé à la clinique.', small: true),
    const ReassuranceList([
      'Un SMS de rappel la veille',
      'Annulation gratuite jusqu’à 24 h avant',
      'Le questionnaire à remplir avant la consultation',
    ]),
    KivetoCard(
      child: SuccessView(
        title: 'Rendez-vous confirmé',
        message: 'Mar. 4 nov. à 10:30 avec Dr Camille Roux.',
        note: 'Un SMS de confirmation vous a été envoyé.',
        action: KivetoButton.outline(
          label: 'Ajouter à mon calendrier',
          icon: LucideGlyph.calendar,
          onPressed: () {},
        ),
      ),
    ),
    KivetoCard(
      padding: const EdgeInsets.all(20),
      child: SheetSuccessView(
        title: 'Rendez-vous annulé',
        message: 'La clinique a été prévenue.',
        action: KivetoButton.primary(label: 'Fermer', onPressed: () {}),
      ),
    ),
    const KivetoCard(
      child: EmptyState(
        glyph: LucideGlyph.inbox,
        title: 'Aucun document',
        body: 'Les documents partagés par la clinique apparaîtront ici.',
      ),
    ),
    for (final failure in const <Object>[
      NetworkFailure(),
      RateLimitedFailure(retryAfter: Duration(seconds: 90)),
      ServerFailure(statusCode: 503),
      FormatException('not an API failure'),
    ])
      KivetoCard(
        child: ErrorView(error: failure, onRetry: () {}),
      ),
    const SizedBox(height: 80, child: LoadingView()),
    const KivetoSkeleton(),
  ];

  List<Widget> _formats() {
    final instant = ClinicInstant.parse('2025-11-04T10:30:00+01:00');
    final date = LocalDate(2026, 10, 14);
    return [
      for (final line in [
        KivetoFormat.dateTimeShort(instant),
        KivetoFormat.time(instant),
        KivetoFormat.dayMonth(date),
        KivetoFormat.dayMonthYear(date),
        KivetoFormat.numericDate(date),
        KivetoFormat.money(Money(6800, 'EUR')),
        KivetoFormat.phone('+33612345678'),
        KivetoFormat.phone('+262692123456'),
        KivetoFormat.phone('+687751234'),
      ])
        Text(line, style: KivetoText.label),
    ];
  }

  Widget _icons() => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      for (final glyph in LucideGlyph.values)
        SizedBox(
          width: 72,
          child: Column(
            children: [
              KivetoIcon(glyph, size: 24),
              const SizedBox(height: 4),
              Text(
                glyph.name,
                style: KivetoText.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
    ],
  );

  List<Widget> _typography() => [
    for (final (name, style) in [
      ('display 30/700', KivetoText.display),
      ('displaySmall 28/700', KivetoText.displaySmall),
      ('pageTitle 26/700', KivetoText.pageTitle),
      ('flowTitle 24/700', KivetoText.flowTitle),
      ('headline 22/700', KivetoText.headline),
      ('brandWordmark 18/700', KivetoText.brandWordmark),
      ('titleLarge 18/700', KivetoText.titleLarge),
      ('sectionTitle 16/700', KivetoText.sectionTitle),
      ('itemTitle 15/700', KivetoText.itemTitle),
      ('itemValue 15/600', KivetoText.itemValue),
      ('bodyLarge 15/400', KivetoText.bodyLarge),
      ('input 15/400', KivetoText.input),
      ('body 14/400', KivetoText.body),
      ('label 14/600', KivetoText.label),
      ('labelStrong 14/700', KivetoText.labelStrong),
      ('bodySmall 13/400', KivetoText.bodySmall),
      ('labelSmall 13/600', KivetoText.labelSmall),
      ('labelSmallStrong 13/700', KivetoText.labelSmallStrong),
      ('optionalSuffix 13/500', KivetoText.optionalSuffix),
      ('caption 12/400', KivetoText.caption),
      ('captionStrong 12/600', KivetoText.captionStrong),
      ('captionMedium 12/500', KivetoText.captionMedium),
      (
        'OVERLINE 12/600',
        KivetoText.overline.copyWith(color: KivetoColors.brand),
      ),
      ('tag 12/700', KivetoText.tag),
      ('pill 11/700', KivetoText.pill),
      ('navLabel 11/600', KivetoText.navLabel),
      ('navLabelActive 11/700', KivetoText.navLabelActive),
      ('micro 10/700', KivetoText.micro.copyWith(color: KivetoColors.ink)),
    ])
      Text('$name — Bonjour Sarah', style: style),
  ];

  Widget _colors() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final (name, color) in _tokens)
        SizedBox(
          width: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: KivetoColors.border),
                  borderRadius: BorderRadius.circular(KivetoRadius.s),
                ),
              ),
              Text(name, style: KivetoText.caption),
            ],
          ),
        ),
    ],
  );
}

const List<(String, Color)> _tokens = [
  ('brand', KivetoColors.brand),
  ('brandPressed', KivetoColors.brandPressed),
  ('brandSoft', KivetoColors.brandSoft),
  ('brandSubtle', KivetoColors.brandSubtle),
  ('brandBorderSoft', KivetoColors.brandBorderSoft),
  ('onBrandSoft', KivetoColors.onBrandSoft),
  ('onBrandSoftMuted', KivetoColors.onBrandSoftMuted),
  ('brandDisabled', KivetoColors.brandDisabled),
  ('onBrandMuted', KivetoColors.onBrandMuted),
  ('brandRaised', KivetoColors.brandRaised),
  ('onBrandOutline', KivetoColors.onBrandOutline),
  ('ink', KivetoColors.ink),
  ('inkSecondary', KivetoColors.inkSecondary),
  ('inkMuted', KivetoColors.inkMuted),
  ('inkDisabled', KivetoColors.inkDisabled),
  ('inkUnavailable', KivetoColors.inkUnavailable),
  ('surface', KivetoColors.surface),
  ('canvas', KivetoColors.canvas),
  ('track', KivetoColors.track),
  ('neutralSoft', KivetoColors.neutralSoft),
  ('border', KivetoColors.border),
  ('divider', KivetoColors.divider),
  ('borderStrong', KivetoColors.borderStrong),
  ('borderChip', KivetoColors.borderChip),
  ('timelineLine', KivetoColors.timelineLine),
  ('timelineDot', KivetoColors.timelineDot),
  ('success', KivetoColors.success),
  ('successSoft', KivetoColors.successSoft),
  ('warning', KivetoColors.warning),
  ('warningSoft', KivetoColors.warningSoft),
  ('onWarningSoft', KivetoColors.onWarningSoft),
  ('accentOrange', KivetoColors.accentOrange),
  ('accentOrangeSoft', KivetoColors.accentOrangeSoft),
  ('danger', KivetoColors.danger),
  ('dangerSoft', KivetoColors.dangerSoft),
  ('onDangerSoft', KivetoColors.onDangerSoft),
  ('dangerBorderSoft', KivetoColors.dangerBorderSoft),
  ('dangerDisabled', KivetoColors.dangerDisabled),
  ('onDangerDisabled', KivetoColors.onDangerDisabled),
  ('badge', KivetoColors.badge),
  ('scrim', KivetoColors.scrim),
  ('shadow', KivetoColors.shadow),
];
