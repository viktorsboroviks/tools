# mdl config file
# official reference: https://github.com/markdownlint/markdownlint/blob/master/docs/configuration.md
# some examples: https://github.com/markdownlint/markdownlint/issues/67
all

# in some code blocks tabs are used
#
# this fix was added in master, but not yet released:
# https://github.com/markdownlint/markdownlint/pull/404
# ```rb
# rule "MD010", :ignore_code_blocks => true
# ``
exclude_rule 'MD010'

# allow headers to end with '?'
rule "MD026", :punctuation => ".,;:"

# ordered list item prefix, shoulded be ordered
rule "MD029", :style => :ordered
