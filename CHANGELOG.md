# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.12.0] - 2017-09-12

### Added

- New task that runs the production pipeline and merges reads before passing to
  spades for assembly.

### Changed

- Change spades parameters in the experimental task to treat the merged and
  unmerged reads as two different libraries.
