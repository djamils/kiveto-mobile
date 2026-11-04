import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_card.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_listing_messages.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_listing_providers.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/link_suggestion_callouts.dart';
import 'package:kiveto_mobile/features/scheduling/scheduling.dart'
    show callClinic;
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/async/more_footer.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// How long the typing settles before the search is sent.
const searchDebounce = Duration(milliseconds: 350);

/// Screen 10, « Trouver une clinique » (mockup 10), the landing of an
/// account without a clinic: « Bonjour {prénom} », the clinics' records at
/// the account's phone number (« Rattacher ce dossier ») and the links
/// waiting for their clinic, then the directory: the search by name or
/// city, « Autour de moi » (by distance), page after page, as C-31 cards.
/// The server decides what matches; a refused search shows its message.
///
/// Exit: [onOpenListing] with a listing id (a clinic on Kiveto).
class ClinicSearchPage extends ConsumerStatefulWidget {
  const new({required this.onOpenListing, super.key});

  final void Function(BuildContext context, String listingId) onOpenListing;

  @override
  ConsumerState<ClinicSearchPage> createState() => _ClinicSearchPageState();
}

class _ClinicSearchPageState extends ConsumerState<ClinicSearchPage> {
  final _text = TextEditingController();
  Timer? _debounce;

  /// The search shown.
  var _query = ListingQuery();

  /// Reading the device's position.
  bool _locating = false;

  /// The suggestion being accepted, and those accepted (hidden until the
  /// suggestions read again drop them).
  String? _accepting;
  final _accepted = <String>{};

  /// The results last shown and their search: kept on screen while the
  /// first page of another search loads.
  ({ListingQuery query, ClinicSearchState results})? _shown;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _typed(String _) {
    _debounce?.cancel();
    _debounce = Timer(searchDebounce, () {
      if (!mounted) return;
      setState(
        () => _query = ListingQuery(text: _text.text, near: _query.near),
      );
    });
  }

