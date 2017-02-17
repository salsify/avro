This fork of Apache Avro is being used to release a
avro-salsify-fork Ruby gem.

This fork contains:
- changes to support logical types: https://github.com/apache/avro/pull/116
- a full schema compatibility check for ruby: https://github.com/apache/avro/pull/170
- support for ruby 2.4: https://github.com/apache/avro/pull/191

To use this gem add the following to your Gemfile:

  gem 'avro-salsify-fork', '1.9.0.5', require: 'avro'

--------------------------------------------------------------------

Apache Avro™ is a data serialization system.

Learn more about Avro, please visit our website at:

  http://avro.apache.org/

To contribute to Avro, please read:

  https://cwiki.apache.org/confluence/display/AVRO/How+To+Contribute
