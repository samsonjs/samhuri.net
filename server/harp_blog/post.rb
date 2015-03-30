require 'securerandom'

class HarpBlog
  class Post

    PERSISTENT_FIELDS = %w[id author title date timestamp link url tags].map(&:to_sym)
    TRANSIENT_FIELDS = %w[time slug body draft].map(&:to_sym)
    FIELDS = PERSISTENT_FIELDS + TRANSIENT_FIELDS
    FIELDS.each { |f| attr_accessor f }

    def initialize(fields = nil)
      if fields
        FIELDS.each do |k|
          if v = fields[k.to_s] || fields[k.to_sym]
            instance_variable_set("@#{k}", v)
          end
        end
      end
    end

    def persistent_fields
      PERSISTENT_FIELDS.inject({}) do |h, k|
        h[k] = send(k)
        h
      end
    end

    def fields
      FIELDS.inject({}) do |h, k|
        h[k] = send(k)
        h
      end
    end

    def link?
      !!link
    end

    def draft?
      @draft
    end

    def author
      @author ||= 'Sami Samhuri'
    end

    def time
      @time ||= @timestamp ? Time.at(@timestamp) : Time.now
    end

    def time=(time)
      @timestamp = nil
      @date = nil
      @url = nil
      @time = time
    end

    def timestamp
      @timestamp ||= time.to_i
    end

    def timestamp=(timestamp)
      @time = nil
      @date = nil
      @url = nil
      @timestamp = timestamp
    end

    def id
      @id ||=
          if draft?
            SecureRandom.uuid
          else
            slug
          end
    end

    def url
      @url ||=
          if draft?
            "/posts/drafts/#{id}"
          else
            "/posts/#{time.year}/#{padded_month}/#{slug}"
          end
    end

    def slug
      # TODO: be intelligent about unicode ... \p{Word} might help. negated char class with it?
      if !draft? && title
        @slug ||= title.downcase.
            gsub(/'/, '').
            gsub(/[^[:alpha:]\d_]/, '-').
            gsub(/^-+|-+$/, '').
            gsub(/-+/, '-')
      end
    end

    def date
      @date ||= time.strftime('%B %d, %Y')
    end

    def tags
      @tags ||= []
    end

    def padded_month
      pad(time.month)
    end

    def dir
      if draft?
        'drafts'
      else
        File.join(time.year.to_s, padded_month)
      end
    end

    def pad(n)
      n.to_i < 10 ? "0#{n}" : "#{n}"
    end

  end
end