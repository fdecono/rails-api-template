# Shared examples for common model validations
# These can be reused across different model specs

RSpec.shared_examples "common validations" do |model_class, attributes|
  describe "validations" do
    # Test presence validations
    attributes[:presence]&.each do |attr|
      it { should validate_presence_of(attr) }
    end

    # Test uniqueness validations
    attributes[:uniqueness]&.each do |attr|
      it { should validate_uniqueness_of(attr).case_insensitive }
    end

    # Test length validations
    attributes[:length]&.each do |attr, options|
      if options[:minimum]
        it { should validate_length_of(attr).is_at_least(options[:minimum]) }
      end
      if options[:maximum]
        it { should validate_length_of(attr).is_at_most(options[:maximum]) }
      end
      if options[:is]
        it { should validate_length_of(attr).is_equal_to(options[:is]) }
      end
    end

    # Test numericality validations
    attributes[:numericality]&.each do |attr, options|
      if options[:greater_than]
        it { should validate_numericality_of(attr).is_greater_than(options[:greater_than]) }
      end
      if options[:less_than]
        it { should validate_numericality_of(attr).is_less_than(options[:less_than]) }
      end
      if options[:only_integer]
        it { should validate_numericality_of(attr).only_integer }
      end
    end

    # Test inclusion validations
    attributes[:inclusion]&.each do |attr, options|
      it { should validate_inclusion_of(attr).in_range(options[:in]) }
    end
  end
end

# Shared example for common associations
RSpec.shared_examples "common associations" do |model_class, associations|
  describe "associations" do
    associations[:belongs_to]&.each do |association|
      it { should belong_to(association) }
    end

    associations[:has_many]&.each do |association|
      it { should have_many(association) }
    end

    associations[:has_one]&.each do |association|
      it { should have_one(association) }
    end

    associations[:has_and_belongs_to_many]&.each do |association|
      it { should have_and_belong_to_many(association) }
    end
  end
end

# Shared example for common scopes
RSpec.shared_examples "common scopes" do |model_class, scopes|
  describe "scopes" do
    scopes.each do |scope_name, expectations|
      describe ".#{scope_name}" do
        expectations.each do |expectation|
          case expectation[:type]
          when :returns_records
            it "returns the expected records" do
              result = model_class.send(scope_name)
              if expectation[:count]
                expect(result.count).to eq(expectation[:count])
              end
              if expectation[:includes]
                expectation[:includes].each do |included_record|
                  expect(result).to include(included_record)
                end
              end
              if expectation[:excludes]
                expectation[:excludes].each do |excluded_record|
                  expect(result).not_to include(excluded_record)
                end
              end
            end
          when :chains_with
            it "chains with other scopes" do
              chained_result = model_class.send(scope_name).send(expectation[:scope])
              expect(chained_result).to be_a(ActiveRecord::Relation)
            end
          end
        end
      end
    end
  end
end
