Merb.logger.info("Loaded STAGING Environment...")
ENV['INLINEDIR'] = Merb.root / 'tmp'
Merb::Config.use { |c|
  c[:bundle_assets]     = true
  c[:exception_details] = false
  c[:reload_classes]    = false
  c[:log_level]         = :error
  c[:log_file]  = Merb.root / "log" / "staging.log"
  # or redirect logger using IO handle
  # c[:log_stream] = STDOUT
}
