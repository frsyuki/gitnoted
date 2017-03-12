require 'sinatra/base'
require 'rack/cors'
require 'rack/static'
require 'redcarpet'
require 'erb'
require 'json'
require 'git_noted/repository'

module GitNoted
  class Application < Sinatra::Base
    def self.default_renderer
      renderer = Redcarpet::Render::HTML.new({
        escape_html: true,
        safe_links_only: true,
      })
      redcarpet = Redcarpet::Markdown.new(renderer, {
        tables: true,
        no_intra_emphasis: true
      })
      redcarpet.method(:render)
    end

    def self.with(allow_origins: [], **options)
      Class.new(self) do
        alias_method :initialize_saved, :initialize
        define_method(:initialize) do
          initialize_saved(**options)
        end

        use Rack::Cors do
          allow do
            origins *allow_origins unless allow_origins.empty?

            resource '/api/*', {
                methods: [:get, :options, :head],
                headers: :any,
                expose:  [],
                credentials: true,
                max_age: 600,
            }
          end

          allow do
            origins '*'
            resource '/public/*', :headers => :any, :methods => :get
          end
        end
      end
    end

    def initialize(repository:, renderer: Application.default_renderer)
      super()
      @repository = repository
      @renderer = renderer
    end

    attr_accessor :repository
    attr_accessor :renderer

    use Rack::Static, urls: ["/js", "/css"], root: File.expand_path("../public", __FILE__)

    include ERB::Util

    TRANSPARENT_1PX_PNG = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=".unpack('m').first

    get '/' do
      redirect "/index.html"
    end

    # GET /api/notes
    #     ?labels=k1:v1,k2:v2,...
    #     ?exclude_labels=k1:v1,k2:v2,...
    get '/api/notes' do
      notes = load_notes(params).map do |note|
        {
          labels: note.labels,
          body: read_note(note)
        }
      end

      response = {
        notes: notes
      }

      content_type "application/json"
      return response.to_json
    end

    # GET /api/notes.html
    #     ?labels=k1:v1,k2:v2,...
    #     ?exclude_labels=k1:v1,k2:v2,...
    get '/api/notes.html' do
      notes = load_notes(params)

      html = %[<ul class="gitnoted">]
      notes.each do |note|
        body = render_note(note)
        html << %[<li class="gitnoted-note">]
          html << %[<div class="gitnoted-body">#{body}</div>]
          html << %[<ul class="gitnoted-labels">]
            note.labels.each do |label|
              html << %[<li class="gitnoted-label">#{html_escape(label)}</li>]
            end
          html << %[</ul>]
        html << %[</li>]
      end
      html << %[</ul>]

      content_type "text/html"
      return html
    end

    # GET /api/labels
    #     ?prefix=k1:
    #     ?used_with=k1:v1
    get '/api/labels' do
      labels = load_labels(params)

      response = {
        labels: labels
      }

      content_type "application/json"
      return response.to_json
    end

    # force update
    get '/api/github_hook' do
      @repository.update!

      response = { }

      content_type "application/json"
      return response.to_json
    end

    get '/favicon.ico' do
      content_type "image/png"
      return TRANSPARENT_1PX_PNG
    end

    def read_note(note)
      @repository.read(note)
    end

    def render_note(note)
      @renderer.call(read_note(note))
    end

    def load_notes(params)
      label_names = (params[:labels] || '').split(",")
      exclude_label_names = (params[:exclude_labels] || '').split(",")
      @repository.search_notes(labels: label_names, exclude_labels: exclude_label_names)
    end

    def load_labels(params)
      used_with_label_names = (params[:used_with] || '').split(',')
      prefix = params[:prefix]
      prefix = nil if prefix == ''
      @repository.search_labels(prefix: prefix, used_with: used_with_label_names)
    end
  end
end
