<img src="http://d324imu86q1bqn.cloudfront.net/uploads/user/avatar/641/large_Ello.1000x1000.png" width="200px" height="200px" />

# Ello Render Pipeline

This gem provides a convenient API to a customized [html-pipeline](https://github.com/jch/html-pipeline/) stack that we use for rendering posts and profiles on Ello.

[![Build Status](https://travis-ci.org/ello/render_pipeline.svg?branch=master)](https://travis-ci.org/ello/render_pipeline)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'render_pipeline', github: 'ello/render_pipeline'
```

And then execute:

    $ bundle


## Usage

```ruby
RenderPipeline.render('textual content')
```

The pipeline supports a few more advanced options, including the ability to configure multiple preset "contexts" with different rendering options. For now, see the tests for more information on how to set those up.

## Development

After checking out the repo, run `rake` to run the tests. 

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ello/render_pipeline.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


## Code of Conduct
Ello was created by idealists who believe that the essential nature of all human beings is to be kind, considerate, helpful, intelligent, responsible, and respectful of others. To that end, we will be enforcing [the Ello rules](https://ello.co/wtf/policies/rules/) within all of our open source projects. If you don’t follow the rules, you risk being ignored, banned, or reported for abuse.
