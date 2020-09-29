# Batting Average

## Intro

This project is a solution for Batting Averages Backend Exercise, outlined in [README.backend.md](README.backend.md).

The resulting CLI app is `bacalc`.

## Setup

The application requires Ruby 2.7.1 to run and is based on [Thor](http://whatisthor.com/) Ruby gem.

- Make sure you have required Ruby version installed
- Clone the repo
- Cd into the directory
- Execute `bundle install`
- Symlink `bacalc` to a directory accessible in your $PATH environment variable

## Usage

The application accepts an input CSV file name and optional team name and year filters.

```bash
bacalc calculate Batting.csv --year=1901 --team="Cincinnati Reds"
```

It also can list the known team names.

```bash
bacalc teams
```

## Test

Run `bundle exec rake test` to run tests.

Run linter with `bundle exec rubocop`.
