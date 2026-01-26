# frozen_string_literal: true

module MountHelper
  def when_mounted(at: :uchi)
    original_mount_at = Uchi.routes.instance_variable_get(:@mount_at)
    begin
      Uchi.routes.instance_variable_set(:@mount_at, at)

      yield
    ensure
      # Restore original mount path
      Uchi.routes.instance_variable_set(:@mount_at, original_mount_at)
    end
  end
end
