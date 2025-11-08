require 'geocoder/lookups/base'
require 'geocoder/results/reverse_geocoder'

##
#  Host endpoint: .../reverse?lat=?&lon=?
#  Host result: returns the python reverse_geocoder result in JSON
#  See python reverse_geocoder module for more details
module Geocoder::Lookup
  class ReverseGeocoder < Base

    def name
      "Reverse Geocoder"
    end

    def supported_protocols
      [:https, :http]
    end

    private # ---------------------------------------------------------------

    def base_query_url(query)
      if query.reverse_geocode?
        "#{protocol}://#{host}/reverse_geocode?"
      else
        raise "Forward geocode not supported"
      end
    end

    def query_url_params(query)
      params = {
      }.merge(super)

      if query.reverse_geocode?
        lat,lon = query.coordinates
        params[:lat] = lat
        params[:lon] = lon
      else
        params[:q] = query.sanitized_text
      end
      params
    end

    ##
    # called by fetch_data
    def parse_raw_data(raw_data)
      raw_data.match(/^<html><title>404/) ? nil : super(raw_data)
    end

    def results(query)
      return [] unless doc = fetch_data(query)
      ap doc
      doc.is_a?(Array) ? doc : [doc]
      return doc.map{|r| remap_result(r)}
    end

    def remap_result(r)
      {
        lat: r["lat"],
        lon: r["lon"],
        city: r["name"],
        state: r["admin1"],
        county: r["admin2"],
        country_code: r["cc"]
      }
    end

    def reserved_result(ip)
      {
        'ip' => ip,
        'city' => '',
        'state' => '',
        'county' => '',
        'latitude' => '0',
        'longitude' => '0',
        'country_code' => 'RD'
      }
    end

    def host
      configuration[:host] || raise( "Reverse Geocoder requires the host configuration.")
    end
  end
end
