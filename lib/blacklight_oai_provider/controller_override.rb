# Meant to be applied on top of a controller that implements
# Blacklight::SolrHelper. Will inject range limiting behaviors
# to solr parameters creation. 
module BlacklightOaiProvider::ControllerOverride
  def self.included(some_class)
    some_class.helper_method :oai_config
  end

  # Action method of our own!
  # Delivers a _partial_ that's a display of a single fields range facets.
  # Used when we need a second Solr query to get range facets, after the
  # first found min/max from result set. 
  def oai
    options = params.delete_if { |k,v| %w{controller action}.include?(k) }
    provider = BlacklightOaiProvider::SolrDocumentProvider.new
    render :text => provider.process_request(options), :content_type => 'text/xml'
  end

  # Uses Blacklight.config, needs to be modified when
  # that changes to be controller-based. This is the only method
  # in this plugin that accesses Blacklight.config, single point
  # of contact. 
  def oai_config(solr_field)    
    Blacklight.config[:oai] || {}
  end
end
