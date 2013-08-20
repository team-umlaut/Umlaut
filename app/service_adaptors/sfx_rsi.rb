# Service that searches SFX Rapid Service Indicator API to check
# item availability.
# Rapid Service Indicator API is documented at:
# http://www.exlibrisgroup.org/display/SFXOI/Rapid+Service+Indicator
# (needs login)

class SfxRsi < Service
  include MetadataHelper

  attr_writer :ip, :institute
  attr_reader :message, :fulltext_found, :status_ok

  def service_types_generated
    [ ServiceTypeValue['fulltext'] ]
  end

  def initialize(config)
    super
  end

  def handle(request)
    data = get_data(request)
    query = build_query(data)
    response = send_query(query)
    process_response(response)

    request.dispatched(self, @status_ok)
  end

  # Process request to extract metadata for api call
  def get_data(request)
    metadata = request.referent.metadata
    data = {}
    data[:identifier] = {}
    data[:identifier][:isbn] = get_isbn(request.referent)
    data[:identifier][:issn] = get_issn(request.referent)
    data[:identifier][:lccn] = get_lccn(request.referent)
    data[:identifier][:object_id] = metadata['object_id']
    data[:ip] = @ip || metadata['req:id']
    data[:year] = metadata['date']
    data[:institute_name] = @institute
    #get rid of any empty values
    data[:identifier].delete_if{|key,value| value.nil? || value.empty?}
    data.delete_if{|key,value| value.nil? || value.empty?}
    data
  end

  # Convert metadata hash to xml query as per RSI spec
  def build_query(data)
    return if !data.has_key?(:identifier) || data[:identifier].empty?

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.IDENTIFIER_REQUEST(
          "version" => "1.0",
          "xsi:noNamespaceSchemaLocation" => "ISSNRequest.xsd",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance"
      ) do
        xml.IDENTIFIER_REQUEST_ITEM do
          #the identifiers need a special display
          data[:identifier].each { |type, value|  xml.IDENTIFIER "#{type}:#{value}" }
          data.each { |key, value|  xml.send(key.upcase, value) unless key == :identifier }
        end
      end
    end
    builder.to_xml
  end

  # Send query via GET
  # POST is preferred but didn't work for me
  def send_query(query)
    client = HTTPClient.new
    response = client.get(@base_url, {:request_xml => query } )
    response.content
  end

  # Run processing on XML response
  def process_response(response)
    xml = Nokogiri::XML(response)
    #if we got a bad response - log and quit
    check_service_status(xml)
    unless @status_ok
      Rails.logger.error("Error in SFX RSI query: #{get_message(xml)}")
      return
    end
    check_for_fulltext(xml)
  end

  # Check service status in api response
  def check_service_status(xml)
    request_message = xml.xpath("IDENTIFIER_RESPONSE/IDENTIFIER_REQUEST_RESULT").attr('RESULT').content
    @status_ok = request_message.downcase.include? "ok"
  end

  # If item is not found
  # return error message OR result message
  def get_message(item)
    details =  item.xpath('IDENTIFIER_RESPONSE_DETAILS')
    if details.xpath('CONTENT').empty?
      @message = details.xpath('RESULT').first.content
    else
      @message = details.xpath('CONTENT').first.content
    end
  end

  # see if we have a result: found, otherwise get the error message
  def check_for_fulltext(xml)
    #return true if we get a single hit
    items = xml.xpath('IDENTIFIER_RESPONSE/IDENTIFIER_RESPONSE_ITEM')
    items.each do |item|
      @fulltext_found ||= item_found?(item)
      get_message(item) unless @fulltext_found
    end
  end

  # check item to see if if it
  # result is found or not found
  def item_found?(item_node)
    result = item_node.xpath("IDENTIFIER_RESPONSE_DETAILS/RESULT").first.content
    !result.downcase.include? "not"
  end


end
