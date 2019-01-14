class IosCi < Formula
  desc "Build, Archive & Export iOS/MacOS app via command-line"
  homepage "https://tungdev1209.github.io/homebrew-ios-ci/"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.0.16.tar.gz"
  sha256 "bcd945a6eb3e9df869f332c5725d63633d8abc50c97e598a165db6c20ef4f3b7"

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
