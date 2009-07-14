require 'oursignal/job'

module Oursignal
  module Score
    class Tally < Job
      self.poll_time = 5

      def poll
        links = Link.all(:conditions => {:score => nil})
        links + Link.all(:conditions => {:updated_at => {:'$lt' => Time.now - 60 * 15}})
      end

      def work(links)
        links.each do |link|
          # scores = self.class.subclasses.each{|s| s.new.score}
          score         = 0.5 # TODO: Bayesian average over scores.
          link.velocity = score - (link.score || 0)
          link.score    = score
          link.save
        end
      end
    end # Source
  end # Score
end # Oursignal