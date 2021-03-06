require 'oursignal'
require 'timeout'

module Oursignal
  #--
  # TODO: A queue etc.
  module Screenshot
    def self.generate link
      script   = File.join(Oursignal.root, 'js', 'rasterize.js')
      filename = link.id.to_s + '.png'
      tempfile = File.join(Oursignal.root, 'tmp', 'screenshots', filename)
      file     = File.join(Oursignal.root, 'public', 'screenshots', filename)

      begin
        Timeout.timeout(60) do
          Dir.chdir(Oursignal.root) do
            [
              ['/bin/mkdir', '-p', File.dirname(tempfile)],
              ['/bin/mkdir', '-p', File.dirname(file)],
              ['bin/phantomjs', script, link.url, tempfile],
              ['/usr/bin/convert', tempfile, '-crop 1680x1080+0+0', tempfile],
              ['/usr/bin/convert', tempfile, '-filter Lanczos', '-thumbnail 336x216', file],
              ['/bin/rm', tempfile]
            ].each do |command|
              system(command.join(' ')) || raise('system(%s) failed: %s' % [command.join(' '), $?])
            end
          end
        end
      rescue Timeout::Error
        warn "Timed out screenshotting #{link.url}"
        # Not ideal at all.
        system('/bin/killall phantomjs')
        system('/bin/killall convert')
        system("/bin/rm #{tempfile}")
      end
    end
  end # Screenshot
end # Oursignal

