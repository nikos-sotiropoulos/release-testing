
**1. Underlier Refactoring**

Usage of the `Underlier` is being refactored to be consistent across all pay-out types that make reference to it, namely:
- `EquityPayout` (where `Underlier` was being uniquely used before)
- `OptionPayout` (which was using `Product` before)
- `ForwardPayout` (which directly specified the types of underlying products which could be used before)

As part of this refactoring, the `settlementTerms` attribute has also been rationalised within the `ForwardPayout` class, which now works in the same way as the `OptionPayout` class. The previous `settlementDate` attribute has been deprecated and moved to the broader `settlementTerms` one.

*Note*: a `valueDate` attribute of type `date` needed to be added within `settlementTerms`  in order to make this work with `ForeignExchange` pay-outs  because date is specified in hard, not adjustable. This should be fixed and merged with the existing `settlementDate` attribute, once the usage of various types of dates (absolute, adjustable or relative) is being refactored.

*Review directions*

See `OptionPayout` and `ForwardPayout`, and the “Ingestion” page on the CDM Portal for option and fx products.

**2. DAML Download Disabled**

Compiler has changed on DAML side, such that DAML code generated from CDM no longer builds. This will have to be looked as part of a subsequent release.
