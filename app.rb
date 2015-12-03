require 'rubygems'
require 'sinatra'
Bundler.require

get '/' do
  'Visit <a href=\'/api?code=NRT\'>API</a> page with <code>?code=NRT</code>.' \
  '<br />' \
  'This example hits <code>http://www.webservicex.net/airport.asmx?WSDL</code>'
end

get '/api' do
  # Get paremeter
  code = params[:code]

  # We going ot play with this API
  unless code.nil? || code.strip.empty?
    client = Savon.client(wsdl: 'http://www.webservicex.net/airport.asmx?WSDL')
    response = client.call :get_airport_information_by_airport_code,
                           response_parser: :nokogiri,
                           message: { 'airportCode' => code.upcase }

    # Check if responce was successfull
    if response.success?
      dom = Nokogiri.XML(
        response.to_hash[:get_airport_information_by_airport_code_response] \
        [:get_airport_information_by_airport_code_result]
      )
      table = dom.xpath('//NewDataSet/Table')[0]
      @code = table.xpath('AirportCode').text
      @city = table.xpath('CityOrAirportName').text
      @country = table.xpath('Country').text
      "<strong>#{@code} is #{@city}</strong><br /> in #{@country}"
    else
      'Something went wrong'
    end
  end
end
