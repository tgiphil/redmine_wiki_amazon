# vim: set ts=2 sts=2 sw=2 expandtab :
require 'redmine'
$rmwa_my_dir = File.dirname(__FILE__)

class AmazonUrlBuilderDefault
  attr_accessor :url 

  def initialize(mode = nil)
    @mode = mode
  end

  def item(asin)
    @url = "#"
    self
  end

  def image(asin)
    @url = "#"
    self
  end

  def associate(associate_id)
    self
  end
end


class AmazonUrlBuilderUs
  attr_accessor :url 

  def initialize(mode = nil)
    @mode = mode
  end

  def item(asin)
    @url = "http://www.amazon.com/dp/#{asin}"
    self
  end

  def associate(associate_id)
    @url = "#{@url}/?tag=#{associate_id}" unless associate_id == nil
    self
  end

  def image(asin)
    @url = "http://ec3.images-amazon.com/images/P/#{asin}.01._PC_SCMZZZZZZZ_.jpg"
    self
  end
end


class AmazonHelper
  def initialize(mode = nil)
    @mode = mode
  end

  def builder(country)
    AmazonUrlBuilderUs.new(@mode)
  end


  def trim(str)
    return str.strip unless str == nil
    return nil
  end


  def parse_args(args)
    asin = trim(args[0])
    associate_id = trim(args[1])
    country = (trim(args[2]).intern unless args[2] == nil) || $rmwa_global_settings["country"].intern

    return asin, associate_id, country
  end


  def get_image_url(asin, country)
    builder(country).image(asin).url
  end


  def get_item_url(asin, associate_id, country)
    builder(country).item(asin).associate(associate_id).url
  end


  def get_tag(args)
    return "(No parameters specified. ASIN is needed at least)" if args.empty?
    asin, associate_id, country = parse_args(args)

    return <<TEMPLATE
<a href="#{get_item_url(asin, associate_id, country)}">
  <img src="#{get_image_url(asin, country)}" />
</a>
TEMPLATE
  end

end

def load_global_settings
  conf_file = $rmwa_my_dir + '/config/settings.yml'
  begin
    $rmwa_global_settings = YAML.load_file(conf_file)
  rescue
    $rmwa_global_settings = { "country" => "en" }
  end
end

load_global_settings

Redmine::Plugin.register :redmine_wiki_amazon do
  name 'Redmine Plugin Amazon Link Wiki Macro'
  author 'Takashi Oguma; modified by Phil Garcia'
  description 'This plugin provides a macro \'amazon\' for Wiki which allows you to embed images and links to Amazon product page.'
  version '0.0.1m'

  Redmine::WikiFormatting::Macros.register do
    desc "make a link to Amazon product page.\n"
    macro :amazon do |obj, args|
      h = AmazonHelper.new
      h.get_tag(args)
    end

  end

end

