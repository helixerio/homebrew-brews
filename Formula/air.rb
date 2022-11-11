class Air < Formula
  desc "Live reload for Go apps"
  homepage "https://github.com/cosmtrek/air"
  url "https://github.com/cosmtrek/air/archive/v1.40.4.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "f762994733fad62bb1724fbcecc30e580eb3d88b5acf1f8896c223f666a6ef1b"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args
  end

  test do
    shell_output("#{bin}/air -v")
  end
end
