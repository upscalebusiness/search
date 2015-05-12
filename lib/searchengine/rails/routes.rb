module ActionDispatch::Routing
  class Mapper
    def searchability_for(resource, options={})
      #get "#{route_format resource}", to: "#{options[:controller]}#query"
      get "query", to: "#{options[:controller]}#query"
    end

    private
    def route_format(resource)
      resource.to_s.underscore
    end
  end
end