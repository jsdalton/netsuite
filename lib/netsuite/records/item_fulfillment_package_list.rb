module NetSuite
  module Records
    class ItemFulfillmentPackageList
      include Support::Fields
      include Support::Records
      include Namespaces::TranSales

      fields :package

      def initialize(attributes = {})
        if attributes.keys != [:package] && attributes.first

          transformed_attrs = {}
          object = attributes.first.last

          case object
          when Hash
            object.each do |k, v|
              transformed_attrs.merge!(normalize_key(k) => v)
            end
          when Array
            object.each do |hash|
              hash.each do |k, v|
                carrier_suffix_index = k.to_s.rindex('_')-1
                transformed_attrs.merge!(normalize_key(k) => v)
              end
            end
          end

          attributes = { package: transformed_attrs }
        end

        initialize_from_attributes_hash(attributes)
      end

      def package=(packages)
        case packages
        when Hash
          self.packages << ItemFulfillmentPackage.new(packages)
        when Array
          packages.each { |package| self.packages << ItemFulfillmentPackage.new(package) }
        end
      end

      def packages
        @packages ||= []
      end

      def to_record
        { "#{record_namespace}:package" => packages.map(&:to_record) }
      end

      # since we have to handle ups, fedex and ups, let's discard the carrier-specific
      # suffix so that we can use generic packages across the board
      def normalize_key(key)
        k = key.to_s
        ["_fed_ex", "_ups", "_usps"].each do |cs|
          k.slice! cs
        end
        k.to_sym
      end
    end
  end
end
