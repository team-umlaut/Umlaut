require 'test/test_helper'

class SfxRsiTest < ActiveSupport::TestCase

  def setup
    @service = ServiceStore.instantiate_service!("SFXRSI", nil)

  end

  def build_request(format, hash = {})
    context_object = OpenURL::ContextObject.new
    context_object.referent.set_format(format) if format

    hash.each_pair do |key, value|
      context_object.referent.set_metadata(key.to_s, value.to_s)
    end

    rft = Referent.create_by_context_object(context_object)

    req = Request.new
    req.referent = rft
    req.save!

    req
  end

  #Make sure request parser is working as it should
  def test_get_data
    req = build_request(
        "journal", :atitle => "Human-Machine Collaborative Planning",
        :au => "Allen, James F.", :aufirst => "James", :auinitm => "F", :aulast => "Allen",
        :epage => "29", :genre => "proceeding", :spage => "27", :object_id => '123456',
        :isbn => '789456', 'req:id' => '127.0.0.1'
    )
    data = @service.get_data(req)
    assert_not_nil(data, "Error - data is nil")
    assert_equal('123456', data[:identifier][:object_id], "Object id not parsed correctly")
    assert_equal('789456', data[:identifier][:isbn], "ISBN not parsed correctly")
    assert_equal('127.0.0.1', data[:ip], "IP not parsed correctly")
  end

  def test_build_query
    data = {:identifier => {:object_id => "123456" }, :ip => '127.0.0.1', :institute=> 'Science Lab' }
    query = @service.build_query(data)
    xml = Nokogiri::XML(query)
    ip = xml.xpath('IDENTIFIER_REQUEST/IDENTIFIER_REQUEST_ITEM/IP').first.content
    institute = xml.xpath('IDENTIFIER_REQUEST/IDENTIFIER_REQUEST_ITEM/INSTITUTE').first.content
    identifier = xml.xpath('IDENTIFIER_REQUEST/IDENTIFIER_REQUEST_ITEM/IDENTIFIER').first.content

    assert_equal('127.0.0.1', ip, 'XML Request not built properly')
    assert_equal('Science Lab', institute, 'XML Request not built properly')
    assert_equal('object_id:123456', identifier, 'XML Request not built properly')
  end

  def test_process_response
    error_response = '<?xml version="1.0"?><IDENTIFIER_RESPONSE VERSION="1.0">
      <IDENTIFIER_REQUEST_RESULT RESULT="OK" /><IDENTIFIER_RESPONSE_ITEM><IDENTIFIER_REQUEST_ITEM>
      </IDENTIFIER_REQUEST_ITEM><IDENTIFIER_RESPONSE_DETAILS><CONTENT>Not valid request item</CONTENT>
      <RESULT>not found</RESULT></IDENTIFIER_RESPONSE_DETAILS></IDENTIFIER_RESPONSE_ITEM>
      <REQUESTED_SERVICES></REQUESTED_SERVICES></IDENTIFIER_RESPONSE>'

    @service.process_response(error_response)
    assert_equal('Not valid request item', @service.message)

    response = "<?xml version='1.0' ?><IDENTIFIER_RESPONSE VERSION='1.0'><IDENTIFIER_REQUEST_RESULT RESULT='OK' />
    <IDENTIFIER_RESPONSE_ITEM><IDENTIFIER_REQUEST_ITEM><IDENTIFIER>object_id:111082404606014</IDENTIFIER>
    <ISSUE>15</ISSUE><VOLUME>1</VOLUME><YEAR>1995</YEAR><institute_name>science_lab</institute_name>
    </IDENTIFIER_REQUEST_ITEM><IDENTIFIER_RESPONSE_DETAILS><AVAILABLE_SERVICES>getFullTxt</AVAILABLE_SERVICES>
    <OBJECT_ID>111082404606014</OBJECT_ID><RESULT>notFound</RESULT></IDENTIFIER_RESPONSE_DETAILS>
    </IDENTIFIER_RESPONSE_ITEM><REQUESTED_SERVICES /></IDENTIFIER_RESPONSE>"

    #test for notFound before found
    @service.process_response(response)
    assert_false(@service.fulltext_found, 'Error parsing XML response.')

    response.gsub!('notFound', 'found')
    @service.process_response(response)
    assert_true(@service.fulltext_found, 'Error parsing XML response.')



  end

end