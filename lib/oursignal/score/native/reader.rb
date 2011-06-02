require 'curb'
require 'time'
require 'zlib'

# Business.
require 'oursignal/link'
require 'oursignal/score/native'

module Oursignal
  module Score
    class Native
      module Reader
        def self.perform
          sources = Oursignal::Score::Native.all
          links   = Link.execute(%q{
            select * from links
            where updated_at < now() - interval '5 minutes'
          })

          # TODO: Safe distance from (ulimit -n) - (lsof | wc -l)
          multi = Curl::Multi.new
          multi.max_connects = 250
          sources.each do |source|
            links.each do |link|
              score = source.new(link)
              easy  = Curl::Easy.new(link.url) do |e|
                e.follow_location       = true
                e.timeout               = 5
                e.headers['User-Agent'] = Oursignal::USER_AGENT
                e.on_complete do |response|
                  begin
                    score.parse(body(response)) if response.response_code.to_s =~ /^2/
                  resuce => error
                    warn error
                  end
                end
              end
              multi.add easy
            end
          end
          multi.perform
        end

        protected
          def self.body curl
            if curl.header_str.match(/.*Content-Encoding:\sgzip\r/)
              begin
                gz   = Zlib::GzipReader.new(StringIO.new(curl.body_str))
                body = gz.read
                gz.close
                body
              rescue Zlib::GzipFile::Error
                curl.body_str
              end
            else
              curl.body_str
            end
          end

      end # Reader
    end # Native
  end # Score
end # Oursignal

