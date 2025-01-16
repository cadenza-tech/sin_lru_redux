# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'lru_redux'
require 'sin_lru_redux'
require 'minitest/autorun'
require 'minitest/pride'
require 'timecop'
