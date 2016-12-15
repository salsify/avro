# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
module Avro
  module SchemaCompatibilityValidator
    UNCACHED_COMPARISONS = Schema::PRIMITIVE_TYPES_SYM.to_a.push(:fixed).freeze

    @compatible_schemas = {}

    def self.clear
      @compatible_schemas.clear
    end

    def self.can_read?(writers_schema, readers_schema)
      recursive_compatible_schemas(writers_schema, readers_schema)
    end

    def self.mutual_read?(writers_schema, readers_schema)
      can_read?(readers_schema, writers_schema) && can_read?(writers_schema, readers_schema)
    end

    # TODO: rename?
    def self.recursive_compatible_schemas(writers_schema, readers_schema, recursion_set = Set.new)
      cache_comparison(writers_schema, readers_schema, recursion_set) do
        recursive_match_schemas(writers_schema, readers_schema, recursion_set)
      end
    end

    def self.recursive_match_schemas(writers_schema, readers_schema, recursion_set)
      return false unless Avro::IO::DatumReader.match_schemas(writers_schema, readers_schema)

      return true if UNCACHED_COMPARISONS.include?(readers_schema.type_sym) && writers_schema.type_sym != :union # Hack!

      case readers_schema.type_sym
      when :record
        match_records(writers_schema, readers_schema, recursion_set)
      when :map
        recursive_compatible_schemas(writers_schema.values, readers_schema.values, recursion_set)
      when :array
        recursive_compatible_schemas(writers_schema.items, readers_schema.items, recursion_set)
      when :union
        match_union(writers_schema, readers_schema, recursion_set)
      when :enum
        # reader's symbols must contain all writer's symbols
        (writers_schema.symbols - readers_schema.symbols).empty?
      else
        if writers_schema.type_sym == :union && writers_schema.schemas.size == 1
          recursive_compatible_schemas(writers_schema.schemas.first, readers_schema, recursion_set)
        else
          false
        end
      end
    end

    def self.schema_pair_key(writers_schema, readers_schema)
      unless UNCACHED_COMPARISONS.include?(readers_schema.type_sym)
        [Digest::SHA256.hexdigest(readers_schema.to_s),
         Digest::SHA256.hexdigest(writers_schema.to_s)]
      end
    end

    def self.cache_comparison(writers_schema, readers_schema, recursion_set)
      key = schema_pair_key(writers_schema, readers_schema)

      return true if recursion_set.include?(key)

      @compatible_schemas.fetch(key) do
        recursion_set.add(key) if key
        result = yield
        @compatible_schemas[key] = result if key
        #puts "#{writers_schema}, #{readers_schema}, #{result}"
        result
      end
    end

    def self.match_union(writers_schema, readers_schema, recursion_set)
      raise 'readers_schema must be a union' unless readers_schema.type_sym == :union

      case writers_schema.type_sym
      when :union
        writers_schema.schemas.all? { |writer_type| recursive_compatible_schemas(writer_type, readers_schema, recursion_set) }
      else
        readers_schema.schemas.any? { |reader_type| recursive_compatible_schemas(writers_schema, reader_type, recursion_set) }
      end
    end

    def self.match_records(writers_schema, readers_schema, recursion_set)
      writer_fields_hash = writers_schema.fields_hash
      readers_schema.fields.each do |field|
        if writer_fields_hash.key?(field.name)
          return false unless recursive_compatible_schemas(writer_fields_hash[field.name].type, field.type, recursion_set)
        else
          return false unless field.default?
        end
      end

      return true
    end
  end
end
