require 'umlaut'
require 'umlaut_configurable'

# Superclass for all Umlaut controllers, to hold default behavior,
# also hold global configuration. It's a superclass rather than a module,
# so we can use Rails 3 hieararchical superclass view lookup too if we want,
# for general umlaut views. And also so local app can over-ride
# methods here once, and have it apply to all Umlaut controllers.
# But there's not much magic in here or anything, the
# common behavior is ordinary methods available to be called, mostly. 
#
# This class is copied into the local app -- the default implementation
# does nothing but 'include Umlaut::ControllerBehavior'
#
# You will ordinarily set config here, and can also over-ride
# methods from Umlaut::ControllerBehavior if desired. Or add
# additional helpers to over-ride Umlaut helpers if needed. 
class UmlautController < ApplicationController
    include Umlaut::ControllerBehavior

    # Code to enable localisation

    before_filter :set_locale

    # if no locale is set, will default to default_locale (i.e. en)
    def set_locale
      I18n.locale = params['umlaut.locale'.to_sym] || I18n.default_locale
    end

    # ensure locale is always included in any internal links
    def default_url_options(options={})
      { 'umlaut.locale'.to_sym => I18n.locale }
    end


    # Some suggested configuration. More config keys
    # are available, see UmlautConfigurable.set_default_configuration!
    # implementation for list. Configuration actually uses
    # a Confstruct object. 
    
    umlaut_config.configure do 
      # app_name 'Find It'
      
      # URL to image to use for link resolver in some self-links, 
      # OR name of image asset in local app. 
      #link_img_url "http//something"
      
      # Sometimes Umlaut sends out email, what email addr should it be from?
      # from_email_addr 'no_reply@umlaut.example.com'
      
      # Local layout for UmlautController's, instead of
      # built in 'umlaut' layout?
      # layout "application"
      
      # A help url used on error page and a few other places.
      # help_url  "http://www.library.jhu.edu/services/askalib/index.html"

      # If OpenURL came from manual entry of title/ISSN, and no match is found in
      # link resolver knowledge base, display a warning to the user of potential
      # typo?
      # entry_not_in_kb_warning true
      
      # rfr_ids used for umlaut generated pages.
      # rfr_ids do
      #   opensearch  "info:sid/umlaut.code4lib.org:opensearch"
      #  citation    "info:sid/umlaut.code4lib.org:citation"
      #   azlist      'info:sid/umlaut.code4lib.org:azlist'
      # end
      
      # Referent filters. Sort of like SFX source parsers.
      # hash, key is regexp to match a sid, value is filter object
      # (see lib/referent_filters )        
      # add_referent_filters!( :match => /.*/, :filter => DissertationCatch.new ) 
    
      # How many seconds between updates of the background updater for background
      # services?
      # poll_wait_seconds 4

      # uncomment this line to show localisation selector
      localisation_enabled true
      
      # Configuration for the 'search' functions -- A-Z lookup
      # and citation entry. 
      search do
        # Is your SFX database connection, defined in database.yml under
        # sfx_db and used for A-Z searches, Sfx4 or do you want to use Sfx4Solr?  
        # Other SearchMethods in addition to SFX direct db may be provided later. 
        #az_search_method  SearchMethods::Sfx4
        #az_search_method  SearchMethods::Sfx4Solr::Local
        
        # When talking directly to the SFX A-Z list database, you may
        # need to set this, if you have multiple A-Z profiles configured
        # and don't want to use the 'default.
        # sfx_az_profile "default"    
                
        # can set to "_blank" etc. 
        # result_link_target nil        
      end
      
      # config only relevant to SFX use  
      sfx do      
        # base sfx url to use for search actions, error condition backup,
        # and some other purposes. For search actions (A-Z), direct database
        # connection to your SFX db also needs to be defined in database.yml
        # sfx_base_url  'http://sfx.library.jhu.edu:8000/jhu_sfx?'
        # 
  
        
        
        # Umlaut tries to figure out from the SFX knowledge base
        # which hosts are "SFX controlled", to avoid duplicating SFX
        # urls with urls from catalog. But sometimes it misses some, or
        # alternate hostnames for some. Regexps matching against
        # urls can be included here. Eg,
        # AppConfig::Base.additional_sfx_controlled_urls = [
        #    %r{^http://([^\.]\.)*pubmedcentral\.com}
        #  ]    
        # additional_sfx_controlled_urls = []
        
        
      end
      
      # Advanced topic, you can declaratively configure
      # what sections of the resolve page are output where
      # and how using resolve_sections and add_resolve_sections!            
      
    end
    
    
end
