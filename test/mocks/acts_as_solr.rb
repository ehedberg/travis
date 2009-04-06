module ActsAsSolr
  class Post    
    def self.execute(request)
    end
  end
  
  module ClassMethods
    # this override is very specific to our implementation! searching title and description fields.
    # this would break on any other models besides task or description
    def find_by_solr(query, options={})
      query = "%" + query + "%"
      limit = options[:limit].nil? ? "" : options[:limit]
      order = options[:order].nil? ? "" : options[:order]
      offset = options[:offset].nil? ? 0 : options[:offset]
      records = find(:all, 
        :conditions => ["title like ? or description like ?", query, query], 
        :offset => offset,
        :limit => limit,
        :order => order)
      ActsAsSolr::SearchResults.new(
        :docs => records,
        :total => records.length
      )
    end
    def count_by_solr(query)
      find(:all, :conditions => ["title like ? or description like ?", query, query]).length
    end
  end
end