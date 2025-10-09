# Homebrew formula for LiveWalls
require "fileutils"

class Livewalls < Formula
  desc "LiveWalls: Use videos as dynamic desktop wallpapers on macOS"
  homepage "https://github.com/fparrav/LiveWalls"
  url "https://github.com/fparrav/livewalls-dist/releases/download/v1.5.10/LiveWalls-v1.5.10.dmg"
  sha256 "ad8be0951c32a5bb8ab7f13172ed9f86281647f5fb0b168adc514be17977ea1e"

  livecheck do
    strategy :github_latest
  end

  depends_on macos: :sonoma

  def install
    mount_dir = Pathname.new(Dir.mktmpdir("livewalls-dmg"))
    begin
      system "hdiutil", "attach", cached_download, "-nobrowse", "-mountpoint", mount_dir

      app_path = mount_dir/"LiveWalls.app"
      odie "LiveWalls.app not found in DMG" unless app_path.directory?

      destination = prefix/"Applications/LiveWalls.app"
      destination.dirname.mkpath
      FileUtils.cp_r(app_path, destination)
    ensure
      if mount_dir.exist?
        system "hdiutil", "detach", mount_dir
        FileUtils.remove_entry mount_dir
      end
    end
  end

  def post_install
    # Remove quarantine attribute to avoid security warnings
    system "xattr", "-d", "com.apple.quarantine", "#{prefix}/Applications/LiveWalls.app"
  end

  test do
    # Basic test to verify installation
    system "true"
  end

  def caveats
    <<~EOS
      LiveWalls has been installed successfully to Applications folder.

      To use LiveWalls:
        1. Open Applications folder and launch LiveWalls
        2. Add your video files using the interface
        3. Select a video and set it as your wallpaper

      Note: LiveWalls requires accessibility permissions to set wallpapers.
      macOS will prompt you to grant these permissions when first running the app.

      For more information, visit:
        https://github.com/fparrav/LiveWalls
    EOS
  end
end
