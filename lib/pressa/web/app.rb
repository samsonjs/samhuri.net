require "json"
require "sinatra/base"
require "super_good/csrf_protection"
require "pressa"
require "pressa/link_post"
require "pressa/open_graph"
require "pressa/posts/repo"
require "pressa/posts/tag_index"
require "pressa/web/draft_store"
require "pressa/web/job_runner"
require "pressa/web/preview"

module Pressa
  module Web
    # Pressa's web front end, hosted on mudge behind Caddy on the tailnet.
    #
    # It owns posting a link, drafts, and preview, and it does so by driving
    # the same bin/ scripts the phone Shortcut drives over SSH rather than
    # reimplementing the flow. Publishing runs inline: it measures about five
    # seconds, and the flock those scripts take is what stops two of them
    # running at once, so there is nothing here for a job queue to do.
    class App < Sinatra::Base
      class ConfigurationError < StandardError; end

      WEB_ROOT = File.expand_path("../../../web", __dir__)
      REPO_ROOT = File.expand_path("../../..", __dir__)
      TAG_CHIP_LIMIT = 24
      # bin/post-link and bin/publish-draft take an flock, so a second publish
      # exits 75 (EX_TEMPFAIL) instead of running. That's "try again shortly",
      # not a failure.
      BUSY_EXIT_STATUS = 75

      # There are no cookies or sessions here, so what a malicious page would be
      # riding isn't a login -- it's this machine's position on the tailnet.
      # Sec-Fetch-* are forbidden header names, so page JavaScript can't forge
      # them; a request without them didn't come from a browser and can't be the
      # confused deputy a CSRF needs, which is what keeps curl and the phone
      # Shortcut working.
      use SuperGood::CSRFProtection

      # The middleware guards unsafe methods, which is the right default. It
      # leaves GETs alone, but /link/metadata is a GET that makes this server
      # fetch a URL the caller chose, so a cross-site page could use it to probe
      # the tailnet blind. Rather than keep a second copy of the rule, ask the
      # middleware how it would treat the request if it were a POST.
      CROSS_ORIGIN_PROBE = SuperGood::CSRFProtection.new(->(_env) { [200, {}, []] })

      # Rendering every post to count tags takes a beat, and the link form is
      # the page that has to feel instant on a phone, so the chips are cached
      # until a post is added or edited. A plain hash rather than a Sinatra
      # setting: this is a mutable cache, not configuration, and `set` defines
      # methods.
      TAG_CACHE = {}

      # Built once at boot, by web/config.ru. Nothing builds them per request:
      # it costs about six milliseconds, and the memoisation that saved those
      # six milliseconds was the ugliest code in this file.
      def self.configure_sites!
        set :html_site, build_site("html")
        set :gemini_site, build_site("gemini")
      end

      def self.build_site(output_format)
        Pressa.create_site(source_path: repo_root, url_override: site_url, output_format:)
      end

      set :root, WEB_ROOT
      set :views, File.join(WEB_ROOT, "views")
      set :public_folder, File.join(WEB_ROOT, "public")
      set :bind, ENV.fetch("BIND_ADDRESS", "127.0.0.1")
      set :port, ENV.fetch("PORT", "1112")
      set :host_authorization, {permitted_hosts: ["pressa", "mudge", "localhost", "127.0.0.1"]}

      set :repo_root, REPO_ROOT
      set :site_url, ENV.fetch("PRESSA_SITE_URL", "https://samhuri.net")
      set :link_scraper, OpenGraph
      set :html_site, nil
      set :gemini_site, nil
      set :author, nil

      helpers do
        def h(text) = Rack::Utils.escape_html(text.to_s)

        def repo_path(*parts) = File.join(settings.repo_root, *parts)

        def drafts = DraftStore.new(dir: repo_path("public", "drafts"))

        def preview_renderer = Preview.new(html_site:, gemini_site:)

        def html_site = settings.html_site || missing_site!(:html_site)

        def gemini_site = settings.gemini_site || missing_site!(:gemini_site)

        def missing_site!(key)
          raise ConfigurationError, "#{key} was never set; web/config.ru builds it at boot"
        end

        def author = settings.author || html_site.author

        # Rendering every post to count tags takes a beat, and the link form
        # is the page you want instant on a phone, so it's cached until a post
        # is added or edited.
        def tag_chips
          files = Dir.glob(repo_path("posts", "**", "*.md"))
          key = [settings.repo_root, files.length, files.map { File.mtime(it) }.max]
          return TAG_CACHE[:tags] if TAG_CACHE[:key] == key

          posts = Posts::PostRepo.new.read_posts(repo_path("posts"))
          tags = Posts::TagIndex.from_posts_by_year(posts).counts.keys.first(TAG_CHIP_LIMIT)
          TAG_CACHE[:key] = key
          TAG_CACHE[:tags] = tags
          tags
        end

        def link_form
          {
            title: params[:title].to_s.strip,
            link: params[:link].to_s.strip,
            # Browsers normalize textarea line breaks to CRLF on submit, per
            # the HTML spec, even though nothing here ever inserts one.
            body: params[:body].to_s.gsub("\r\n", "\n").strip,
            tags: normalize_tags(params[:tags]),
            image: params[:image].to_s.strip
          }
        end

        def normalize_tags(value)
          value.to_s.split(",").map { it.strip.downcase }.reject(&:empty?).join(", ")
        end

        def link_post_source(form)
          LinkPost.build(
            title: form[:title], link: form[:link], body: form[:body], tags: form[:tags],
            image: form[:image].empty? ? nil : form[:image], author:
          )
        end

        # Runs one of the publish scripts inline. Returns nil when it worked,
        # or the status to halt with when it didn't, leaving @error and @log
        # for the page to render.
        def run_publish(command:, stdin_data: nil)
          @log = []
          @published = JobRunner.run(command:, stdin_data:, chdir: settings.repo_root) { @log << it }
          nil
        rescue JobRunner::Failed => e
          busy = e.exit_status == BUSY_EXIT_STATUS
          @error = busy ? "Something else is publishing right now. Try again in a moment." : e.message
          busy ? 409 : 500
        end

        def cross_origin_request?
          status, = CROSS_ORIGIN_PROBE.call(request.env.merge("REQUEST_METHOD" => "POST"))
          status == 403
        end

        def json_error(status, message) = halt(status, {error: message}.to_json)
      end

      # --- posting a link ----------------------------------------------------

      get "/" do
        @form = {}
        @tags = tag_chips
        @published = params[:published]
        erb :link
      end

      post "/link" do
        @form = link_form
        @tags = tag_chips

        if @form[:title].empty? || @form[:link].empty?
          @error = "A URL and a title are both required."
          halt 422, erb(:link)
        end

        payload = @form.reject { |_key, value| value.to_s.empty? }.to_json
        status = run_publish(command: [repo_path("bin", "post-link")], stdin_data: payload)
        # A failure keeps the form and the log on screen so it can be retried.
        halt status, erb(:link) if status

        # Success redirects so a reload can't publish the same post twice.
        redirect to("/?published=#{Rack::Utils.escape(@published)}"), 303
      end

      get "/link/metadata" do
        halt 403, "Forbidden" if cross_origin_request?

        content_type :json
        url = params[:url].to_s.strip
        json_error(400, "missing url") if url.empty?

        found = settings.link_scraper.fetch(url)
        return "{}" unless found

        {title: found.title, description: found.description, image: found.image}.compact.to_json
      end

      # --- preview -----------------------------------------------------------

      post "/preview" do
        content_type :json

        begin
          source, slug = preview_source
          result = preview_renderer.render(source, slug:)
        rescue Preview::Error, LinkPost::Error => e
          json_error(422, e.message)
        end

        {title: result.title, html: result.html, gemtext: result.gemtext}.to_json
      end

      # --- drafts ------------------------------------------------------------

      get "/drafts" do
        @drafts = drafts.list
        @published = params[:published]
        erb :drafts
      end

      post "/drafts" do
        slug =
          begin
            drafts.create(params[:title].to_s)
          rescue DraftStore::Conflict => e
            @drafts = drafts.list
            @error = e.message
            halt 409, erb(:drafts)
          rescue DraftStore::InvalidTitle
            @drafts = drafts.list
            @error = "That title doesn't make a usable filename."
            halt 422, erb(:drafts)
          end

        redirect to("/drafts/#{slug}"), 303
      end

      get "/drafts/:slug" do
        @slug = params[:slug]
        @source = find_draft(@slug)
        @version = drafts.version(@slug)
        erb :draft
      end

      # The editor holds raw markdown, so its own front matter is the only
      # place a readable title can come from.
      def self.draft_title(source, slug)
        source[/^Title:\s*(.+)$/, 1]&.strip&.then { it.empty? ? nil : it } || slug
      end

      post "/drafts/:slug" do
        @slug = params[:slug]
        find_draft(@slug)
        @source = params[:source].to_s
        @version = params[:version].to_s

        if @version.empty?
          @error = "This form is out of date. Reload the page, then paste your text back in."
          halt 422, erb(:draft)
        end

        begin
          drafts.write(@slug, @source, expected_version: @version)
        rescue DraftStore::Stale => e
          @version = e.current_version
          @conflict = e.current_content
          @error = "This draft changed on disk since you opened it. Your text is still below; " \
            "what's on disk now is underneath it."
          halt 409, erb(:draft)
        end

        redirect to("/drafts/#{@slug}"), 303
      end

      post "/drafts/:slug/publish" do
        @slug = params[:slug]
        @source = find_draft(@slug)
        @version = drafts.version(@slug)

        status = run_publish(command: [repo_path("bin", "publish-draft"), @slug])
        halt status, erb(:draft) if status

        # The draft is gone now, so there's nothing left to edit -- and the
        # redirect keeps a reload from trying to publish it again.
        redirect to("/drafts?published=#{Rack::Utils.escape(@published)}"), 303
      end

      post "/drafts/:slug/delete" do
        find_draft(params[:slug])
        drafts.delete(params[:slug])
        redirect to("/drafts"), 303
      end

      # --- odds and ends -----------------------------------------------------

      get "/tags" do
        content_type :json
        tag_chips.to_json
      end

      get "/up" do
        "ok"
      end

      not_found do
        next if response.body.any?

        erb :not_found
      end

      helpers do
        def find_draft(slug)
          drafts.read(slug)
        rescue DraftStore::Error
          halt 404, not_found_page("No draft named #{h(slug)}.")
        end

        def not_found_page(message)
          @message = message
          erb :not_found
        end

        def preview_source
          raw = params[:source].to_s
          unless raw.strip.empty?
            return [raw.gsub("\r\n", "\n"), preview_slug]
          end

          post = link_post_source(link_form)
          [post.content, File.basename(post.filename, ".md")]
        end

        def preview_slug
          slug = params[:slug].to_s
          slug.match?(DraftStore::SLUG_PATTERN) ? slug : "preview"
        end
      end
    end
  end
end
