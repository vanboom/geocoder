require 'geocoder/results/base'

module Geocoder::Result
  class ReverseGeocoder < Base

    def address(format = :full)
      [
        city,
        state,
        county,
        [country.presence, country_code.presence].compact.join(" / ")
      ].compact.join(", ")
    end

    def county
      @data[:county]
    end

    def coordinates
      [@data[:lat].to_f, @data[:lon].to_f]
    end

    def city
      @data[:city]
    end

    def state
      @data[:state]
    end

    def state_code
      ""
    end

    def country
      @data[:country_name]
    end

    def country_code
      @data[:country_code]
    end

    def postal_code
      @data[:zip]
    end

    def self.response_attributes
      %w[country_code ip]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
