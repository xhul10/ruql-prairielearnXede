# Ruql::Prairielearn

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/ruql/prairielearn`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruql-prairielearn'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruql-prairielearn

## Usage


`ruql prairielearn --default-topic=`_topic_ `[--omit-tags=`_tag1,tag2_`] [--extra-tags=`_tag1,tag2,tag3_`] ruql_file.rb`

Converts questions in `ruql_file.rb` into a set of PrairieLearn question
generators.  Each question will go in its own subdirectory containing
`question.html` and `info.json`.  These are assumed to be questions
that require no special server-side files.
The attribute `singleVariant` will be set to `true` in
`info.json` since these questions are by definition single-variant.

Supported RuQL question types and their PrairieLearn equivalent
elements are as follows; unsupported questions are ignored with a
warning printed to standard error:

* `choice_answer` --

* `select_multiple` --

* `truefalse` --


### If a RuQL question has one or more `tags`:

* The first tag (with all non-alphanumeric characters replaced by de-dup'd underscores, and all lowercased)
will be used as the subdirectory name;
for example, `P&D vs. Agile` will become `p_d_vs_agile`.  If there are
name collisions, then `_2`, `_3`, etc. will be appended to subsequent
names.

* The first tag, first-word-capitalized but
otherwise verbatim, will be used as the question's `title`
attribute in `info.json`.  Question titles need not be unique,
so it's fine for multiple questions to have the same title.

* If a tag begins with `topic:`, the rest of the tag is used as the
  question's `topic` in `info.json`, which means it must appear in the
  list of topics in `infoCourse.json`.

### If the question does not have `tags`:

* A random UUID will be generated as the subdirectory name and also
used as the question's `title`.

* The value of the required `--default-topic=` option on the command line will be used
as the topic.


### PrairieLearn-specific interpretation of certain tags

If a question's tag list includes any tags given in the `--omit-tags`
command line argument, that question
won't be converted to PL format at all.  At Berkeley we use this for questions
that were designed to be simple manually-constructed variants placed into the same logical
RuQL group for delivery via Canvas; we hand-convert those to
PrairieLearn and use its question generator ability.

Furthermore, the tag `radio` will be added for single-answer multiple
choice (`choice_answer` in RuQL) questions, and `checkbox` will be
added for select-all-that-apply (`select_multiple` in RuQL) questions.

### Additional tags

You can optionally specify `--extra-tags=tag1,tag2,tag3` on the command line
(where each tag can contain any characters except commas; it's your
job to escape them properly from the shell) as extra tags that will be
added to *all* questions.  For example, this can indicate who imported
the questions.

The final list of a question's tags is sorted in alphabetical order.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ruql-prairielearn. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Ruql::Prairielearn project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ruql-prairielearn/blob/master/CODE_OF_CONDUCT.md).
