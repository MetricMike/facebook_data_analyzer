# frozen_string_literal: true

# My script for 'I analyzed my facebook data and it's story of shyness,
# loneliness and change'
module FacebookDataAnalyzer
  require 'facebook_data_analyzer/analyzeables/analyzeable'
  require 'facebook_data_analyzer/analyzeables/contacts'
  require 'facebook_data_analyzer/analyzeables/friends'
  require 'facebook_data_analyzer/analyzeables/messages'
  require 'facebook_data_analyzer/contact'
  require 'facebook_data_analyzer/friend'
  require 'facebook_data_analyzer/message'

  require 'axlsx'
  require 'parallel'
  require 'json'
  require 'workbook'
  require 'set'

  def self.run(options = {})
    catalog        = options.fetch(:catalog)
    xlsx           = [options.fetch(:filename), 'xlsx'].join('.')
    html           = [options.fetch(:filename), 'html'].join('.') if options.fetch(:html)
    parallel_usage = options.fetch(:parallel)

    package = ::Axlsx::Package.new

    analyzeables = [Messages.new(catalog: catalog, options: options),
                    Contacts.new(catalog: catalog),
                    Friends.new(catalog: catalog)]

    analyzeables.each do |analyzeable|
      analyzeable.analyze
      analyzeable.export(package: package)
    end

    puts "= Export #{xlsx}"
    package.serialize(xlsx)

    if html
      puts "= Export #{html}"
      b = ::Workbook::Book.open(xlsx)
      b.write_to_html(html)
    end
  end
end
