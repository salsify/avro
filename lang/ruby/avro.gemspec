# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'avro'
  spec.version       = File.open('lib/avro/VERSION.txt').read.chomp
  spec.authors       = ['Apache Software Foundation']
  spec.email         = ['dev@avro.apache.org']
  spec.summary       = 'Apache Avro for Ruby'
  spec.description   = 'Avro is a data serialization and RPC format'
  spec.homepage      = 'https://avro.apache.org/'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.test_files    = Dir.glob('test/**/*')
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency 'multi_json', ' ~>1'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'snappy'
  spec.add_development_dependency 'zstd-ruby'
  spec.add_development_dependency 'test-unit'

  # parallel 1.20.0 requires Ruby 2.5+
  spec.add_development_dependency 'parallel', '<= 1.19.2'

  # rubocop 0.82 requires Ruby 2.4+
  spec.add_development_dependency 'rubocop', '<= 1.6'

  # rdoc 6.2.1 requires Ruby 2.4+
  spec.add_development_dependency 'rdoc', '<= 6.2.0'
end
