# README

## Approach

I thought about building a very pure front-end app, but decided I wanted to show off more full-stack skills, so the app is a full Rails app.

## What could still be done

* There is a lot of visual polish and refinement that's still possible; this is a "low-design" approach that focuses on the interactions more than the pretty pixels.
* The next feature I would have written is a configuration for auto-filling new pay periods. The current code assumes a biweekly default cadence, but that should be configurable by account. (Of course, there are no accounts either). I'd then couple that configuration with either auto-provisioning of future pay period records, or provisioning on demand, in a "Give me another x weeks" kind of interaction.

## Getting started

### Ruby

You'll need Ruby installed on your machine. Check the `.ruby-version` file for the correct version.

### Bundler

If your Ruby doesn't have `bundler` installed, run this first:

    gem install bundler

Then, install the dependencies with:

    bundle install

### Database

The app uses sqlite3 for maximum portability, although that's a terrible thing to deploy into production in a cloud-style environment.

To create the database and seed it:

    rails db:setup

### Testing

To run the test suite, it's as you would expect from a Rails app:

    rails test
