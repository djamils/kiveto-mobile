// The renewal request of screen 17: its draft compares by content (one
// Idempotency-Key per content), the receipt the server gave.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/domain/renewal.dart';

void main() {
  test('a draft equals another with the same condition and note', () {
    const draft = RenewalRequestDraft(
      condition: PetCondition.improved,
      note: 'Plus de grattage',
    );

    expect(
      draft,
      RenewalRequestDraft(
        condition: PetCondition.values.first,
        note: ['Plus de', 'grattage'].join(' '),
      ),
    );
    expect(
      draft.hashCode,
      const RenewalRequestDraft(
        condition: PetCondition.improved,
        note: 'Plus de grattage',
      ).hashCode,
    );
    expect(
      draft,
      isNot(const RenewalRequestDraft(condition: PetCondition.improved)),
    );
    expect(
      draft,
      isNot(
        const RenewalRequestDraft(
          condition: PetCondition.adverseEffects,
          note: 'Plus de grattage',
        ),
      ),
    );
    expect(draft == Object(), isFalse);
    expect(
      const RenewalRequestDraft(condition: PetCondition.noImprovement).note,
      isNull,
    );
  });

  test('a receipt: the request and its status', () {
    const receipt = RenewalReceipt(
      requestId: '01a19a12-87fc-7cd1-a51e-c25f03efc697',
      status: RenewalStatus.submitted,
    );

    expect(receipt.requestId, '01a19a12-87fc-7cd1-a51e-c25f03efc697');
    expect(receipt.status, RenewalStatus.submitted);
  });
}
