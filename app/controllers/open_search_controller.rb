class OpenSearchController < UmlautController

  layout false

  def index
    render(:content_type => "application/xml")
  end
end