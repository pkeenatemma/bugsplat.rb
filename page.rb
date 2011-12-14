Encoding.default_internal, Encoding.default_external = ['utf-8'] * 2

require 'rubygems'
require 'redcarpet'
require 'date'

class Page

  DATE_REGEX = /\d{4}-\d{2}-\d{2}/
  DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

  attr_reader :name

  def self.parse_all(renderer)
    find_all.map do |page|
      self.new(normalize_name(page), renderer)
    end
  end

  def self.find_all
    Dir.glob(File.join(File.dirname(__FILE__), "entries", "*.md")).map do |fullpath|
      File.basename(fullpath)
    end
  end

  def initialize(page, renderer)
    @name = page
    @renderer = renderer
    parse_page
  end

  def parse_page
    headers, body = contents.split(/\n\n/, 2)
    parse_headers(headers)
    parse_body(body)
  end

  def parse_headers(header_text)
    @headers = {}
    header_text.split("\n").each do |header|
      name, value = header.split(/:\s+/)
      @headers[name.downcase] = value
    end
  end

  def parse_body(body_text)
    @body = body_text
    @before_fold, after_fold = body_text.split("--fold--")
  end

  def self.normalize_name(page)
    return page.downcase.strip.sub(/\.(html|md)$/,'')
  end

  def is_blog_post?
    return @name =~ DATE_REGEX
  end

  def render
    @renderer.render(@body)
  end

  def render_before_fold
    @renderer.render(@before_fold)
  end

  def contents
    @contents ||= File.open(filename, 'r:utf-8') do |file|
      file.read
    end
  end

  def filename
    File.join(File.dirname(__FILE__), "entries", "#{@name}.md")
  end

  def matches_path(path)
    normalized = self.class.normalize_name(path)
    return @name == normalized || @headers['id'] == normalized
  end

  def [](key)
    return @headers[key]
  end

  def date
    if is_blog_post?
      Time.strptime(@headers['date'], DATE_FORMAT)
    end
  end

  def html_path
    "/#{@name}.html"
  end
end
