require 'rugged'
require 'concurrent'
require 'pathname'

module GitNoted
  class Repository
    class Note
      def initialize(name, path, labels)
        @name = name
        @path = path
        @labels = labels
      end

      attr_reader :name, :path, :labels
    end

    def initialize(remote_url, local_path, username: nil, password: nil, logger: Logger.new(STDERR))
      @local_path = Pathname.new(local_path).cleanpath
      @remote_url = remote_url
      if username
        @credentials = Rugged::Credentials::UserPassword.new(username: username, password: password)
      else
        @credentials = nil
      end
      @logger = logger

      # initial update
      update! || index!
    end

    def update!
      begin
        @repo ||= Rugged::Repository.init_at(@local_path.to_s)
        updated = fetch(@repo)
        return false unless updated
      rescue => e
        # fall back to clone.
        @logger.warn "Failed to update repository incrementally. Falling back to clone: #{e}"
      end
      @repo = clone
      index!
      return true
    end

    def read(note)
      File.read(note.path).sub(/^:label:(.*)$\n/, '')
    end

    def schedule_update!(interval)
      Concurrent::ScheduledTask.execute(interval) do
        begin
          update!
        rescue => e
          @logger.error "Failed to update repository: #{e}"
          e.backtrace.each do |bt|
            @logger.error "  #{bt}"
          end
        ensure
          schedule_update!(interval)
        end
      end
    end

    def search_notes(labels: nil, exclude_labels: nil)
      labels ||= []
      exclude_labels ||= []

      @notes.select do |note|
        labels.all? {|t| note.labels.include?(t) } &&
          !exclude_labels.any? {|t| note.labels.include?(t) }
      end
    end

    def search_labels(prefix: nil, used_with: nil)
      match = {}
      @notes.each do |note|
        if used_with.nil? || used_with.all? {|t| note.labels.include?(t) }
          if prefix.nil?
            matching = note.labels
          else
            matching = note.labels.select {|label| label.start_with?(prefix) }
          end
          matching.each {|label| match[label] = true }
        end
      end
      match.keys.sort
    end

    private

    def clone
      logger_timer "Cloning remote repository." do
        tmp_path = "#{@local_path}.tmp"
        FileUtils.rm_rf tmp_path
        Rugged::Repository.clone_at(@remote_url, tmp_path, credentials: @credentials)
        FileUtils.rm_rf @local_path
        FileUtils.mv tmp_path, @local_path
        Rugged::Repository.init_at(@local_path.to_s)
      end
    end

    def fetch(repo)
      logger_timer "Fetching remote repository." do
        remote = repo.remotes["origin"]
        unless remote
          raise "Remote repository is not fetched yet."
        end
        fetched = remote.fetch
        return fetched[:total_objects] > 0
      end
    end

    def index!
      logger_timer "Updating label index." do
        files = Dir["#{@local_path}/**/*.md"]
        @notes = files.map do |path|
          name = Pathname.new(path).relative_path_from(Pathname.new(@local_path)).sub(/\.md$/, '')
          parse_note(name, path, File.read(path))
        end
      end
    end

    LABEL_KEY_CHARSET = /[a-zA-Z0-9_\-\.\/]/
    LABEL_VALUE_CHARSET = /[a-zA-Z0-9_\-\.\/]/

    def parse_note(name, path, text)
      m = /^:label:(.*)$/.match(text)
      if m
        labels = m[1].scan(/[a-zA-Z0-9_\-\.\/]+:[a-zA-Z0-9_\-\.\/]+/)
      else
        labels = []
      end

      Note.new(name, path, labels)
    end

    def logger_timer(start_message, end_message = "%.2f seconds.")
      @logger.info start_message
      start_time = Time.now
      begin
        return yield
      ensure
        finish_time = Time.now
        @logger.info end_message % (finish_time - start_time)
      end
    end
  end
end
