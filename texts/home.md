CPANTS is a testing service for CPAN distributions. One of its goals is to provide some sort of quality measure called *Kwalitee*. Though it looks and sounds like quality, higher Kwalitee score doesn't always mean a distribution is more useful for you. All it can assure is it's less likely for you to encounter problems on installation, the format of manuals, licensing, or maybe portability, as most of the CPANTS metrics are based on the past toolchain/QA issues you may or may not remember.

If you are a CPAN author, search and visit your Kwalitee report page, and fix at least core fails (if any) for better CPAN experiences.

### Limitations

CPANTS is not about running the test suite that most distributions ship with. This is done by the [CPAN Testers][].

[CPAN Testers]: http://www.cpantesters.org/

One big limitation of CPANTS is that it cannot actually execute any code: The module might not run on the machine doing the testing, it might have third-party dependencies, etc. CPANTS can only gather data and Kwalitee by looking at files, source code etc. This means that there are a lot of bugs in the Kwalitee-calculating code. Don't take everything here too serious! In a future version it might be possible to collect metadata from various distributed testers who run the tests on different platforms and settings (as CPAN testers do).
