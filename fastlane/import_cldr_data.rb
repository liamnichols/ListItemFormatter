require 'faraday'
require 'json'
require 'fileutils'

IS_PARTIAL_DATA_FETCH_ENABLED = false # When set to true, allows fetching of only part of the data to speed up testing

def import_cldr_data(cldr_tag, asset_catalog_path)
data_source = CLDRDataSource.new(cldr_tag)
exporter = CLDRExporter.new(data_source, asset_catalog_path)
exporter.export
end

class CLDRDataSource

  def initialize(tag)
    @tag = tag
  end

  def tag
    @tag
  end

  def parent_locales
    @parent_locales ||= load_parent_locales
  end

  def available_locales
    @available_locales ||= load_available_locales
  end

  def all_list_patterns
    @all_list_patterns ||= load_all_list_patterns
  end

  private

    def load_parent_locales
      json = json_from_url "https://raw.githubusercontent.com/unicode-cldr/cldr-core/#{tag}/supplemental/parentLocales.json"
      json["supplemental"]["parentLocales"]["parentLocale"] unless json.nil?
    end

    def load_available_locales
      json = json_from_url "https://raw.githubusercontent.com/unicode-cldr/cldr-core/#{tag}/availableLocales.json"
      json["availableLocales"]["full"] unless json.nil?
    end

    def load_all_list_patterns
      all_list_patterns = {}
      current_step = 1
      available_locales.each { |locale|
        print "\rLoading list patterns #{current_step}/#{available_locales.count}  "
        next if IS_PARTIAL_DATA_FETCH_ENABLED && current_step >= 10
        all_list_patterns[locale] = load_list_patterns_for_locale(locale)
        current_step += 1
      }
      print "\n"
      all_list_patterns
    end

    def load_list_patterns_for_locale(locale)
      json = json_from_url "https://raw.githubusercontent.com/unicode-cldr/cldr-misc-full/#{tag}/main/#{locale}/listPatterns.json"
      json["main"][locale]["listPatterns"] unless json.nil?
    end

    def json_from_url(url)
      response = Faraday.get(url)
      return nil unless response.status == 200
      json = JSON.parse(response.body)
    end
end

class CLDRExporter

  def initialize(data_source, asset_catalog)
    @parent_locales = data_source.parent_locales.map { |k,v| [normalize_locale_identifier(k), normalize_locale_identifier(v)] }.to_h
    @all_list_patterns = data_source.all_list_patterns.map { |k,v| [normalize_locale_identifier(k), v] }.to_h
    @asset_catalog = asset_catalog
  end

  def export

    resources = required_list_patterns.map { |k,v| ListPatterns.new(k, v) }
    resources << LocaleInformation.new(parent_locales, required_locale_identifiers)

    create_asset_catalog(asset_catalog)
    resources.each { |r| r.write(asset_catalog) }
  end

  private

    def asset_catalog
      @asset_catalog
    end

    def create_asset_catalog(directory)

      contents_path = File.join(asset_catalog, "Contents.json")
      contents = {
        :info => {
          :version => 1,
          :author => "xcode"
        }
      }

      FileUtils.remove_dir(asset_catalog) if File.exists? asset_catalog
      FileUtils.mkdir_p(asset_catalog)

      File.open(contents_path,"w") do |f|
        f.write(JSON.pretty_generate(contents))
      end
    end

    def parent_locales
      @parent_locales
    end

    def all_list_patterns
      @all_list_patterns
    end

    def required_list_patterns
      @required_list_patterns ||= all_list_patterns.select { |identifier, list_patterns|

        parent_identifier = parent_locale_for_locale_identifier(identifier)
        true if parent_identifier.nil?

        parent_list_patterns = all_list_patterns[parent_identifier]
        list_patterns != parent_list_patterns
      }
    end

    def required_locale_identifiers
      required_list_patterns.keys
    end

    def normalize_locale_identifier(identifier)
      identifier.gsub('-', '_')
    end

    def parent_locale_for_locale_identifier(identifier)

      manually_mapped_value = @parent_locales[identifier]
      unless manually_mapped_value.nil?
        return manually_mapped_value
      end

      components = identifier.split("_")[0...-1]
      components.join("_") unless components.empty?
    end
end

class DataAsset

  def name
    raise "Not Implemented"
  end

  def data
    raise "Not Implemented"
  end

  def write(directory)

    dataset_path = File.join(directory, "#{name}.dataset")
    data_path = File.join(dataset_path, filename)
    contents_path = File.join(dataset_path, "Contents.json")

    FileUtils.mkdir_p(dataset_path)

    File.open(data_path, "w") do |f|
      f.write(JSON.pretty_generate(data))
    end

    File.open(contents_path,"w") do |f|
      f.write(JSON.pretty_generate(contents))
    end
  end

  private

    def filename
      "#{name}.json"
    end

    def contents
      {
        :info => {
          :version => 1,
          :author => "xcode"
        },
        :data => [
          {
            :idiom => "universal",
            :filename => filename
          }
        ]
      }
    end
end

class LocaleInformation < DataAsset

  def initialize(parent_locales, locale_identifiers)
    @parent_locales = parent_locales
    @locale_identifiers = locale_identifiers
  end

  def name
    "localeInformation"
  end

  def data
    { :localeIdentifiers => @locale_identifiers, :parentLocale => @parent_locales }
  end
end

class ListPatterns < DataAsset

  def initialize(locale_identifier, cldr_list_patterns)
    @locale_identifier = locale_identifier
    @cldr_list_patterns = cldr_list_patterns
  end

  def name
    @locale_identifier
  end

  def data
    { :localeIdentifier => @locale_identifier, :listPatterns => formatted_list_patterns }
  end

  private

    def formatted_list_patterns
      cldr_list_patterns.map { |k,v| [convert_pattern_name(k), v] }.to_h
    end

    def cldr_list_patterns
      @cldr_list_patterns
    end

    def convert_pattern_name(key)
      uncapitalize(key.gsub("listPattern-type-", "").split("-").map { |x| x.capitalize }.join(""))
    end

    def uncapitalize(str)
      str[0, 1].downcase + str[1..-1]
    end
end
