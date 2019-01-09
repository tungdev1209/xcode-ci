class IosCi < Formula
  desc "Build, archive & export iOS/MacOS app via command-line"
  homepage "https://github.com/tungdev1209/homebrew-ios-ci"
  version "1.0.3"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.0.3.tar.gz"
  sha256 "f1bc1c38bd08238867b8fb5d08fd7d893bd80e550243a793e6c088ed81f65bb4"

  def install
    bin.install "ios-ci"
    prefix.install "Author"
    prefix.install "README.md"
    prefix.install "hooks"
    prefix.install "config"
  end

  test do
    system "#{bin}/ios-ci", "--version"
  end
end
