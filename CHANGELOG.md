## [Unreleased]

## [0.1.2] - 2025-11-06

### Fixed
- Fixed GitHub Actions badge URL in README to display correctly
- Fixed gem version badge display on RubyGems page

## [0.1.1] - 2025-11-06

### Fixed
- Fixed render_template to handle both %{key} and %<key>s string interpolation formats
- Fixed gemspec validation error by excluding gem files from repository

### Changed
- Applied RuboCop auto-corrections and style improvements
- Updated RuboCop configuration with NewCops enabled
- Improved code formatting and consistency across all files
- Updated ENV variable access to use ENV.fetch for better nil handling

## [0.1.0] - 2025-11-05

- Initial release
