class IosCi < Formula
  desc "Build, Archive & Export iOS/MacOS app via command-line"
  homepage "https://tungdev1209.github.io/homebrew-ios-ci/"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.1.1.tar.gz"
  sha256 "fc2c12fc6ec10775b69f53708a8df0e1a49f1a6a977fca7eee99f1d6cdda54ab"

  def install
    bin.install "ios-ci"
    prefix.install "Author"
    prefix.install "README.md"
    prefix.install "hooks"
    prefix.install "config"
    prefix.install "helper"
  end

  test do
    system "#{bin}/ios-ci", "__test_cmd"
  end
end
