class Depot < Formula
  desc "Private Terraform Registry with support for Modules and Providers"
  homepage "https://github.com/helixerio/depot"
  url "https://github.com/helixerio/depot/archive/refs/tags/v0.3.1.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "4fe26ca0aa59cebaea45a2c12a0672b365ddd5bc149fa00241cdde2af27f48b9"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args
  end

  test do
    assert_match "Depot version: 0.3.1", shell_output("#{bin}/depot version")
  end
end
