module Ishin
  # Can be used to include the Ishin functionality into your class and provides
  # a `.to_hash` method.
  module Mixin
    # Calls `Ishin.to_hash` and passes the parameters on.
    # @param options [Hash]
    # @see Ishin.to_hash
    def to_hash(options = {})
      Ishin.to_hash(self, options)
    end
  end
end