  /// « Autour de moi »: the position read, the search sorted by distance;
  /// tapped again, back to the name order. A position that cannot be read
  /// leaves the mode as it was (the text typed just before searched) and
  /// says why.
  Future<void> _nearMe() async {
    _debounce?.cancel();
    if (_query.near != null) {
      setState(() => _query = ListingQuery(text: _text.text));
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _locating = true);
    try {
      final position = await ref.read(deviceLocationProvider)();
      if (!mounted) return;
      setState(() {
        _locating = false;
        _query = ListingQuery(text: _text.text, near: position);
      });
    } on LocationFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        _query = ListingQuery(text: _text.text, near: _query.near);
      });
      messenger?.showSnackBar(
        SnackBar(content: Text(locationMessage(l10n, failure.problem))),
      );
    }
  }

  /// Pull-to-refresh: `/me` (a link the clinic confirmed since), the
  /// records suggested and the search shown; done when the search
  /// answered.
  Future<void> _refresh() async {
    final search = clinicSearchProvider(_query);
    ref
      ..invalidate(meProvider)
      ..invalidate(linkSuggestionsProvider)
      ..invalidate(search);
    try {
      await ref.read(search.future);
    } on Object {
      // The page shows the failure.
    }
  }

  Future<void> _accept(LinkSuggestion suggestion) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = AppLocalizations.of(context);
    final container = ProviderScope.containerOf(context, listen: false);
    setState(() => _accepting = suggestion.id);
    try {
      await acceptLinkSuggestion(container, suggestion);
      if (mounted) setState(() => _accepted.add(suggestion.id));
    } on NotFoundFailure {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.linkSuggestionGone)));
    } on Object catch (error) {
      messenger?.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, error).$2)),
      );
    } finally {
      if (mounted) setState(() => _accepting = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final me = switch (ref.watch(meProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final firstName = me?.account.firstName?.trim();
    final pending = [
      for (final clinic in me?.clinics ?? const <ClinicLink>[])
        if (clinic.linkStatus == LinkStatus.pending) clinic,
    ];
    return Scaffold(
      backgroundColor: KivetoColors.canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: KivetoColors.brand,
          onRefresh: _refresh,
          child: CustomScrollView(
            // A short list can be pulled too.
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  KivetoSpace.gutter,
                  KivetoSpace.xl3,
                  KivetoSpace.gutter,
                  KivetoSpace.xl,
                ),
                sliver: SliverList.list(
                  children: [
                    KivetoPageHeader(
                      firstName == null || firstName.isEmpty
                          ? l10n.homeGreetingNoName
                          : l10n.homeGreeting(firstName),
                      subtitle: l10n.clinicSearchSubtitle,
                    ),
                    ..._suggestions(l10n),
                    for (final clinic in pending) ...[
                      const SizedBox(height: KivetoSpace.xl),
                      PendingLinkCallout(clinicName: clinic.name),
                    ],
                    const SizedBox(height: KivetoSpace.xl),
                    KivetoSearchField(
                      semanticLabel: l10n.clinicSearchFieldLabel,
                      hintText: l10n.clinicSearchFieldHint,
                      controller: _text,
                      onChanged: _typed,
                    ),
                    const SizedBox(height: KivetoSpace.m),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _NearMeChip(
                        locating: _locating,
                        on: _query.near != null,
                        onPressed: () => unawaited(_nearMe()),
                      ),
                    ),
                  ],
                ),
              ),
              ..._results(l10n),
            ],
          ),
        ),
      ),
    );
  }

  /// One C-33b callout per record suggested; their failure says so, with a
  /// retry (the search unaffected).
  List<Widget> _suggestions(AppLocalizations l10n) =>
      switch (ref.watch(linkSuggestionsProvider)) {
        AsyncData(:final value) => [
          for (final suggestion in value)
            if (!_accepted.contains(suggestion.id)) ...[
              const SizedBox(height: KivetoSpace.xl),
              LinkSuggestionCallout(
                suggestion: suggestion,
                accepting: _accepting == suggestion.id,
                onAccept: () => unawaited(_accept(suggestion)),
              ),
            ],
        ],
        AsyncError(isLoading: false) => [
          const SizedBox(height: KivetoSpace.xl),
          KivetoCallout.danger(
            body: l10n.linkSuggestionsError,
            actionLabel: l10n.commonRetry,
            onAction: () => ref.invalidate(linkSuggestionsProvider),
          ),
        ],
        _ => const [],
      };

  List<Widget> _results(AppLocalizations l10n) {
    final query = _query;
    final provider = clinicSearchProvider(query);
    Widget fill(Widget child) =>
        SliverFillRemaining(hasScrollBody: false, child: child);
    Widget padded(Widget sliver) => _padded(sliver);
    switch (ref.watch(provider)) {
      case AsyncValue(isLoading: true, hasError: true):
        return [fill(const LoadingView())];
      case AsyncData(:final value):
        _shown = (query: query, results: value);
        final items = value.items;
        if (items.isEmpty && value.nextCursor == null) {
          return [
            fill(
              EmptyState(
                glyph: LucideGlyph.search,
                title: l10n.clinicSearchEmptyTitle,
                // Around a position, the server searches within reach
                // only (and the clinics it can place).
                body: query.near == null
                    ? l10n.clinicSearchEmptyBody
                    : l10n.clinicSearchEmptyNearBody,
              ),
            ),
          ];
        }
        return [_list(l10n, query, value, provider: provider)];
      case AsyncError(:final error)
          when error is ValidationFailure && error.violations.isNotEmpty:
        _shown = null;
        // The server's word on the search (« Saisissez au moins 2
        // caractères. ») in place of the results.
        return [
          padded(
            SliverToBoxAdapter(
              child: Text(
                error.violations.first.message,
                style: KivetoText.bodySmall,
              ),
            ),
          ),
        ];
      case AsyncError(:final error):
        _shown = null;
        return [
          fill(
            ErrorView(error: error, onRetry: () => ref.invalidate(provider)),
          ),
        ];
      default:
        // Another search's first page on its way: the last results stay
        // in view under a thin progress bar.
        return switch (_shown) {
          (:final query, :final results) when results.items.isNotEmpty => [
            _list(l10n, query, results),
          ],
          _ => [fill(const LoadingView())],
        };
    }
  }

  Widget _padded(Widget sliver) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(
      KivetoSpace.gutter,
      KivetoSpace.xs,
      KivetoSpace.gutter,
      KivetoSpace.xl,
    ),
    sliver: sliver,
  );

  /// The count and the cards of [query]'s [results]; the footer reads the
  /// next page through [provider]. Without [provider] the results are the
  /// last ones shown while another search loads: a progress bar above the
  /// count, no footer.
  Widget _list(
    AppLocalizations l10n,
    ListingQuery query,
    ClinicSearchState results, {
    AsyncNotifierProvider<ClinicSearchNotifier, ClinicSearchState>? provider,
  }) {
    final items = results.items;
    final more = results.nextCursor != null;
    final stale = provider == null;
    final footer = more && !stale;
    // No count over an empty page that has a next one.
    final header = stale || items.isNotEmpty;
    final first = header ? 1 : 0;
    return _padded(
      SliverList.separated(
        itemCount: first + items.length + (footer ? 1 : 0),
        separatorBuilder: (context, index) =>
            const SizedBox(height: KivetoSpace.m),
        itemBuilder: (context, index) {
          if (header && index == 0) {
            // No total in the API: « Plus de … » while a page remains.
            final count = items.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (stale) ...[
                  LinearProgressIndicator(
                    minHeight: 2,
                    color: KivetoColors.brand,
                    backgroundColor: KivetoColors.brandSoft,
                    semanticsLabel: l10n.commonLoading,
                  ),
                  const SizedBox(height: KivetoSpace.s),
                ],
                if (items.isNotEmpty)
                  Text(
                    switch ((query.near == null, more)) {
                      (true, false) => l10n.clinicSearchCount(count),
                      (true, true) => l10n.clinicSearchMoreCount(count),
                      (false, false) => l10n.clinicSearchNearCount(count),
                      (false, true) => l10n.clinicSearchMoreNearCount(count),
                    },
                    style: KivetoText.labelSmall.copyWith(
                      color: KivetoColors.inkMuted,
                    ),
                  ),
              ],
            );
          }
          if (index == first + items.length) {
            return MoreFooter(
              loading: results.loadingMore,
              failed: results.moreError != null,
              onLoad: () => unawaited(ref.read(provider!.notifier).loadMore()),
            );
          }
          final clinic = items[index - first];
          return ClinicCard(
            key: ValueKey(clinic.id),
            clinic: clinic,
            onOpen: () {
              // The field let go first: the route's scope would give it
              // back its focus (and the keyboard) on the way back from 11.
              FocusManager.instance.primaryFocus?.unfocus();
              widget.onOpenListing(context, clinic.id.value);
            },
            onCall: (phone) => unawaited(callClinic(context, ref, phone)),
          );
        },
      ),
    );
  }
}

/// C-13d « Autour de moi »: a white chip with a map pin; « Localisation… »
/// disabled while the position is read; with a cross once [on] (tapped
/// again: back to the name order).
class _NearMeChip extends StatelessWidget {
  const new({
    required this.locating,
    required this.on,
    required this.onPressed,
  });

  final bool locating;
  final bool on;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      selected: on,
      child: KivetoSummaryChip.action(
        label: locating ? l10n.clinicSearchLocating : l10n.clinicSearchNearMe,
        leadingGlyph: LucideGlyph.mapPin,
        trailingGlyph: on && !locating ? LucideGlyph.x : null,
        onPressed: locating ? null : onPressed,
      ),
    );
  }
}
