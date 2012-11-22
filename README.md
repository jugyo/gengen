# GenGen

A simple generator using github repository.

## Installation

    $ gem install gengen

## Usage

From github:

    $ gengen user/template [directory] [foo=bar ...]

↓

    $ gengen jugyo/sublime-plugin RubyUtils name=RubyUtils command=test

From local git repository:

    $ gengen --local(-l) git_repository_path [directory] [foo=bar ...]

↓

    $ gengen -l /path/to/sublime-plugin RubyUtils name=RubyUtils command=test

## Creating Template

It is simple. You can embed variables to template using `{{{var}}}`:

    import sublime, sublime_plugin

    class {{{name}}}Command(sublime_plugin.TextCommand):
      def run(self, edit):
        sublime.message_dialog("foo")

You can also embed variables in file name:

    {{{name}}}.py

## Example Templates

* [sublime-plugin.gengen](https://github.com/jugyo/sublime-plugin.gengen)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
