#!/usr/bin/env ruby

require 'json'

puts JSON.generate(JSON.parse(ARGF.read), array_nl: "\n", object_nl: "\n", indent: "    ")


