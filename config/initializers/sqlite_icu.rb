# frozen_string_literal: true

if Rails.env.production?
  module SqliteIcuExtension
    ICU_EXTENSION_PATH = Rails.root.join("lib", "sqlite_icu", "libSqliteIcu.so").to_s

    def configure_connection
      super

      return unless @config[:adapter] == "sqlite3"
      return unless File.exist?(ICU_EXTENSION_PATH)

      raw = @raw_connection
      raw.enable_load_extension(true)
      raw.load_extension(ICU_EXTENSION_PATH)
      raw.enable_load_extension(false)
    rescue => e
      Rails.logger.error("Failed to load SQLite ICU extension: #{e.class}: #{e.message}")
      raise
    end
  end

  ActiveSupport.on_load(:active_record) do
    ActiveRecord::ConnectionAdapters::SQLite3Adapter.prepend(SqliteIcuExtension)
  end
end