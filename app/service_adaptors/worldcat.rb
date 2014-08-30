# Link to worldcat.org that relies on screen scraping to see if it's gotten
# a hit. 
#
# Warning, worldcat can be awfully slow to respond. 
# optional search_zip_code param.
# Optional base_url param, but I don't know why you'd want to change it.
# display_text
require 'uri'
require 'net/http'
class Worldcat < Service
  include MetadataHelper
  include UmlautHttp
  
  def initialize(config)
    # defaults
    @suppress_precheck = false # it seems unneccesary to pre-check worldcat, it's mostly ALWAYS a positive hit. And pre-checking against worldcat is running into Worldcat's rate limiting defenses. If neccesary, you can turn this off. Really, we should be using the Worldcat API anyway. 
    @base_url = 'http://www.worldcat.org/'
    @display_text = :worldcat_link_name
    @display_name = 'OCLC WorldCat.org'
    
    @credits = {
      "OCLC WorldCat.org" => "http://www.worldcat.org/"
    }
    
    super(config)
  end

  def service_types_generated
    return [ServiceTypeValue['highlighted_link']]
  end
  
  def handle(request)
    isbn = get_identifier(:urn, "isbn", request.referent)
    issn = get_identifier(:urn, "issn", request.referent)
    oclcnum = get_identifier(:info, "oclcnum", request.referent)
    
    
    isxn_key = nil
    isxn_value = nil
    if (! oclcnum.blank?)
      isxn_key = 'oclc'
      isxn_value = oclcnum    
    elsif (! issn.blank?)
      isxn_key = 'issn'
      #isxn_value = ref_metadata['issn'] + '+dt:ser'
      isxn_value = issn
    elsif (! isbn.blank?)
      isxn_key = 'isbn'
      isxn_value = isbn
    else
      # We have no useful identifiers
      return request.dispatched(self, true)
    end

    # Do some cleanup of the value. Sometimes spaces or other
    # weird chars get in there, why not strip out everything that
    # isn't a number or X?
    isxn_value = isxn_value.gsub( /[^\dX]/, '')
    # and URL escape just to be safe, although really shouldn't be neccesary
    isxn_value = URI.escape( isxn_value )
    
    # We do a pre-emptive lookup to worldcat to try and see if worldcat
    # has a hit or not, before adding the link.
    isxn_key = URI.escape( isxn_key )
    uri_str = @base_url+isxn_key+'/'+isxn_value
    uri_str +=  "&loc=#{URI.escape(@search_zip_code.to_s)}" if @search_zip_code

    
    begin
      worldcat_uri = URI.parse(uri_str)
    rescue Exception => e
      Rails.logger.error("Bad worldcat uri string constructed?")
      Rails.logger.error(e)
      return request.dispatched(self, DispatchedService::FailedFatal)
    end

    unless ( @suppress_precheck )
    
      http = Net::HTTP.new worldcat_uri.host
      http.open_timeout = 7
      http.read_timeout = 7
  
      
      begin
        # Fake being a proxy to send info on actual end-user client to worldcat,
        # to lessen chance of worldcat traffic limiters. 
        headers = proxy_like_headers( request, worldcat_uri.host )
        wc_response = http.get(worldcat_uri.path, headers)
      rescue  Timeout::Error => exception
        return request.dispatched(self, DispatchedService::FailedTemporary, exception)
      end
  
      # Bad response code?
      unless wc_response.code == "200"
        # Could be temporary, could be fatal. Let's say temporary. 
        return request.dispatched(self, DispatchedService::FailedTemporary, Exception.new("oclc returned error http status code: #{wc_response.code}"))
      end
  
      # Sadly, worldcat returns a 200 even if there are no matches.
      # We need to screen-scrape to discover if there are matches.
      if (wc_response.body =~ /The page you tried was not found\./)
        # Not found in worldcat, we won't add a link.
        return request.dispatched(self, true)
      end
    end
    
    request.add_service_response(
      :service=>self, 
      :url=>worldcat_uri.to_s,
      :display_text=>@display_text, 
      :service_type_value => :highlighted_link
      )
    
    return request.dispatched(self, true)
  end
end
