class Depot < Formula
  desc "Private Terraform Registry with support for Modules and Providers"
  homepage "https://github.com/helixerio/depot"
  url "https://github.com/helixerio/depot/archive/v0.1.0.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "9bf3127433ecf37e11e2aef5c0aa8118c6dd59f79bedf0de25a6ed828367f721"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args
  end

  test do
    assert_match "Depot version: 0.1.0", shell_output("#{bin}/depot version")
  end
end
