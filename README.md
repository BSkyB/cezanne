[![Build Status](https://travis-ci.org/sky-uk/cezanne.svg?branch=master)](https://travis-ci.org/sky-uk/cezanne)
[![Coverage Status](https://coveralls.io/repos/sky-uk/cezanne/badge.svg?branch=master&service=github)](https://coveralls.io/github/sky-uk/cezanne?branch=master)

# Cezanne

Cross-browser visual regression testing tool

## Installation

Add this line to your application's Gemfile:

    gem 'cezanne'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cezanne

## Usage 
### RSpec

In your `spec_helper.rb`
    
    require 'cezanne/rspec'
    
    RSpec.configure do |config|
      config.include Cezanne
    end

    Cezanne.configure do |config|
      config.uid = ENV['build_number']
      config.project_name = 'awesome_app'
    end

The `uid` should be a unique identifier. We use the build number, but it can be a static string if you don't need
to keep multiple versions of the screenshots.

In your tests

    
    describe 'Mont Sainte-Victoire', screenshots: true do
      it 'is a masterpiece' do
        visit 'url-to-painting'
        check_visual_regression_for 'mont-sainte-victoire'
      end
    end

Make sure to use a unique name for each screenshot. 
The associate file will be a gif image named after the parameter (`'mont-sainte-victoire'` in the example above)
and the browser name & version, to make it easy to check visual regressions on multiple browsers.

## Dependencies

Cezanne uses ImageMagick. Check with your package manager.

Screenshots are taken using Capybara and its configured driver (local, headless, remote) as long as it supports screenshots.

Screenshots images (`.gif`) are stored on Dropbox. Follow the instructions at https://www.dropbox.com/developers/core and 
export your oAuth access token

    export DROPBOX_ACCESS_TOKEN=**insert dropbox access token here**


## (Opinionated) Workflow

* Reference screenshots are stored on Dropbox
* New and different screenshots will be synced to Dropbox at the end of the test suite 


    ```
    project_name
    |
    +-- reference_screenshots
    |
    +-- uid
    |   |
    |   +-- new_screenshots
    |   |
    |   +-- different_screenshots
    |
    |
    +-- uid_2
        |
        ...
    ```

## Tests

To run the specs

1. clone the repo `git clone git@github.com:sky-uk/cezanne.git`
2. cd into it `cd cezanne`
3. install deps `gem install bundler && bundle install`
4. run the specs `rspec`

(integration tests use Firefox by default)

## Authors

Made with <3 by the Sky Haiku team

Got questions? Ask Ben (ben.stokoe@sky.uk) or Andrea (andrea.pigato@sky.uk)
