class HomebrewIosCi < Formula
  desc "Build, archive & export iOS/MacOS app via command-line"
  homepage "https://github.com/tungdev1209/homebrew-ios-ci"
  version "1.0.1"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.0.1.tar.gz"
  sha256 "615dba929c555eaca2309e4f9ace8eea03e95aab3afb7d75c730e97a5f6b7dfc"

  def install
    bin.install "ios-ci"
    prefix.install "Author"
    prefix.install "README.md"
    prefix.install "hooks"
    prefix.install "config"
    system "chmod", "+x", "$(brew --cellar)/ios-ci/1.0.1/bin/ios-ci"
  end

  test do
    system "#{bin}/ios-ci", "--version"
  end
end
